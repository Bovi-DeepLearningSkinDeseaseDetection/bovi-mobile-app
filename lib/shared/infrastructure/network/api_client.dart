import 'package:dio/dio.dart';

import '../../domain/exceptions/network_unavailable_exception.dart';

/// Address of the backend, chosen when building the app:
///
///     flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
///     flutter build apk --dart-define=API_BASE_URL=https://api.bovi.pe
///
/// The default reaches a backend on the PC from the Android emulator.
class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get apiUrl => '$baseUrl/api/v1';
}

/// Error answered by the backend: `{code, message, details}`, with
/// [message] in Spanish for the farmer.
class ApiFailure {
  final int statusCode;
  final String code;
  final String message;

  const ApiFailure(this.statusCode, this.code, this.message);

  static const _fallback =
      'No se pudo completar la solicitud. Intente de nuevo.';

  /// Reads the error of the backend, or throws [NetworkUnavailableException]
  /// when the request never got an answer.
  factory ApiFailure.of(DioException error) {
    final response = error.response;
    if (response == null) throw const NetworkUnavailableException();
    final body = response.data;
    if (body is Map && body['code'] is String && body['message'] is String) {
      return ApiFailure(
        response.statusCode ?? 0,
        body['code'] as String,
        body['message'] as String,
      );
    }
    final status = response.statusCode ?? 0;
    // A proxy or a load balancer without the JSON format of the API.
    if (status >= 500) throw const NetworkUnavailableException();
    return ApiFailure(status, 'error_http', _fallback);
  }
}

/// The backend refused a request with its `{code, message}` error.
class ApiException implements Exception {
  final ApiFailure failure;

  const ApiException(this.failure);

  int get statusCode => failure.statusCode;
  String get code => failure.code;
  String get message => failure.message;

  /// The token is no longer accepted: the farmer must sign in again.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode ${failure.code})';
}

/// Runs a request to the backend translating its errors: [ApiException]
/// with the message of the backend, or NetworkUnavailableException.
Future<T> callApi<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw ApiException(ApiFailure.of(error));
  }
}

/// HTTP client of the backend: JSON over HTTPS (RNF5).
Dio createApiClient({String? baseUrl}) => Dio(
  BaseOptions(
    baseUrl: baseUrl ?? ApiConfig.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  ),
);
