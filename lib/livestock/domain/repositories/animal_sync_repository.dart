import '../model/aggregates/animal.dart';

/// What the cloud sync reads and writes on the local animals (HU12, HU15).
abstract class AnimalSyncRepository {
  /// Pending animals of [ownerId] and those without an owner.
  Future<List<Animal>> pendingSync(String ownerId);

  /// Synced; when the backend merged it with an animal of the same ear tag,
  /// the local uuid becomes [canonicalUuid] so later evaluations point to it.
  Future<void> markSynced(
    String uuid,
    String ownerId,
    DateTime at, {
    String? canonicalUuid,
  });

  Future<void> markFailed(String uuid, String ownerId, String reason);

  /// Keeps an animal restored from the cloud (HU13) and returns it with its
  /// local id. Already on the phone with that uuid: returned as it is. Same
  /// ear tag with another uuid: it is the same animal, it takes the cloud
  /// uuid.
  Future<Animal> restore(Animal cloud, String ownerId);
}
