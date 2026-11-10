import '../../../../livestock/interfaces/acl/livestock_context_facade.dart';

/// What the clinical context needs from the livestock context, through its
/// facade only (anti-corruption layer).
class ExternalLivestockService {
  final LivestockContextFacade _livestock;

  const ExternalLivestockService(this._livestock);

  /// Keeps the animal first in the list of recent animals.
  Future<void> recordEvaluation(int animalId, DateTime at) =>
      _livestock.markEvaluated(animalId, at);
}
