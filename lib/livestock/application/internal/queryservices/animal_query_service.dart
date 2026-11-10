import '../../../domain/model/aggregates/animal.dart';
import '../../../domain/model/valueobjects/ear_tag.dart';
import '../../../domain/repositories/animal_repository.dart';

/// Finds the animals of the farm (HU15, scenario 2).
class AnimalQueryService {
  final AnimalRepository _repository;

  const AnimalQueryService(this._repository);

  /// Animals whose ear tag contains [text]; without text, the most recently
  /// evaluated ones.
  Future<List<Animal>> search(String text) =>
      _repository.search(EarTag.normalize(text));

  Future<Animal?> findById(int id) => _repository.findById(id);
}
