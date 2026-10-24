import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

import '../../../../domain/model/aggregates/evaluation.dart';
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

  @override
  Stream<List<Evaluation>> watchAll() {
    return _isar.evaluations
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .asyncMap((entities) => Future.wait(entities.map(_toDomain)));
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
      ..venomCode = evaluation.venomCode
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
      venomCode: entity.venomCode,
      animalId: entity.animalId,
      animalEarTag: entity.animalEarTag,
      bodyZone: entity.bodyZone,
      syncStatus: entity.syncStatus,
    );
  }
}
