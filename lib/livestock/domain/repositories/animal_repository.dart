import '../model/aggregates/animal.dart';
import '../model/valueobjects/ear_tag.dart';

/// Local storage of the animals of the farm (HU15).
abstract class AnimalRepository {
  /// Saves the animal and returns it with its local id.
  Future<Animal> save(Animal animal);

  Future<Animal?> findById(int id);

  Future<Animal?> findByEarTag(EarTag earTag);

  /// Animals whose ear tag contains [text], most recently evaluated first.
  /// An empty [text] lists the most recent animals.
  Future<List<Animal>> search(String text, {int limit = 30});

  /// Records that the animal was linked to an evaluation at [at].
  Future<void> markEvaluated(int id, DateTime at);
}
