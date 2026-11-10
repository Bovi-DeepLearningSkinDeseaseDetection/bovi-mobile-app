import '../../../../shared/domain/model/sync_status.dart';
import '../valueobjects/animal_sex.dart';
import '../valueobjects/ear_tag.dart';

/// Animal of the farm, identified by its ear tag (HU15).
class Animal {
  /// Local id; null until the animal is saved.
  final int? id;

  /// Global id for the cloud sync.
  final String uuid;
  final EarTag earTag;
  final String breed;
  final AnimalSex sex;
  final DateTime createdAt;
  final DateTime? lastEvaluatedAt;
  final SyncStatus syncStatus;

  const Animal({
    this.id,
    required this.uuid,
    required this.earTag,
    required this.breed,
    required this.sex,
    required this.createdAt,
    this.lastEvaluatedAt,
    this.syncStatus = SyncStatus.pending,
  });
}
