import '../../../shared/domain/model/remote_page.dart';
import '../model/aggregates/animal.dart';

/// GET /api/v1/animals of the backend (HU13). The animals come with their
/// cloud uuid and as synced.
///
/// Throws ApiException (refused) or NetworkUnavailableException.
abstract class AnimalRestoreGateway {
  Future<RemotePage<Animal>> fetchAnimals(
    String token, {
    String? cursor,
    int limit = 100,
  });
}
