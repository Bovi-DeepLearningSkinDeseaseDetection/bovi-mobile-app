/// What the restore of the history needs from the local evaluations (HU13).
abstract class EvaluationRestoreRepository {
  /// Whether this evaluation is already on the phone: the restore skips it,
  /// so a cut restore continues where it stopped.
  Future<bool> exists(String uuid);

  /// Evaluations of [ownerId] on this phone, to know if it has no data.
  Future<int> countOwnedBy(String ownerId);
}
