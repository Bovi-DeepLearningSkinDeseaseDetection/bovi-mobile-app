// HU13 against the real backend (bovi-backend B3) and S3 (RustFS): one phone
// backs up, another phone of the same farmer restores. Skipped unless
// BOVI_API_URL is set:
//
//   BOVI_API_URL=http://localhost:8000 flutter test test/clinical/restore_backend_contract_test.dart
import 'dart:io';
import 'dart:math';

import 'package:bov_mobile_app/clinical/application/internal/commandservices/cloud_sync_service.dart';
import 'package:bov_mobile_app/clinical/application/internal/commandservices/history_restore_service.dart';
import 'package:bov_mobile_app/clinical/application/internal/outboundservices/external_iam_service.dart';
import 'package:bov_mobile_app/clinical/infrastructure/http/evaluation_sync_http_gateway.dart';
import 'package:bov_mobile_app/clinical/infrastructure/http/history_restore_http_gateway.dart';
import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/domain/model/commands/sign_up_command.dart';
import 'package:bov_mobile_app/iam/infrastructure/http/auth_http_gateway.dart';
import 'package:bov_mobile_app/iam/interfaces/acl/iam_context_facade.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_command_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_restore_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_sync_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/queryservices/animal_query_service.dart';
import 'package:bov_mobile_app/livestock/infrastructure/http/animal_restore_http_gateway.dart';
import 'package:bov_mobile_app/livestock/infrastructure/http/animal_sync_http_gateway.dart';
import 'package:bov_mobile_app/livestock/interfaces/acl/livestock_context_facade.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../iam/iam_fakes.dart' as iam;
import 'restore_fakes.dart';
import 'sync_fakes.dart';

/// A phone of the farmer with the real HTTP clients.
class _Phone {
  final evaluations = MemoryEvaluations();
  final animals = MemoryAnimals();
  final photos = MemoryPhotoStore();
  late final CloudSyncService sync;
  late final HistoryRestoreService restore;

  _Phone(Dio api, AuthCommandService auth) {
    final iamFacade = ExternalIamService(IamContextFacade(auth));
    final livestock = LivestockContextFacade(
      AnimalCommandService(animals),
      AnimalQueryService(animals),
      AnimalSyncService(animals, AnimalSyncHttpGateway(api)),
      AnimalRestoreService(animals, AnimalRestoreHttpGateway(api)),
    );
    sync = CloudSyncService(
      evaluations,
      EvaluationSyncHttpGateway(api),
      iamFacade,
      livestock,
    );
    restore = HistoryRestoreService(
      evaluations,
      evaluations,
      HistoryRestoreHttpGateway(api),
      photos,
      iamFacade,
      livestock,
    );
  }
}

void main() {
  final baseUrl = Platform.environment['BOVI_API_URL'];
  final skip = baseUrl == null ? 'BOVI_API_URL no está definida' : null;
  const photo = 'test/fixtures/paridad/ds1_dermatofitosis_01150.jpg';

  test('a new phone gets back the animals, evaluations and photos', () async {
    final api = createApiClient(baseUrl: '$baseUrl/api/v1');
    final run = Random().nextInt(1 << 32);
    final email = 'restore-$run@bovi.test';
    final oldAuth = AuthCommandService(
      AuthHttpGateway(api),
      iam.MemorySessionRepository(),
    );
    final created = await oldAuth.signUp(
      SignUpCommand(
        name: 'Ganadero restauración',
        email: email,
        password: 'establo2026',
        consentAccepted: true,
      ),
    );
    final owner = created.farmer.id;

    // The old phone backs up an animal and three evaluations.
    final oldPhone = _Phone(api, oldAuth);
    final settled = DateTime.now().subtract(const Duration(minutes: 10));
    oldPhone.animals.add(1, 'R-$run', uuid: _uuid(), owner: owner);
    final ids = [_uuid(), _uuid(), _uuid()];
    oldPhone.evaluations.add(
      evaluation(ids[0], owner: owner, animalId: 1, imagePath: photo),
      changed: settled,
    );
    for (final id in ids.skip(1)) {
      oldPhone.evaluations.add(
        evaluation(id, owner: owner, imagePath: photo),
        changed: settled,
      );
    }
    expect((await oldPhone.sync.syncNow()).synced, 3);

    // A new phone: the farmer signs in and the app offers the restore.
    final newAuth = AuthCommandService(
      AuthHttpGateway(api),
      iam.MemorySessionRepository(),
    );
    await newAuth.signIn(email: email, password: 'establo2026');
    final newPhone = _Phone(api, newAuth);
    expect(await newPhone.restore.pendingToRestore(), 3);

    final report = await newPhone.restore.restore();

    expect(report.outcome, RestoreOutcome.completed);
    expect(report.restored, 3);
    expect(report.animals, 1);
    expect(newPhone.evaluations.items.keys, unorderedEquals(ids));
    final withAnimal = newPhone.evaluations.items[ids[0]]!;
    expect(withAnimal.syncStatus, SyncStatus.synced);
    expect(withAnimal.animalEarTag, 'R-$run');
    expect(withAnimal.result.top.label, 'sarna');
    expect(withAnimal.result.modelVersion, 'v7c');
    // Each photo is exactly the one the old phone took.
    for (final id in ids) {
      expect(newPhone.photos.saved[id], File(photo).readAsBytesSync());
    }
    // Restored data is synced: nothing goes up again, and it is not offered.
    expect((await newPhone.sync.syncNow()).synced, 0);
    expect(await newPhone.restore.pendingToRestore(), 0);

    // Scenario 3: another farmer restores nothing of this one.
    final stranger = AuthCommandService(
      AuthHttpGateway(api),
      iam.MemorySessionRepository(),
    );
    await stranger.signUp(
      SignUpCommand(
        name: 'Otro ganadero',
        email: 'otro-$run@bovi.test',
        password: 'establo2026',
        consentAccepted: true,
      ),
    );
    final strangerPhone = _Phone(api, stranger);
    final nothing = await strangerPhone.restore.restore();
    expect(nothing.restored, 0);
    expect(strangerPhone.evaluations.items, isEmpty);
  }, skip: skip);
}

String _uuid() {
  final r = Random.secure();
  String hex(int n) =>
      List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
  return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
}
