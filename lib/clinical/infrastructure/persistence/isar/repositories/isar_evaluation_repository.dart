import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

import '../../../../domain/exceptions/evaluation_already_synced_exception.dart';
import '../../../../domain/model/aggregates/evaluation.dart';
import '../../../../domain/model/queries/evaluation_filter.dart';
import '../../../../domain/model/value_objects/body_zone.dart';
import '../../../../domain/model/value_objects/clinical_code.dart';
import '../../../../domain/model/value_objects/evaluation_outcome.dart';
import '../../../../domain/model/value_objects/inference_result.dart';
import '../../../../domain/repositories/evaluation_repository.dart';
import '../../../../domain/repositories/evaluation_restore_repository.dart';
import '../../../../domain/repositories/evaluation_sync_repository.dart';
import '../../../../../shared/domain/model/sync_status.dart';
import '../../../storage/evaluation_image_store.dart';
import '../entities/evaluation_entity.dart';

/// Stores the evaluations in the `evaluations` Isar collection.
class IsarEvaluationRepository
    implements
        EvaluationRepository,
        EvaluationSyncRepository,
        EvaluationRestoreRepository {
  final Isar _isar;
  final EvaluationImageStore _images;

  IsarEvaluationRepository(this._isar, this._images);

  @override
  Future<Evaluation> save(Evaluation evaluation) async {
    final entity = _toEntity(evaluation);
    await _isar.writeTxn(() => _isar.evaluations.put(entity));
    return _toDomain(entity);
  }

  // The date range walks the createdAt index backwards, so the results come
  // out newest first without sorting; the other filters are applied on the
  // way (HU11, scenario 5).
  @override
  Stream<List<Evaluation>> watch([
    EvaluationFilter filter = EvaluationFilter.none,
  ]) {
    final conditions = <_Condition>[
      if (filter.animalId != null) (q) => q.animalIdEqualTo(filter.animalId),
      if (filter.inconclusive)
        (q) => q.outcomeEqualTo(EvaluationOutcome.inconclusive),
      if (filter.label != null)
        (q) => q
            .topLabelEqualTo(filter.label!)
            .and()
            .not()
            .outcomeEqualTo(EvaluationOutcome.inconclusive),
      if (filter.syncStatus != null)
        (q) => q.syncStatusEqualTo(filter.syncStatus!),
    ];
    return _isar.evaluations
        .where(sort: Sort.desc)
        .createdAtBetween(filter.start ?? _firstDate, filter.end ?? _lastDate)
        .filter()
        .allOf(conditions, (q, condition) => condition(q))
        .watch(fireImmediately: true)
        .asyncMap((entities) => Future.wait(entities.map(_toDomain)));
  }

  static final _firstDate = DateTime.fromMillisecondsSinceEpoch(0);
  static final _lastDate = DateTime(9999);

  @override
  Future<Evaluation> assignAnimal(
    int evaluationId, {
    required int animalId,
    required String animalEarTag,
    required BodyZone bodyZone,
  }) async {
    final entity = await _isar.evaluations.get(evaluationId);
    if (entity == null) {
      throw StateError('Evaluation $evaluationId does not exist.');
    }
    // The cloud copy is immutable: it would no longer match.
    if (entity.syncStatus == SyncStatus.synced) {
      throw const EvaluationAlreadySyncedException();
    }
    entity
      ..animalId = animalId
      ..animalEarTag = animalEarTag
      ..bodyZone = bodyZone
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.evaluations.put(entity));
    return _toDomain(entity);
  }

  EvaluationEntity _toEntity(Evaluation evaluation) {
    final result = evaluation.result;
    return EvaluationEntity()
      ..id = evaluation.id ?? Isar.autoIncrement
      ..uuid = evaluation.uuid
      ..createdAt = evaluation.createdAt
      ..updatedAt = DateTime.now()
      // The store keeps the files in one folder; only the names are saved.
      ..imageFile = p.basename(evaluation.imagePath)
      ..thumbnailFile = p.basename(evaluation.thumbnailPath)
      ..origin = evaluation.origin
      ..outcome = evaluation.outcome
      ..topLabel = result.top.label
      ..confidence = result.top.probability
      ..probabilities = [
        for (final item in result.probabilities)
          ClassScoreEmbedded()
            ..label = item.label
            ..probability = item.probability,
      ]
      ..clinicalCodes = [
        for (final code in evaluation.clinicalCodes)
          ClinicalCodeEmbedded()
            ..system = code.system
            ..code = code.code
            ..display = code.display,
      ]
      ..catalogVersion = evaluation.catalogVersion
      ..modelVersion = result.modelVersion
      ..inferenceMs = result.elapsed.inMilliseconds
      ..animalId = evaluation.animalId
      ..animalEarTag = evaluation.animalEarTag
      ..bodyZone = evaluation.bodyZone
      ..syncStatus = evaluation.syncStatus
      ..ownerId = evaluation.ownerId
      ..syncError = evaluation.syncError;
  }

  Future<Evaluation> _toDomain(EvaluationEntity entity) async {
    return Evaluation(
      id: entity.id,
      uuid: entity.uuid,
      createdAt: entity.createdAt,
      imagePath: await _images.pathOf(entity.imageFile),
      thumbnailPath: await _images.pathOf(entity.thumbnailFile),
      origin: entity.origin,
      result: InferenceResult(
        probabilities: [
          for (final score in entity.probabilities)
            ClassProbability(score.label, score.probability),
        ],
        modelVersion: entity.modelVersion,
        elapsed: Duration(milliseconds: entity.inferenceMs),
      ),
      clinicalCodes: [
        for (final code
            in entity.clinicalCodes ?? const <ClinicalCodeEmbedded>[])
          ClinicalCode(
            system: code.system,
            code: code.code,
            display: code.display,
          ),
      ],
      catalogVersion: entity.catalogVersion,
      animalId: entity.animalId,
      animalEarTag: entity.animalEarTag,
      bodyZone: entity.bodyZone,
      syncStatus: entity.syncStatus,
      ownerId: entity.ownerId,
      syncError: entity.syncError,
    );
  }

  @override
  Future<List<Evaluation>> pendingSync(
    String ownerId, {
    required DateTime changedBefore,
  }) async {
    final entities = await _isar.evaluations
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .and()
        .updatedAtLessThan(changedBefore)
        .and()
        .group((q) => q.ownerIdEqualTo(ownerId).or().ownerIdIsNull())
        .sortByCreatedAt()
        .findAll();
    return Future.wait(entities.map(_toDomain));
  }

  @override
  Future<void> markSynced(
    Iterable<String> uuids,
    String ownerId,
    DateTime at,
  ) => _update(uuids, (entity) {
    entity
      ..syncStatus = SyncStatus.synced
      ..syncedAt = at
      ..ownerId = ownerId
      ..syncError = null;
  });

  @override
  Future<void> markFailed(String uuid, String ownerId, String reason) =>
      _update([uuid], (entity) {
        entity
          ..syncStatus = SyncStatus.failed
          ..ownerId = ownerId
          ..syncError = reason;
      });

  @override
  Stream<int> watchPendingCount() => _isar.evaluations
      .filter()
      .syncStatusEqualTo(SyncStatus.pending)
      .watchLazy(fireImmediately: true)
      .asyncMap(
        (_) => _isar.evaluations
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .count(),
      );

  Future<void> _update(
    Iterable<String> uuids,
    void Function(EvaluationEntity entity) change,
  ) => _isar.writeTxn(() async {
    for (final uuid in uuids) {
      final entity = await _isar.evaluations.getByUuid(uuid);
      if (entity == null) continue;
      change(entity);
      entity.updatedAt = DateTime.now();
      await _isar.evaluations.put(entity);
    }
  });
  @override
  Future<bool> exists(String uuid) async =>
      await _isar.evaluations.getByUuid(uuid) != null;

  @override
  Future<int> countOwnedBy(String ownerId) =>
      _isar.evaluations.filter().ownerIdEqualTo(ownerId).count();
}

typedef _Condition =
    QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
    Function(
      QueryBuilder<EvaluationEntity, EvaluationEntity, QFilterCondition> q,
    );
