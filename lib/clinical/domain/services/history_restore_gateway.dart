import 'dart:typed_data';

import '../../../shared/domain/model/remote_page.dart';
import '../model/value_objects/body_zone.dart';
import '../model/value_objects/clinical_code.dart';
import '../model/value_objects/inference_result.dart';
import '../model/value_objects/origin_image.dart';

/// An evaluation of the farmer as the cloud keeps it (HU13).
class RemoteEvaluation {
  final String id;
  final DateTime evaluatedAt;
  final ImageOrigin origin;
  final InferenceResult result;
  final List<ClinicalCode> clinicalCodes;
  final String? catalogVersion;

  /// Cloud uuid of the animal, already restored before the evaluations.
  final String? animalUuid;
  final BodyZone? bodyZone;

  /// Presigned GET of the photo, valid 15 minutes.
  final String imageUrl;

  const RemoteEvaluation({
    required this.id,
    required this.evaluatedAt,
    required this.origin,
    required this.result,
    required this.clinicalCodes,
    required this.catalogVersion,
    required this.animalUuid,
    required this.bodyZone,
    required this.imageUrl,
  });
}

/// The photo is no longer in S3. That evaluation is skipped and counted;
/// the restore goes on with the rest.
class PhotoMissingException implements Exception {
  const PhotoMissingException();
}

/// GET /api/v1/evaluations and the photos in S3 (HU13).
///
/// Throws ApiException (refused) or NetworkUnavailableException.
abstract class HistoryRestoreGateway {
  Future<RemotePage<RemoteEvaluation>> fetchEvaluations(
    String token, {
    String? cursor,
    int limit = 50,
  });

  /// Throws [PhotoMissingException] when S3 no longer has it.
  Future<Uint8List> downloadPhoto(String url);
}
