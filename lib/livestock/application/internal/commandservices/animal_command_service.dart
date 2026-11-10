import 'package:uuid/uuid.dart';

import '../../../domain/exceptions/duplicate_ear_tag_exception.dart';
import '../../../domain/model/aggregates/animal.dart';
import '../../../domain/model/valueobjects/animal_sex.dart';
import '../../../domain/model/valueobjects/ear_tag.dart';
import '../../../domain/repositories/animal_repository.dart';

/// Registers the animals of the farm (HU15).
class AnimalCommandService {
  final AnimalRepository _repository;

  const AnimalCommandService(this._repository);

  /// Saves a new animal. Throws [DuplicateEarTagException] with the
  /// registered animal when the ear tag already exists (scenario 4), and
  /// [FormatException] when the ear tag is not valid.
  Future<Animal> register({
    required String earTag,
    required String breed,
    required AnimalSex sex,
  }) async {
    final tag = EarTag(earTag);
    final existing = await _repository.findByEarTag(tag);
    if (existing != null) throw DuplicateEarTagException(existing);
    return _repository.save(
      Animal(
        uuid: const Uuid().v4(),
        earTag: tag,
        breed: breed.trim(),
        sex: sex,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> markEvaluated(int animalId, DateTime at) =>
      _repository.markEvaluated(animalId, at);
}
