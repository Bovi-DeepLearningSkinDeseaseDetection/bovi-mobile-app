// HU12 against the real backend (bovi-backend B2) and S3 (RustFS). Skipped
// unless BOVI_API_URL is set:
//
//   cd bovi-backend && docker compose up -d --build db s3 s3-init api
//   BOVI_API_URL=http://localhost:8000 flutter test test/clinical/sync_backend_contract_test.dart
import 'dart:io';
import 'dart:math';

import 'package:bov_mobile_app/clinical/application/internal/commandservices/cloud_sync_service.dart';
import 'package:bov_mobile_app/clinical/application/internal/outboundservices/external_iam_service.dart';
import 'package:bov_mobile_app/clinical/infrastructure/http/evaluation_sync_http_gateway.dart';
import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/domain/model/commands/sign_up_command.dart';
import 'package:bov_mobile_app/iam/infrastructure/http/auth_http_gateway.dart';
import 'package:bov_mobile_app/iam/interfaces/acl/iam_context_facade.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_command_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_sync_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/queryservices/animal_query_service.dart';
import 'package:bov_mobile_app/livestock/infrastructure/http/animal_sync_http_gateway.dart';
import 'package:bov_mobile_app/livestock/interfaces/acl/livestock_context_facade.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../iam/iam_fakes.dart' as iam;
import 'sync_fakes.dart';

/// One phone: its own local data, the real backend.
class _Phone {
  final evaluations = MemoryEvaluations();
  final animals = MemoryAnimals();
  final AuthCommandService auth;
  late final CloudSyncService sync;

  _Phone(Dio api, this.auth) {
    sync = CloudSyncService(
      evaluations,
      EvaluationSyncHttpGateway(api),
      ExternalIamService(IamContextFacade(auth)),
      LivestockContextFacade(
        AnimalCommandService(animals),
        AnimalQueryService(animals),
        AnimalSyncService(animals, AnimalSyncHttpGateway(api)),
      ),
    );
  }
}

void main() {
  final baseUrl = Platform.environment['BOVI_API_URL'];
  final skip = baseUrl == null ? 'BOVI_API_URL no está definida' : null;
  const photo = 'test/fixtures/paridad/ds1_dermatofitosis_01150.jpg';

  late Dio api;
  late AuthCommandService auth;
  final run = Random().nextInt(1 << 32);

  setUpAll(() async {
    if (skip != null) return;
    api = createApiClient(baseUrl: '$baseUrl/api/v1');
    auth = AuthCommandService(
      AuthHttpGateway(api),
      iam.MemorySessionRepository(),
    );
    await auth.signUp(
      SignUpCommand(
        name: 'Ganadero sync',
        email: 'sync-$run@bovi.test',
        password: 'establo2026',
        consentAccepted: true,
      ),
    );
  });

  Future<Map<String, dynamic>> history() async {
    final token = await auth.validAccessToken();
    final response = await api.get<Map<String, dynamic>>(
      '/evaluations',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data!;
  }

  test('a phone backs up its animal, evaluations and photos', () async {
    final phone = _Phone(api, auth);
    final owner = (await auth.activeSession())!.farmer.id;
    phone.animals.add(1, 'PE-$run', uuid: _uuid(), owner: owner);
    final ids = [_uuid(), _uuid(), _uuid()];
    phone.evaluations.add(
      evaluation(ids[0], owner: owner, animalId: 1, imagePath: photo),
      changed: _settled,
    );
    phone.evaluations.add(
      evaluation(ids[1], owner: owner, imagePath: photo),
      changed: _settled,
    );
    phone.evaluations.add(
      evaluation(ids[2], imagePath: photo),
      changed: _settled,
    ); // pre-HU14

    final report = await phone.sync.syncNow();

    expect(report.outcome, SyncOutcome.completed);
    expect(report.synced, 3);
    expect(phone.animals.byId(1).syncStatus, SyncStatus.synced);
    final cloud = await history();
    expect(cloud['total'], 3);
    final withAnimal = (cloud['items'] as List).firstWhere(
      (e) => e['id'] == ids[0],
    );
    expect(withAnimal['animal_id'], phone.animals.byId(1).uuid);
    expect(withAnimal['body_zone'], 'flank');
    // The photo in S3 is exactly the one on the phone.
    final downloaded = await Dio().get<List<int>>(
      withAnimal['image_url'] as String,
      options: Options(responseType: ResponseType.bytes),
    );
    expect(downloaded.data, File(photo).readAsBytesSync());

    // Scenario 3: the answer was lost and the phone sends it again.
    phone.evaluations.add(
      evaluation(ids[1], owner: owner, imagePath: photo),
      changed: _settled,
    );
    final again = await phone.sync.syncNow();

    expect(again.synced, 1);
    expect(phone.evaluations.statusOf(ids[1]), SyncStatus.synced);
    expect((await history())['total'], 3); // no copy
  }, skip: skip);

  test('another phone with the same ear tag takes the cloud animal', () async {
    final first = _Phone(api, auth);
    final owner = (await auth.activeSession())!.farmer.id;
    final cloudId = _uuid();
    first.animals.add(1, 'MERGE-$run', uuid: cloudId, owner: owner);
    await first.sync.syncNow();

    final second = _Phone(api, auth);
    second.animals.add(1, 'merge-$run', uuid: _uuid(), owner: owner);
    final id = _uuid();
    second.evaluations.add(
      evaluation(id, owner: owner, animalId: 1, imagePath: photo),
      changed: _settled,
    );
    await second.sync.syncNow();

    expect(second.animals.byId(1).uuid, cloudId);
    final item = ((await history())['items'] as List).firstWhere(
      (e) => e['id'] == id,
    );
    expect(item['animal_id'], cloudId);
  }, skip: skip);
}

/// Older than the settle time of the sync, by the real clock.
final _settled = DateTime.now().subtract(const Duration(minutes: 10));

String _uuid() {
  final r = Random.secure();
  String hex(int n) =>
      List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
  return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
}
