import 'package:dio/dio.dart';

import '../../../shared/domain/model/remote_sync_result.dart';
import '../../../shared/infrastructure/network/api_client.dart';
import '../../domain/model/aggregates/animal.dart';
import '../../domain/services/animal_sync_gateway.dart';

/// /api/v1/sync/animals (B2). The enum names of the app are the values of
/// the API (`female`, `male`).
class AnimalSyncHttpGateway implements AnimalSyncGateway {
  final Dio _dio;

  const AnimalSyncHttpGateway(this._dio);

  @override
  Future<List<RemoteSyncResult>> sync(String token, List<Animal> animals) =>
      callApi(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          '/sync/animals',
          data: {
            'animals': [
              for (final animal in animals)
                {
                  'id': animal.uuid,
                  'ear_tag': animal.earTag.value,
                  'breed': animal.breed,
                  'sex': animal.sex.name,
                  'created_at': animal.createdAt.toUtc().toIso8601String(),
                },
            ],
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        return [
          for (final item in response.data!['results'] as List)
            RemoteSyncResult.fromJson(item as Map<String, dynamic>),
        ];
      });
}
