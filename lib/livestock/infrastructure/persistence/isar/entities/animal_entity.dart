import 'package:isar_community/isar.dart';

import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../domain/model/valueobjects/animal_sex.dart';

part 'animal_entity.g.dart';

/// Isar collection `animals`: animals of the farm (HU15).
///
@Collection(accessor: 'animals')
@Name('animals')
class AnimalEntity {
  Id id = Isar.autoIncrement;

  /// Global id for the cloud sync.
  @Index(unique: true)
  late String uuid;

  /// Ear tag number, trimmed and in upper case. Unique per farm.
  @Index(unique: true, caseSensitive: false)
  late String earTag;

  late String breed;

  @Enumerated(EnumType.name)
  late AnimalSex sex;

  late DateTime createdAt;
  late DateTime updatedAt;

  /// Last time the animal was linked to an evaluation. The picker lists the
  /// most recent animals first, so one can be chosen in two taps (HU15).
  @Index()
  DateTime? lastEvaluatedAt;

  @Enumerated(EnumType.name)
  late SyncStatus syncStatus;
}
