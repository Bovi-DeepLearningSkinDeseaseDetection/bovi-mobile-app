import 'dart:typed_data';

import 'package:bov_mobile_app/clinical/application/internal/commandservices/history_restore_service.dart';
import 'package:bov_mobile_app/clinical/application/internal/outboundservices/external_iam_service.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/body_zone.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/domain/services/evaluation_photo_store.dart';
import 'package:bov_mobile_app/clinical/domain/services/history_restore_gateway.dart';
import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/interfaces/acl/iam_context_facade.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_command_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_restore_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/queryservices/animal_query_service.dart';
import 'package:bov_mobile_app/livestock/domain/model/aggregates/animal.dart';
import 'package:bov_mobile_app/livestock/domain/model/valueobjects/animal_sex.dart';
import 'package:bov_mobile_app/livestock/domain/model/valueobjects/ear_tag.dart';
import 'package:bov_mobile_app/livestock/domain/services/animal_restore_gateway.dart';
import 'package:bov_mobile_app/livestock/interfaces/acl/livestock_context_facade.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';
import 'package:bov_mobile_app/shared/domain/model/remote_page.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';

import '../iam/iam_fakes.dart' as iam;
import 'sync_fakes.dart';

RemoteEvaluation remote(int i, {String? animalUuid}) => RemoteEvaluation(
  id: 'cloud-$i',
  evaluatedAt: old.subtract(Duration(hours: i)),
  origin: ImageOrigin.camera,
  result: sarna(),
  clinicalCodes: const [],
  catalogVersion: '2026.1',
  animalUuid: animalUuid,
  bodyZone: animalUuid == null ? null : BodyZone.udder,
  imageUrl: 'https://s3.test/cloud-$i.jpg',
);

Animal cloudAnimal(String uuid, String tag) => Animal(
  uuid: uuid,
  earTag: EarTag(tag),
  breed: 'Jersey',
  sex: AnimalSex.female,
  createdAt: old,
  syncStatus: SyncStatus.synced,
);

/// /evaluations and S3 of one farmer, paginated like the real backend.
class FakeHistoryCloud implements HistoryRestoreGateway {
  final evaluations = <RemoteEvaluation>[];
  final missingPhotos = <String>{};
  final dropOn = <String>{};
  final downloads = <String>[];
  int pages = 0;
  bool offline = false;

  @override
  Future<RemotePage<RemoteEvaluation>> fetchEvaluations(
    String token, {
    String? cursor,
    int limit = 50,
  }) async {
    if (offline) throw const NetworkUnavailableException();
    pages++;
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + limit).clamp(0, evaluations.length);
    return RemotePage(
      evaluations.sublist(start, end),
      evaluations.length,
      end < evaluations.length ? '$end' : null,
    );
  }

  @override
  Future<Uint8List> downloadPhoto(String url) async {
    final id = url.split('/').last.replaceAll('.jpg', '');
    if (dropOn.remove(id)) throw const NetworkUnavailableException();
    if (missingPhotos.contains(id)) throw const PhotoMissingException();
    downloads.add(id);
    return Uint8List.fromList(id.codeUnits);
  }
}

class FakeAnimalCloud implements AnimalRestoreGateway {
  final animals = <Animal>[];

  @override
  Future<RemotePage<Animal>> fetchAnimals(
    String token, {
    String? cursor,
    int limit = 100,
  }) async => RemotePage(animals, animals.length, null);
}

class MemoryPhotoStore implements EvaluationPhotoStore {
  final saved = <String, Uint8List>{};

  @override
  Future<String> pathOf(String fileName) async => '/fotos/$fileName';

  @override
  Future<({String image, String thumbnail})> saveDownloaded(
    Uint8List bytes,
    String id,
  ) async {
    saved[id] = bytes;
    return (image: '$id.jpg', thumbnail: '${id}_thumb.jpg');
  }
}

/// A new phone of the farmer, wired as in the app.
class RestoreHarness {
  final evaluations = MemoryEvaluations();
  final animals = MemoryAnimals();
  final cloud = FakeHistoryCloud();
  final animalCloud = FakeAnimalCloud();
  final photos = MemoryPhotoStore();
  final sessions = iam.MemorySessionRepository(iam.session());
  late final HistoryRestoreService service;

  RestoreHarness() {
    final auth = AuthCommandService(
      iam.FakeAuthGateway(),
      sessions,
      clock: () => now,
    );
    service = HistoryRestoreService(
      evaluations,
      evaluations,
      cloud,
      photos,
      ExternalIamService(IamContextFacade(auth)),
      LivestockContextFacade(
        AnimalCommandService(animals),
        AnimalQueryService(animals),
        null,
        AnimalRestoreService(animals, animalCloud),
      ),
    );
  }
}
