import 'package:dio/dio.dart';

import '../../../shared/infrastructure/network/api_client.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/model/aggregates/auth_session.dart';
import '../../domain/model/commands/sign_up_command.dart';
import '../../domain/services/auth_gateway.dart';

/// /api/v1/auth of the backend (B1).
class AuthHttpGateway implements AuthGateway {
  final Dio _dio;
  final DateTime Function() _clock;

  AuthHttpGateway(this._dio, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  @override
  Future<AuthSession> signUp(SignUpCommand command) => _post('/auth/register', {
    'name': command.name,
    'email': command.email,
    'password': command.password,
    'consent_accepted': command.consentAccepted,
  });

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) => _post('/auth/login', {'email': email, 'password': password});

  @override
  Future<AuthSession> refresh(String refreshToken) =>
      _post('/auth/refresh', {'refresh_token': refreshToken});

  Future<AuthSession> _post(String path, Map<String, Object?> body) async {
    // Taken before the request, so the expiry is never later than the real one.
    final sentAt = _clock();
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return _session(response.data!, sentAt);
    } on DioException catch (error) {
      final failure = ApiFailure.of(error);
      throw AuthException(failure.code, failure.message);
    }
  }

  static AuthSession _session(Map<String, dynamic> json, DateTime sentAt) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthSession(
      farmer: Farmer(
        id: user['id'] as String,
        name: user['name'] as String,
        email: user['email'] as String,
      ),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessExpiresAt: sentAt.add(Duration(seconds: json['expires_in'] as int)),
      refreshExpiresAt: sentAt.add(
        Duration(seconds: json['refresh_expires_in'] as int),
      ),
    );
  }
}
