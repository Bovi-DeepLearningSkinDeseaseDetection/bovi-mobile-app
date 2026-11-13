import 'package:isar_community/isar.dart';

import '../../../../domain/model/aggregates/animal.dart';
import '../../../../domain/model/valueobjects/ear_tag.dart';
import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../domain/repositories/animal_repository.dart';
import '../../../../domain/repositories/animal_sync_repository.dart';
import '../entities/animal_entity.dart';

/// Stores the animals in the `animals` Isar collection.
class IsarAnimalRepository implements AnimalRepository, AnimalSyncRepository {
  final Isar _isar;

  IsarAnimalRepository(this._isar);

  @override
  Future<Animal> save(Animal animal) async {
    final entity = AnimalEntity()
      ..id = animal.id ?? Isar.autoIncrement
      ..uuid = animal.uuid
      ..earTag = animal.earTag.value
      ..breed = animal.breed
      ..sex = animal.sex
      ..createdAt = animal.createdAt
      ..updatedAt = DateTime.now()
      ..lastEvaluatedAt = animal.lastEvaluatedAt
      ..syncStatus = animal.syncStatus
      ..ownerId = animal.ownerId
      ..syncError = animal.syncError;
    await _isar.writeTxn(() => _isar.animals.put(entity));
    return _toDomain(entity);
  }

  @override
  Future<Animal?> findById(int id) async {
    final entity = await _isar.animals.get(id);
    return entity == null ? null : _toDomain(entity);
  }

  // The unique ear tag index answers this lookup directly.
  @override
  Future<Animal?> findByEarTag(EarTag earTag) async {
    final entity = await _isar.animals.getByEarTag(earTag.value);
    return entity == null ? null : _toDomain(entity);
  }

  @override
  Future<List<Animal>> search(String text, {int limit = 30}) async {
    final entities = await _isar.animals
        .filter()
        .optional(text.isNotEmpty, (q) => q.earTagContains(text))
        .sortByLastEvaluatedAtDesc()
        .thenByCreatedAtDesc()
        .limit(limit)
        .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Future<void> markEvaluated(int id, DateTime at) async {
    await _isar.writeTxn(() async {
      final entity = await _isar.animals.get(id);
      if (entity == null) return;
      entity
        ..lastEvaluatedAt = at
        ..updatedAt = DateTime.now();
      await _isar.animals.put(entity);
    });
  }

  Animal _toDomain(AnimalEntity entity) => Animal(
    id: entity.id,
    uuid: entity.uuid,
    earTag: EarTag(entity.earTag),
    breed: entity.breed,
    sex: entity.sex,
    createdAt: entity.createdAt,
    lastEvaluatedAt: entity.lastEvaluatedAt,
    syncStatus: entity.syncStatus,
    ownerId: entity.ownerId,
    syncError: entity.syncError,
  );
  @override
  Future<List<Animal>> pendingSync(String ownerId) async {
    final entities = await _isar.animals
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .and()
        .group((q) => q.ownerIdEqualTo(ownerId).or().ownerIdIsNull())
        .sortByCreatedAt()
        .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Future<void> markSynced(
    String uuid,
    String ownerId,
    DateTime at, {
    String? canonicalUuid,
  }) => _update(uuid, (entity) {
    entity
      ..syncStatus = SyncStatus.synced
      ..syncedAt = at
      ..ownerId = ownerId
      ..syncError = null;
    // Merged with the animal of the same ear tag saved from another phone.
    if (canonicalUuid != null) entity.uuid = canonicalUuid;
  });

  @override
  Future<void> markFailed(String uuid, String ownerId, String reason) =>
      _update(uuid, (entity) {
        entity
          ..syncStatus = SyncStatus.failed
          ..ownerId = ownerId
          ..syncError = reason;
      });

  Future<void> _update(String uuid, void Function(AnimalEntity) change) =>
      _isar.writeTxn(() async {
        final entity = await _isar.animals.getByUuid(uuid);
        if (entity == null) return;
        change(entity);
        entity.updatedAt = DateTime.now();
        await _isar.animals.put(entity);
      });
  @override
  Future<Animal> restore(Animal cloud, String ownerId) async {
    final byUuid = await _isar.animals.getByUuid(cloud.uuid);
    if (byUuid != null) return _toDomain(byUuid);
    // The same ear tag saved on this phone is the same animal: the cloud
    // version wins and the local row takes its uuid.
    final entity =
        await _isar.animals.getByEarTag(cloud.earTag.value) ?? AnimalEntity();
    entity
      ..earTag = cloud.earTag.value
      ..breed = cloud.breed
      ..sex = cloud.sex
      ..createdAt = cloud.createdAt;
    entity
      ..uuid = cloud.uuid
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..syncedAt = DateTime.now()
      ..ownerId = ownerId
      ..syncError = null;
    await _isar.writeTxn(() => _isar.animals.put(entity));
    return _toDomain(entity);
  }
}
