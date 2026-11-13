import '../../../domain/model/aggregates/animal.dart';
import '../../../domain/repositories/animal_sync_repository.dart';
import '../../../domain/services/animal_restore_gateway.dart';

/// Brings the farmer's animals back from the cloud (HU13). They go before
/// the evaluations, which point to them by their cloud uuid.
class AnimalRestoreService {
  static const _pageSize = 100;

  final AnimalSyncRepository _animals;
  final AnimalRestoreGateway _gateway;

  const AnimalRestoreService(this._animals, this._gateway);

  /// Every animal of the farmer on the phone, by cloud uuid. Network and
  /// session errors reach the caller; running it again is safe.
  Future<Map<String, Animal>> restoreAll({
    required String ownerId,
    required String token,
  }) async {
    final restored = <String, Animal>{};
    String? cursor;
    do {
      final page = await _gateway.fetchAnimals(
        token,
        cursor: cursor,
        limit: _pageSize,
      );
      for (final cloud in page.items) {
        restored[cloud.uuid] = await _animals.restore(cloud, ownerId);
      }
      cursor = page.nextCursor;
    } while (cursor != null);
    return restored;
  }
}
