import 'package:isar_community/isar.dart';

import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../domain/model/value_objects/body_zone.dart';
import '../../../../domain/model/value_objects/evaluation_outcome.dart';
import '../../../../domain/model/value_objects/origin_image.dart';

part 'evaluation_entity.g.dart';

/// Isar collection `evaluations`: one analyzed photo and its result.
///
/// Enums are stored by name, so reordering their values never corrupts data.
@Collection(accessor: 'evaluations')
@Name('evaluations')
class EvaluationEntity {
  Id id = Isar.autoIncrement;

  /// Global id, also the idempotency key for the cloud sync (RNF10).
  @Index(unique: true)
  late String uuid;

  @Index()
  late DateTime createdAt;
  late DateTime updatedAt;

  /// File names inside the evaluations folder of the app documents.
  late String imageFile;
  late String thumbnailFile;

  @Enumerated(EnumType.name)
  late ImageOrigin origin;

  @Index()
  @Enumerated(EnumType.name)
  late EvaluationOutcome outcome;

  /// Most probable class, as written in `etiquetas.txt`.
  @Index()
  late String topLabel;
  late double confidence;

  /// Probability of every class of the model (RNF17).
  late List<ClassScoreEmbedded> probabilities;

  String? venomCode;
  late String modelVersion;
  late int inferenceMs;

  // Animal and body zone (HU15). The ear tag is copied so the history can
  // filter and show it without reading the animals collection.
  @Index()
  int? animalId;
  @Index()
  String? animalEarTag;
  @Enumerated(EnumType.name)
  BodyZone? bodyZone;

  // Cloud sync (HU12).
  @Index()
  @Enumerated(EnumType.name)
  late SyncStatus syncStatus;
  DateTime? syncedAt;
}

/// Probability that the model assigned to one class.
@embedded
class ClassScoreEmbedded {
  String label = '';
  double probability = 0;
}
