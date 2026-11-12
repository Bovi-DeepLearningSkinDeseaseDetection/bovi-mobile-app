import '../../../shared/domain/model/remote_sync_result.dart';
import '../model/aggregates/animal.dart';

/// POST /api/v1/sync/animals of the backend.
///
/// Throws ApiException (refused) or NetworkUnavailableException.
abstract class AnimalSyncGateway {
  /// At most [maxBatch] animals per call.
  static const maxBatch = 50;

  Future<List<RemoteSyncResult>> sync(String token, List<Animal> animals);
}
