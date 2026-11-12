import 'package:bov_mobile_app/clinical/application/internal/commandservices/cloud_sync_service.dart';
import 'package:bov_mobile_app/clinical/application/internal/outboundservices/external_iam_service.dart';
import 'package:bov_mobile_app/clinical/domain/model/aggregates/evaluation.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/body_zone.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/domain/model/queries/evaluation_filter.dart';
import 'package:bov_mobile_app/clinical/domain/repositories/evaluation_repository.dart';
import 'package:bov_mobile_app/clinical/domain/repositories/evaluation_restore_repository.dart';
import 'package:bov_mobile_app/clinical/domain/repositories/evaluation_sync_repository.dart';
import 'package:bov_mobile_app/clinical/domain/services/evaluation_sync_gateway.dart';
import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/interfaces/acl/iam_context_facade.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_command_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_sync_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/queryservices/animal_query_service.dart';
import 'package:bov_mobile_app/livestock/domain/model/aggregates/animal.dart';
import 'package:bov_mobile_app/livestock/domain/model/valueobjects/animal_sex.dart';
import 'package:bov_mobile_app/livestock/domain/model/valueobjects/ear_tag.dart';
import 'package:bov_mobile_app/livestock/domain/repositories/animal_repository.dart';
import 'package:bov_mobile_app/livestock/domain/repositories/animal_sync_repository.dart';
import 'package:bov_mobile_app/livestock/domain/services/animal_sync_gateway.dart';
import 'package:bov_mobile_app/livestock/interfaces/acl/livestock_context_facade.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';
import 'package:bov_mobile_app/shared/domain/model/remote_sync_result.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';

import '../iam/iam_fakes.dart' as iam;

final now = iam.now;
final old = now.subtract(const Duration(minutes: 10));
final ownerId = iam.farmer.id;
const otherOwner = 'otro-ganadero';

InferenceResult sarna() => InferenceResult(
  probabilities: const [
    ClassProbability('dermatofitosis', 0.006108),
    ClassProbability('miasis', 0.000231),
    ClassProbability('papilomatosis', 0.015779),
    ClassProbability('piel_sana', 0.002489),
    ClassProbability('sarna', 0.975393),
  ],
  modelVersion: 'v7c',
  elapsed: const Duration(milliseconds: 180),
);

Evaluation evaluation(
  String uuid, {
  String? owner,
  int? animalId,
  SyncStatus status = SyncStatus.pending,
  String imagePath = 'foto.jpg',
}) => Evaluation(
  id: uuid.hashCode,
  uuid: uuid,
  createdAt: old,
  imagePath: imagePath,
  thumbnailPath: 'mini.jpg',
  origin: ImageOrigin.camera,
  result: sarna(),
  animalId: animalId,
  animalEarTag: animalId == null ? null : 'PE-$animalId',
  bodyZone: animalId == null ? null : BodyZone.flank,
  syncStatus: status,
  ownerId: owner,
);

/// The evaluations of the phone, with the same filters as the Isar one.
class MemoryEvaluations
    implements
        EvaluationRepository,
        EvaluationSyncRepository,
        EvaluationRestoreRepository {
  final items = <String, Evaluation>{};
  final changedAt = <String, DateTime>{};

  void add(Evaluation e, {DateTime? changed}) {
    items[e.uuid] = e;
    changedAt[e.uuid] = changed ?? old;
  }

  SyncStatus statusOf(String uuid) => items[uuid]!.syncStatus;

  @override
  Future<List<Evaluation>> pendingSync(
    String ownerId, {
    required DateTime changedBefore,
  }) async => items.values
      .where(
        (e) =>
            e.syncStatus == SyncStatus.pending &&
            changedAt[e.uuid]!.isBefore(changedBefore) &&
            (e.ownerId == null || e.ownerId == ownerId),
      )
      .toList();

  @override
  Future<void> markSynced(
    Iterable<String> uuids,
    String ownerId,
    DateTime at,
  ) async {
    for (final uuid in uuids) {
      items[uuid] = _copy(items[uuid]!, SyncStatus.synced, ownerId, null);
    }
  }

  @override
  Future<void> markFailed(String uuid, String ownerId, String reason) async =>
      items[uuid] = _copy(items[uuid]!, SyncStatus.failed, ownerId, reason);

  @override
  Stream<int> watchPendingCount() => const Stream.empty();

  @override
  Future<Evaluation> save(Evaluation evaluation) async {
    add(evaluation, changed: now);
    return evaluation;
  }

  @override
  Stream<List<Evaluation>> watch([
    EvaluationFilter filter = EvaluationFilter.none,
  ]) => Stream.value(items.values.toList());

  @override
  Future<Evaluation> assignAnimal(
    int evaluationId, {
    required int animalId,
    required String animalEarTag,
    required BodyZone bodyZone,
  }) => throw UnimplementedError();

  @override
  Future<bool> exists(String uuid) async => items.containsKey(uuid);

  @override
  Future<int> countOwnedBy(String ownerId) async =>
      items.values.where((e) => e.ownerId == ownerId).length;

  static Evaluation _copy(
    Evaluation e,
    SyncStatus status,
    String owner,
    String? error,
  ) => Evaluation(
    id: e.id,
    uuid: e.uuid,
    createdAt: e.createdAt,
    imagePath: e.imagePath,
    thumbnailPath: e.thumbnailPath,
    origin: e.origin,
    result: e.result,
    clinicalCodes: e.clinicalCodes,
    catalogVersion: e.catalogVersion,
    animalId: e.animalId,
    animalEarTag: e.animalEarTag,
    bodyZone: e.bodyZone,
    syncStatus: status,
    ownerId: owner,
    syncError: error,
  );
}

/// The animals of the phone.
class MemoryAnimals implements AnimalRepository, AnimalSyncRepository {
  final items = <int, Animal>{};

  Animal add(int id, String tag, {String? uuid, String? owner}) =>
      items[id] = Animal(
        id: id,
        uuid: uuid ?? 'animal-$id',
        earTag: EarTag(tag),
        breed: 'Holstein',
        sex: AnimalSex.female,
        createdAt: old,
        ownerId: owner,
      );

  Animal byId(int id) => items[id]!;

  @override
  Future<Animal> save(Animal animal) async => items[animal.id!] = animal;

  @override
  Future<Animal?> findById(int id) async => items[id];

  @override
  Future<Animal?> findByEarTag(EarTag earTag) async =>
      items.values.where((a) => a.earTag == earTag).firstOrNull;

  @override
  Future<List<Animal>> search(String text, {int limit = 30}) async =>
      items.values.toList();

  @override
  Future<void> markEvaluated(int id, DateTime at) async {}

  @override
  Future<List<Animal>> pendingSync(String ownerId) async => items.values
      .where(
        (a) =>
            a.syncStatus == SyncStatus.pending &&
            (a.ownerId == null || a.ownerId == ownerId),
      )
      .toList();

  @override
  Future<void> markSynced(
    String uuid,
    String ownerId,
    DateTime at, {
    String? canonicalUuid,
  }) async => _update(uuid, SyncStatus.synced, ownerId, canonicalUuid, null);

  @override
  Future<void> markFailed(String uuid, String ownerId, String reason) async =>
      _update(uuid, SyncStatus.failed, ownerId, null, reason);

  @override
  Future<Animal> restore(Animal cloud, String ownerId) async {
    final byUuid = items.values.where((a) => a.uuid == cloud.uuid).firstOrNull;
    if (byUuid != null) return byUuid;
    final sameTag = items.values
        .where((a) => a.earTag == cloud.earTag)
        .firstOrNull;
    final id = sameTag?.id ?? items.length + 1;
    return items[id] = Animal(
      id: id,
      uuid: cloud.uuid,
      earTag: cloud.earTag,
      breed: cloud.breed,
      sex: cloud.sex,
      createdAt: cloud.createdAt,
      syncStatus: SyncStatus.synced,
      ownerId: ownerId,
    );
  }

  void _update(
    String uuid,
    SyncStatus status,
    String owner,
    String? newUuid,
    String? error,
  ) {
    final a = items.values.firstWhere((a) => a.uuid == uuid);
    items[a.id!] = Animal(
      id: a.id,
      uuid: newUuid ?? a.uuid,
      earTag: a.earTag,
      breed: a.breed,
      sex: a.sex,
      createdAt: a.createdAt,
      syncStatus: status,
      ownerId: owner,
      syncError: error,
    );
  }
}

/// /sync/animals that remembers what it saved, like the real one.
class FakeAnimalBackend implements AnimalSyncGateway {
  final savedTags = <String, String>{}; // ear tag -> cloud id
  final rejected = <String, (String, String)>{};
  int calls = 0;

  @override
  Future<List<RemoteSyncResult>> sync(
    String token,
    List<Animal> animals,
  ) async {
    calls++;
    return [
      for (final a in animals)
        if (rejected[a.uuid] case (final code, final message))
          RemoteSyncResult(
            id: a.uuid,
            status: RemoteSyncStatus.rejected,
            code: code,
            message: message,
          )
        else if (savedTags[a.earTag.value] case final cloudId?)
          RemoteSyncResult(
            id: a.uuid,
            status: cloudId == a.uuid
                ? RemoteSyncStatus.duplicate
                : RemoteSyncStatus.merged,
            canonicalId: cloudId,
          )
        else
          _accept(a),
    ];
  }

  RemoteSyncResult _accept(Animal a) {
    savedTags[a.earTag.value] = a.uuid;
    return RemoteSyncResult(
      id: a.uuid,
      status: RemoteSyncStatus.accepted,
      canonicalId: a.uuid,
    );
  }
}

/// The backend and S3 for the evaluations, remembering what was saved so a
/// resend answers `duplicate`, like the real one (RNF10).
class FakeEvaluationBackend implements EvaluationSyncGateway {
  final saved = <String, EvaluationUpload>{};
  final photos = <String>{};
  final calls = <String>[];
  final batchSizes = <int>[];

  /// Evaluations S3 refuses (too big).
  final rejectedPhotos = <String>{};

  /// Answers forced by id: (code, message) of a rejection.
  final rejections = <String, (String, String)>{};

  /// Ids whose photo upload loses the connection, once each.
  final dropConnectionOn = <String>{};

  /// Every call to the backend answers 401.
  bool revokeToken = false;

  @override
  Future<List<UploadTicket>> requestUploads(
    String token,
    List<String> ids,
  ) async {
    calls.add('upload-url');
    _checkToken();
    return [
      for (final id in ids)
        UploadTicket(
          evaluationId: id,
          status: saved.containsKey(id)
              ? UploadTicketStatus.alreadySynced
              : UploadTicketStatus.ready,
          url: 'https://s3.test/bucket',
          fields: {'key': 'evaluaciones/$ownerId/$id.jpg'},
        ),
    ];
  }

  @override
  Future<void> uploadPhoto(UploadTicket ticket, String filePath) async {
    calls.add('photo');
    if (dropConnectionOn.remove(ticket.evaluationId)) {
      throw const NetworkUnavailableException();
    }
    if (rejectedPhotos.contains(ticket.evaluationId)) {
      throw const PhotoRejectedException();
    }
    photos.add(ticket.evaluationId);
  }

  @override
  Future<List<RemoteSyncResult>> sync(
    String token,
    List<EvaluationUpload> evaluations,
  ) async {
    calls.add('sync');
    _checkToken();
    batchSizes.add(evaluations.length);
    return [for (final upload in evaluations) _answer(upload)];
  }

  RemoteSyncResult _answer(EvaluationUpload upload) {
    final id = upload.evaluation.uuid;
    if (rejections[id] case (final code, final message)) {
      return RemoteSyncResult(
        id: id,
        status: RemoteSyncStatus.rejected,
        code: code,
        message: message,
      );
    }
    if (!photos.contains(id)) {
      return RemoteSyncResult(
        id: id,
        status: RemoteSyncStatus.rejected,
        code: 'imagen_no_encontrada',
        message: 'La foto aún no se subió.',
      );
    }
    final duplicate = saved.containsKey(id);
    saved[id] = upload;
    return RemoteSyncResult(
      id: id,
      status: duplicate
          ? RemoteSyncStatus.duplicate
          : RemoteSyncStatus.accepted,
    );
  }

  void _checkToken() {
    if (revokeToken) {
      throw const ApiException(
        ApiFailure(401, 'token_invalido', 'Su sesión no es válida.'),
      );
    }
  }
}

/// Everything wired as in the app, with the fakes above.
class SyncHarness {
  final evaluations = MemoryEvaluations();
  final animals = MemoryAnimals();
  final animalBackend = FakeAnimalBackend();
  final backend = FakeEvaluationBackend();
  final gateway = iam.FakeAuthGateway();
  final sessions = iam.MemorySessionRepository(iam.session());
  late final CloudSyncService service;

  SyncHarness() {
    final auth = AuthCommandService(gateway, sessions, clock: () => now);
    final livestock = LivestockContextFacade(
      AnimalCommandService(animals),
      AnimalQueryService(animals),
      AnimalSyncService(animals, animalBackend, clock: () => now),
    );
    service = CloudSyncService(
      evaluations,
      backend,
      ExternalIamService(IamContextFacade(auth)),
      livestock,
      clock: () => now,
    );
  }
}
