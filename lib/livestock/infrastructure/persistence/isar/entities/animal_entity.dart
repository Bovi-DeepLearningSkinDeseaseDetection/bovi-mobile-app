import 'package:isar_community/isar.dart';

import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../domain/model/valueobjects/animal_sex.dart';

part 'animal_entity.g.dart';

/// Isar collection `animals`: animals of the farm (HU15).
///
/// Defined ahead of HU15 so the database layout is complete; nothing writes
/// to it yet.
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

  @Enumerated(EnumType.name)
  late SyncStatus syncStatus;
}
