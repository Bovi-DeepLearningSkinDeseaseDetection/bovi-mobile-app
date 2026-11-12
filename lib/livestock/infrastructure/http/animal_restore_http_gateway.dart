import 'package:dio/dio.dart';

import '../../../shared/domain/model/remote_page.dart';
import '../../../shared/domain/model/sync_status.dart';
import '../../../shared/infrastructure/network/api_client.dart';
import '../../domain/model/aggregates/animal.dart';
import '../../domain/model/valueobjects/animal_sex.dart';
import '../../domain/model/valueobjects/ear_tag.dart';
import '../../domain/services/animal_restore_gateway.dart';

/// GET /api/v1/animals (B3).
class AnimalRestoreHttpGateway implements AnimalRestoreGateway {
  final Dio _dio;

  const AnimalRestoreHttpGateway(this._dio);

  @override
  Future<RemotePage<Animal>> fetchAnimals(
    String token, {
    String? cursor,
    int limit = 100,
  }) => callApi(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/animals',
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final body = response.data!;
    return RemotePage(
      [
        for (final item in body['items'] as List)
          _animal(item as Map<String, dynamic>),
      ],
      body['total'] as int,
      body['next_cursor'] as String?,
    );
  });

  static Animal _animal(Map<String, dynamic> json) => Animal(
    uuid: json['id'] as String,
    earTag: EarTag(json['ear_tag'] as String),
    breed: json['breed'] as String,
    sex: AnimalSex.values.byName(json['sex'] as String),
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    syncStatus: SyncStatus.synced,
  );
}
