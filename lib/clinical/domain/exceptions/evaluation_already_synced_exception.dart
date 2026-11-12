/// The evaluation is already in the cloud, where it cannot change (HU12):
/// its animal and body zone are final.
class EvaluationAlreadySyncedException implements Exception {
  static const message =
      'Esta evaluación ya está respaldada en la nube y no se puede cambiar.';

  const EvaluationAlreadySyncedException();

  @override
  String toString() => 'EvaluationAlreadySyncedException';
}
