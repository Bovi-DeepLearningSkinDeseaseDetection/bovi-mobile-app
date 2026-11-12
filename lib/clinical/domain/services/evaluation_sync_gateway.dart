import '../../../shared/domain/model/remote_sync_result.dart';
import '../model/aggregates/evaluation.dart';

/// Answer of /media/upload-url for one evaluation.
enum UploadTicketStatus { ready, alreadySynced, rejected }

/// Presigned POST to upload the photo of one evaluation straight to S3.
class UploadTicket {
  final String evaluationId;
  final UploadTicketStatus status;
  final String? url;

  /// Form fields, in the order S3 expects them; the photo goes last.
  final Map<String, String> fields;

  const UploadTicket({
    required this.evaluationId,
    required this.status,
    this.url,
    this.fields = const {},
  });
}

/// One evaluation ready to send, with the cloud id of its animal.
class EvaluationUpload {
  final Evaluation evaluation;
  final String? animalUuid;

  const EvaluationUpload(this.evaluation, this.animalUuid);
}

/// S3 refused the photo (too big or not a JPEG): retrying will not help.
class PhotoRejectedException implements Exception {
  static const message =
      'La foto no se pudo respaldar: excede el tamaño permitido o no es JPEG.';

  const PhotoRejectedException();

  @override
  String toString() => 'PhotoRejectedException';
}

/// The backend and S3 for the evaluations (HU12, RNF18).
///
/// Throws ApiException (refused by the backend) or
/// NetworkUnavailableException.
abstract class EvaluationSyncGateway {
  /// At most [maxBatch] evaluations per call.
  static const maxBatch = 20;

  Future<List<UploadTicket>> requestUploads(String token, List<String> ids);

  /// Throws [PhotoRejectedException] when S3 refuses the file.
  Future<void> uploadPhoto(UploadTicket ticket, String filePath);

  Future<List<RemoteSyncResult>> sync(
    String token,
    List<EvaluationUpload> evaluations,
  );
}
