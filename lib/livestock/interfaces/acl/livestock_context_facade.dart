import '../../../shared/domain/model/sync_status.dart';
import '../../application/internal/commandservices/animal_command_service.dart';
import '../../application/internal/commandservices/animal_restore_service.dart';
import '../../application/internal/commandservices/animal_sync_service.dart';
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
  final AnimalSyncService? _sync;
  final AnimalRestoreService? _restore;

  const LivestockContextFacade(
    this._commands,
    this._queries, [
    this._sync,
    this._restore,
  ]);

  /// Brings the farmer's animals back from the cloud (HU13), by cloud uuid.
  Future<Map<String, AnimalSummary>> restoreAnimals({
    required String ownerId,
    required String token,
  }) async {
    final restored =
        await _restore?.restoreAll(ownerId: ownerId, token: token) ?? const {};
    return {
      for (final entry in restored.entries)
        entry.key: AnimalSummary.of(entry.value),
    };
  }

  /// Backs up the pending animals of the farmer (HU12). Returns how many
  /// were synced; network and session errors reach the caller.
  Future<int> syncPendingAnimals({
    required String ownerId,
    required String token,
  }) async => await _sync?.syncPending(ownerId: ownerId, token: token) ?? 0;

  /// Cloud id of the animal, or null while it is not in the cloud yet: an
  /// evaluation that points to it has to wait.
  Future<String?> syncedAnimalUuid(int id) async {
    final animal = await _queries.findById(id);
    return animal?.syncStatus == SyncStatus.synced ? animal!.uuid : null;
  }

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
