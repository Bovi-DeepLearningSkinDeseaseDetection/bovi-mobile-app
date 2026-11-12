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

  /// Cloud account of the farmer who created it (HU12, HU14). Null for the
  /// records saved before the accounts existed: the first account that syncs
  /// takes them.
  final String? ownerId;

  /// Why the backend rejected it, when [syncStatus] is failed.
  final String? syncError;

  const Animal({
    this.id,
    required this.uuid,
    required this.earTag,
    required this.breed,
    required this.sex,
    required this.createdAt,
    this.lastEvaluatedAt,
    this.syncStatus = SyncStatus.pending,
    this.ownerId,
    this.syncError,
  });
}
