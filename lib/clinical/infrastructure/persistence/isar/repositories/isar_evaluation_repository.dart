import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

import '../../../../domain/model/aggregates/evaluation.dart';
import '../../../../domain/model/queries/evaluation_filter.dart';
import '../../../../domain/model/value_objects/body_zone.dart';
import '../../../../domain/model/value_objects/clinical_code.dart';
import '../../../../domain/model/value_objects/evaluation_outcome.dart';
import '../../../../domain/model/value_objects/inference_result.dart';
import '../../../../domain/repositories/evaluation_repository.dart';
import '../../../storage/evaluation_image_store.dart';
import '../entities/evaluation_entity.dart';

/// Stores the evaluations in the `evaluations` Isar collection.
class IsarEvaluationRepository implements EvaluationRepository {
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
      ..syncStatus = evaluation.syncStatus;
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
    );
  }
}

typedef _Condition =
    QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
    Function(
      QueryBuilder<EvaluationEntity, EvaluationEntity, QFilterCondition> q,
    );
