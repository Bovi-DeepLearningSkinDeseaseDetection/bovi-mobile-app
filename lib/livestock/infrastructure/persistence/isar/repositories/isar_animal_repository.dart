import 'package:isar_community/isar.dart';

import '../../../../domain/model/aggregates/animal.dart';
import '../../../../domain/model/valueobjects/ear_tag.dart';
import '../../../../domain/repositories/animal_repository.dart';
import '../entities/animal_entity.dart';

/// Stores the animals in the `animals` Isar collection.
class IsarAnimalRepository implements AnimalRepository {
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
      ..syncStatus = animal.syncStatus;
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
  );
}
