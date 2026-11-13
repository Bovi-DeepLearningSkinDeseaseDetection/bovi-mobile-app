import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../shared/domain/exceptions/network_unavailable_exception.dart';
import '../../../shared/domain/model/remote_page.dart';
import '../../../shared/infrastructure/network/api_client.dart';
import '../../domain/model/value_objects/body_zone.dart';
import '../../domain/model/value_objects/clinical_code.dart';
import '../../domain/model/value_objects/inference_result.dart';
import '../../domain/model/value_objects/origin_image.dart';
import '../../domain/services/history_restore_gateway.dart';

/// GET /api/v1/evaluations (B3) and the download of each photo straight
/// from S3 with its presigned URL.
class HistoryRestoreHttpGateway implements HistoryRestoreGateway {
  final Dio _api;
  final Dio _storage;

  HistoryRestoreHttpGateway(this._api, [Dio? storage])
    : _storage =
          storage ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  @override
  Future<RemotePage<RemoteEvaluation>> fetchEvaluations(
    String token, {
    String? cursor,
    int limit = 50,
  }) => callApi(() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/evaluations',
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final body = response.data!;
    return RemotePage(
      [
        for (final item in body['items'] as List)
          _evaluation(item as Map<String, dynamic>),
      ],
      body['total'] as int,
      body['next_cursor'] as String?,
    );
  });

  @override
  Future<Uint8List> downloadPhoto(String url) async {
    try {
      final response = await _storage.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404) throw const PhotoMissingException();
      // No answer, a server error or an expired URL (403): retried later.
      throw const NetworkUnavailableException();
    }
  }

  static RemoteEvaluation _evaluation(Map<String, dynamic> json) {
    final zone = json['body_zone'] as String?;
    return RemoteEvaluation(
      id: json['id'] as String,
      evaluatedAt: DateTime.parse(json['evaluated_at'] as String).toLocal(),
      origin: ImageOrigin.values.byName(json['image_origin'] as String),
      result: InferenceResult(
        probabilities: [
          for (final p in json['probabilities'] as List)
            ClassProbability(
              (p as Map<String, dynamic>)['label'] as String,
              (p['probability'] as num).toDouble(),
            ),
        ],
        modelVersion: json['model_version'] as String,
        elapsed: Duration(milliseconds: json['inference_ms'] as int? ?? 0),
      ),
      clinicalCodes: [
        for (final c in json['clinical_codes'] as List)
          ClinicalCode.fromJson(c as Map<String, dynamic>),
      ],
      catalogVersion: json['catalog_version'] as String?,
      animalUuid: json['animal_id'] as String?,
      bodyZone: zone == null ? null : BodyZone.values.byName(zone),
      imageUrl: json['image_url'] as String,
    );
  }
}
