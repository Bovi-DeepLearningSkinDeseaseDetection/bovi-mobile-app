import '../../../../shared/domain/model/remote_sync_result.dart';
import '../../../domain/repositories/animal_sync_repository.dart';
import '../../../domain/services/animal_sync_gateway.dart';

/// Backs up the animals registered on the phone (HU12 + HU15). They go before
/// the evaluations, which point to them by their uuid.
class AnimalSyncService {
  final AnimalSyncRepository _animals;
  final AnimalSyncGateway _gateway;
  final DateTime Function() _clock;

  AnimalSyncService(this._animals, this._gateway, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Returns how many animals were synced. Network and session errors are
  /// thrown to the caller, which retries the whole sync later.
  Future<int> syncPending({
    required String ownerId,
    required String token,
  }) async {
    final pending = await _animals.pendingSync(ownerId);
    var synced = 0;
    for (
      var start = 0;
      start < pending.length;
      start += AnimalSyncGateway.maxBatch
    ) {
      final batch = pending
          .skip(start)
          .take(AnimalSyncGateway.maxBatch)
          .toList();
      final results = await _gateway.sync(token, batch);
      for (final result in results) {
        if (result.isSynced) {
          // Merged: the farmer already had this ear tag in the cloud (HU15,
          // scenario 4); from now on the app uses the cloud id.
          final canonical = result.status == RemoteSyncStatus.merged
              ? result.canonicalId
              : null;
          await _animals.markSynced(
            result.id,
            ownerId,
            _clock(),
            canonicalUuid: canonical,
          );
          synced++;
        } else if (result.isFailed) {
          await _animals.markFailed(
            result.id,
            ownerId,
            result.message ?? 'El servidor rechazó el animal.',
          );
        }
      }
    }
    return synced;
  }
}
