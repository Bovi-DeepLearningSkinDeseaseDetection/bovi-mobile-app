import 'package:bov_mobile_app/livestock/application/internal/commandservices/animal_command_service.dart';
import 'package:bov_mobile_app/livestock/application/internal/queryservices/animal_query_service.dart';
import 'package:bov_mobile_app/livestock/domain/model/aggregates/animal.dart';
import 'package:bov_mobile_app/livestock/domain/model/valueobjects/animal_sex.dart';
import 'package:bov_mobile_app/livestock/domain/model/valueobjects/ear_tag.dart';
import 'package:bov_mobile_app/livestock/domain/repositories/animal_repository.dart';
import 'package:bov_mobile_app/livestock/interfaces/acl/livestock_context_facade.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository kept in memory, with the same rules as the Isar one.
class _MemoryAnimals implements AnimalRepository {
  final _animals = <Animal>[];

  @override
  Future<Animal> save(Animal animal) async {
    final saved = Animal(
      id: _animals.length + 1,
      uuid: animal.uuid,
      earTag: animal.earTag,
      breed: animal.breed,
      sex: animal.sex,
      createdAt: animal.createdAt,
      lastEvaluatedAt: animal.lastEvaluatedAt,
    );
    _animals.add(saved);
    return saved;
  }

  @override
  Future<Animal?> findById(int id) async =>
      _animals.where((a) => a.id == id).firstOrNull;

  @override
  Future<Animal?> findByEarTag(EarTag earTag) async =>
      _animals.where((a) => a.earTag == earTag).firstOrNull;

  @override
  Future<List<Animal>> search(String text, {int limit = 30}) async {
    final found = _animals.where((a) => a.earTag.value.contains(text)).toList();
    found.sort((a, b) {
      final at = a.lastEvaluatedAt ?? DateTime(0);
      final bt = b.lastEvaluatedAt ?? DateTime(0);
      return bt.compareTo(at);
    });
    return found.take(limit).toList();
  }

  @override
  Future<void> markEvaluated(int id, DateTime at) async {
    final index = _animals.indexWhere((a) => a.id == id);
    final animal = _animals[index];
    _animals[index] = Animal(
      id: animal.id,
      uuid: animal.uuid,
      earTag: animal.earTag,
      breed: animal.breed,
      sex: animal.sex,
      createdAt: animal.createdAt,
      lastEvaluatedAt: at,
    );
  }
}

LivestockContextFacade _livestock() {
  final animals = _MemoryAnimals();
  return LivestockContextFacade(
    AnimalCommandService(animals),
    AnimalQueryService(animals),
  );
}

void main() {
  group('EarTag', () {
    test('spaces and case do not make a different tag', () {
      expect(EarTag(' pe 0012 '), EarTag('PE0012'));
    });

    test('an empty, too long or odd tag is rejected', () {
      expect(EarTag.validate(''), isNotNull);
      expect(EarTag.validate('A' * 21), isNotNull);
      expect(EarTag.validate('PE#12'), isNotNull);
      expect(EarTag.validate('PE-0012'), isNull);
    });
  });

  // HU15, scenario 1.
  test('a new animal is registered and can be found', () async {
    final livestock = _livestock();
    final animal = await livestock.registerAnimal(
      earTag: 'pe0012',
      breed: 'Holstein',
      sex: AnimalSex.female,
    );
    expect(animal.earTag, 'PE0012');
    expect(animal.details, 'Holstein · Hembra');
    expect((await livestock.searchAnimals('0012')).single.id, animal.id);
  });

  // HU15, scenario 4.
  test('a duplicate ear tag offers the existing animal', () async {
    final livestock = _livestock();
    final first = await livestock.registerAnimal(
      earTag: 'PE0012',
      breed: 'Holstein',
      sex: AnimalSex.female,
    );
    expect(
      () => livestock.registerAnimal(
        earTag: ' pe 0012',
        breed: 'Jersey',
        sex: AnimalSex.male,
      ),
      throwsA(
        isA<DuplicateAnimalException>().having(
          (e) => e.existing.id,
          'existing animal',
          first.id,
        ),
      ),
    );
  });

  // HU15, scenario 2: the last evaluated animal is listed first.
  test('the most recently evaluated animals come first', () async {
    final livestock = _livestock();
    final a = await livestock.registerAnimal(
      earTag: 'A1',
      breed: 'Holstein',
      sex: AnimalSex.female,
    );
    final b = await livestock.registerAnimal(
      earTag: 'B2',
      breed: 'Jersey',
      sex: AnimalSex.female,
    );
    await livestock.markEvaluated(a.id, DateTime(2026, 11, 1));
    await livestock.markEvaluated(b.id, DateTime(2026, 11, 5));

    final recent = await livestock.searchAnimals('');
    expect(recent.map((animal) => animal.earTag), ['B2', 'A1']);
  });
}
