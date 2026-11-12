import '../model/aggregates/evaluation.dart';

/// What the cloud sync reads and writes on the local evaluations (HU12).
abstract class EvaluationSyncRepository {
  /// Pending evaluations of [ownerId], plus those without an owner (saved
  /// before the accounts existed), oldest first. Only those not changed
  /// since [changedBefore]: right after the analysis the farmer may still
  /// assign the animal, and once in the cloud the evaluation is immutable.
  Future<List<Evaluation>> pendingSync(
    String ownerId, {
    required DateTime changedBefore,
  });

  /// The backend confirmed them: they change to "Sincronizado" (scenario 2)
  /// and belong to [ownerId] from now on.
  Future<void> markSynced(Iterable<String> uuids, String ownerId, DateTime at);

  /// The backend rejected it for good: "Error al sincronizar" with [reason].
  Future<void> markFailed(String uuid, String ownerId, String reason);

  /// Number of evaluations waiting for the cloud, updated on every change.
  Stream<int> watchPendingCount();
}
