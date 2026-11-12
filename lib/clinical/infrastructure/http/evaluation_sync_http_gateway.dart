import 'package:dio/dio.dart';

import '../../../shared/domain/exceptions/network_unavailable_exception.dart';
import '../../../shared/domain/model/remote_sync_result.dart';
import '../../../shared/infrastructure/network/api_client.dart';
import '../../domain/model/value_objects/evaluation_outcome.dart';
import '../../domain/services/evaluation_sync_gateway.dart';

/// SyncHttpClient of the architecture: /media/upload-url and
/// /sync/evaluations of the backend (B2), and the upload of each photo
/// straight to S3 with the presigned POST, never through the backend (RNF18).
class EvaluationSyncHttpGateway implements EvaluationSyncGateway {
  final Dio _api;

  /// Without base URL nor JSON defaults: it only posts forms to S3.
  final Dio _storage;

  EvaluationSyncHttpGateway(this._api, [Dio? storage])
    : _storage =
          storage ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  static Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  @override
  Future<List<UploadTicket>> requestUploads(String token, List<String> ids) =>
      callApi(() async {
        final response = await _api.post<Map<String, dynamic>>(
          '/media/upload-url',
          data: {'evaluation_ids': ids},
          options: _auth(token),
        );
        return [
          for (final item in response.data!['items'] as List)
            _ticket(item as Map<String, dynamic>),
        ];
      });

  static UploadTicket _ticket(Map<String, dynamic> json) {
    final upload = json['upload'] as Map<String, dynamic>?;
    return UploadTicket(
      evaluationId: json['evaluation_id'] as String,
      status: switch (json['status'] as String) {
        'ready' => UploadTicketStatus.ready,
        'already_synced' => UploadTicketStatus.alreadySynced,
        _ => UploadTicketStatus.rejected,
      },
      url: upload?['url'] as String?,
      fields: {
        for (final entry
            in (upload?['fields'] as Map<String, dynamic>? ?? {}).entries)
          entry.key: entry.value as String,
      },
    );
  }

  @override
  Future<void> uploadPhoto(UploadTicket ticket, String filePath) async {
    // S3 reads the policy fields first and the file last; Dio writes the
    // fields before the files, in the order they were added.
    final form = FormData()
      ..fields.addAll(ticket.fields.entries)
      ..files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            filePath,
            filename: 'foto.jpg',
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ),
      );
    try {
      await _storage.post<void>(ticket.url!, data: form);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == null || status >= 500) {
        throw const NetworkUnavailableException();
      }
      // 403 = the presigned URL expired: a new one fixes it on the next run.
      if (status == 403) throw const NetworkUnavailableException();
      throw const PhotoRejectedException();
    }
  }

  @override
  Future<List<RemoteSyncResult>> sync(
    String token,
    List<EvaluationUpload> evaluations,
  ) => callApi(() async {
    final response = await _api.post<Map<String, dynamic>>(
      '/sync/evaluations',
      data: {'evaluations': evaluations.map(_toJson).toList()},
      options: _auth(token),
    );
    return [
      for (final item in response.data!['results'] as List)
        RemoteSyncResult.fromJson(item as Map<String, dynamic>),
    ];
  });

  static Map<String, Object?> _toJson(EvaluationUpload upload) {
    final e = upload.evaluation;
    final top = e.result.top;
    return {
      'id': e.uuid,
      // With its offset, so the backend knows the exact instant.
      'evaluated_at': e.createdAt.toUtc().toIso8601String(),
      'image_origin': e.origin.name,
      'probabilities': [
        for (final p in e.result.probabilities)
          {'label': p.label, 'probability': p.probability},
      ],
      'predicted_class': top.label,
      'confidence': top.probability,
      'outcome': switch (e.outcome) {
        EvaluationOutcome.healthy => 'healthy',
        EvaluationOutcome.lesion => 'lesion',
        EvaluationOutcome.inconclusive => 'inconclusive',
      },
      'clinical_codes': [
        for (final code in e.clinicalCodes)
          {'system': code.system, 'code': code.code, 'display': code.display},
      ],
      'catalog_version': e.catalogVersion,
      'model_version': e.result.modelVersion,
      'inference_ms': e.result.elapsed.inMilliseconds,
      'animal_id': upload.animalUuid,
      'body_zone': upload.animalUuid == null ? null : e.bodyZone?.name,
    };
  }
}
