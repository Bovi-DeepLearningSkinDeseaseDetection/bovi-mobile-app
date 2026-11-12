import '../../../../shared/domain/model/sync_status.dart';
import '../value_objects/body_zone.dart';
import '../value_objects/clinical_code.dart';
import '../value_objects/evaluation_outcome.dart';
import '../value_objects/inference_result.dart';
import '../value_objects/origin_image.dart';

/// One analyzed photo with its preliminary result, kept on the device (HU10).
class Evaluation {
  /// Local id; null until the evaluation is saved.
  final int? id;

  /// Global id, also the idempotency key for the cloud sync (RNF10).
  final String uuid;
  final DateTime createdAt;

  /// Absolute paths of the compressed photo and its thumbnail.
  final String imagePath;
  final String thumbnailPath;
  final ImageOrigin origin;

  /// Probabilities, model version and inference time (RNF17).
  final InferenceResult result;

  /// Standard codes of the result: MeSH for the disease and NCBI Taxonomy
  /// for its causal agent (HU07). Empty for healthy skin and inconclusive
  /// results.
  final List<ClinicalCode> clinicalCodes;

  /// Edition of the code catalog used, so old codes stay traceable.
  final String? catalogVersion;

  /// Animal and body zone, assigned from HU15 on.
  final int? animalId;
  final String? animalEarTag;
  final BodyZone? bodyZone;

  final SyncStatus syncStatus;

  /// Cloud account of the farmer who created it (HU12, HU14). Null for the
  /// records saved before the accounts existed: the first account that syncs
  /// takes them.
  final String? ownerId;

  /// Why the backend rejected it, when [syncStatus] is failed.
  final String? syncError;

  const Evaluation({
    this.id,
    required this.uuid,
    required this.createdAt,
    required this.imagePath,
    required this.thumbnailPath,
    required this.origin,
    required this.result,
    this.clinicalCodes = const [],
    this.catalogVersion,
    this.animalId,
    this.animalEarTag,
    this.bodyZone,
    this.syncStatus = SyncStatus.pending,
    this.ownerId,
    this.syncError,
  });

  EvaluationOutcome get outcome => EvaluationOutcome.of(result);
}
