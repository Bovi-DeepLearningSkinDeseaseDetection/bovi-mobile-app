import '../../application/internal/commandservices/animal_command_service.dart';
import '../../application/internal/queryservices/animal_query_service.dart';
import '../../domain/exceptions/duplicate_ear_tag_exception.dart';
import '../../domain/model/aggregates/animal.dart';
import '../../domain/model/valueobjects/animal_sex.dart';

/// What other bounded contexts may know about an animal.
class AnimalSummary {
  final int id;
  final String earTag;
  final String breed;
  final String sexLabel;

  const AnimalSummary({
    required this.id,
    required this.earTag,
    required this.breed,
    required this.sexLabel,
  });

  factory AnimalSummary.of(Animal animal) => AnimalSummary(
    id: animal.id!,
    earTag: animal.earTag.value,
    breed: animal.breed,
    sexLabel: animal.sex.label,
  );

  /// For example "Holstein · Hembra".
  String get details => '$breed · $sexLabel';
}

/// The animal with that ear tag already exists; [existing] can be selected.
class DuplicateAnimalException implements Exception {
  final AnimalSummary existing;

  const DuplicateAnimalException(this.existing);
}

/// Entry point of the livestock context for the other contexts (ACL). They
/// never use its domain directly, only these summaries.
class LivestockContextFacade {
  final AnimalCommandService _commands;
  final AnimalQueryService _queries;

  const LivestockContextFacade(this._commands, this._queries);

  Future<List<AnimalSummary>> searchAnimals(String earTag) async =>
      (await _queries.search(earTag)).map(AnimalSummary.of).toList();

  Future<AnimalSummary?> animalById(int id) async {
    final animal = await _queries.findById(id);
    return animal == null ? null : AnimalSummary.of(animal);
  }

  /// Throws [DuplicateAnimalException] when the ear tag is taken and
  /// [FormatException] when it is not valid.
  Future<AnimalSummary> registerAnimal({
    required String earTag,
    required String breed,
    required AnimalSex sex,
  }) async {
    try {
      final animal = await _commands.register(
        earTag: earTag,
        breed: breed,
        sex: sex,
      );
      return AnimalSummary.of(animal);
    } on DuplicateEarTagException catch (error) {
      throw DuplicateAnimalException(AnimalSummary.of(error.existing));
    }
  }

  Future<void> markEvaluated(int animalId, DateTime at) =>
      _commands.markEvaluated(animalId, at);
}
