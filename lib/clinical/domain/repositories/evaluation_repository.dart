import '../model/aggregates/evaluation.dart';
import '../model/queries/evaluation_filter.dart';
import '../model/value_objects/body_zone.dart';

/// Local storage of the evaluations (HU10, HU11).
abstract class EvaluationRepository {
  /// Saves the evaluation and returns it with its local id.
  Future<Evaluation> save(Evaluation evaluation);

  /// Evaluations that meet [filter], newest first, updated whenever one is
  /// saved or changed.
  Stream<List<Evaluation>> watch([EvaluationFilter filter]);

  /// Links the evaluation to an animal and the body zone of the lesion
  /// (HU15, scenario 3) and returns it updated.
  Future<Evaluation> assignAnimal(
    int evaluationId, {
    required int animalId,
    required String animalEarTag,
    required BodyZone bodyZone,
  });
}
