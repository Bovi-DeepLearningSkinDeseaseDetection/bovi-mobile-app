import '../model/aggregates/evaluation.dart';

/// Local storage of the evaluations (HU10, HU11).
abstract class EvaluationRepository {
  /// Saves the evaluation and returns it with its local id.
  Future<Evaluation> save(Evaluation evaluation);

  /// All evaluations, newest first, updated whenever one is saved.
  Stream<List<Evaluation>> watchAll();
}
