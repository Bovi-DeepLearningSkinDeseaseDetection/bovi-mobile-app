import 'dart:convert';
import 'dart:typed_data';

import 'package:bov_mobile_app/iam/domain/exceptions/auth_exceptions.dart';
import 'package:bov_mobile_app/iam/domain/model/commands/sign_up_command.dart';
import 'package:bov_mobile_app/iam/infrastructure/http/auth_http_gateway.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with the given status and body, and records it.
class _Adapter implements HttpClientAdapter {
  final int status;
  final Object? body;
  final String contentType;
  final bool unreachable;
  RequestOptions? last;
  Object? lastBody;

  _Adapter(
    this.status,
    this.body, {
    this.contentType = 'application/json',
    this.unreachable = false,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    lastBody = options.data;
    if (unreachable) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Connection refused',
      );
    }
    final text = body is String ? body as String : jsonEncode(body);
    return ResponseBody.fromString(
      text,
      status,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _sessionBody = {
  'access_token': 'a.b.c',
  'refresh_token': 'r.s.t',
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_expires_in': 2592000,
  'user': {
    'id': '3f1c2a7e-9d4b-4c1a-8f00-000000000001',
    'name': 'Juan Pérez',
    'email': 'juan.perez@example.com',
  },
};

void main() {
  final sentAt = DateTime.utc(2026, 11, 12, 10);

  (AuthHttpGateway, _Adapter) gatewayAnswering(_Adapter adapter) {
    final dio = createApiClient(baseUrl: 'https://api.bovi.test/api/v1')
      ..httpClientAdapter = adapter;
    return (AuthHttpGateway(dio, clock: () => sentAt), adapter);
  }

  test('login sends the credentials and reads the session', () async {
    final (gateway, adapter) = gatewayAnswering(_Adapter(200, _sessionBody));

    final session = await gateway.signIn(
      email: 'juan.perez@example.com',
      password: 'establo2026',
    );

    expect(
      adapter.last!.uri.toString(),
      'https://api.bovi.test/api/v1/auth/login',
    );
    expect(adapter.lastBody, {
      'email': 'juan.perez@example.com',
      'password': 'establo2026',
    });
    expect(session.farmer.name, 'Juan Pérez');
    expect(session.accessExpiresAt, sentAt.add(const Duration(hours: 1)));
    expect(session.refreshExpiresAt, sentAt.add(const Duration(days: 30)));
  });

  test('register sends the consent', () async {
    final (gateway, adapter) = gatewayAnswering(_Adapter(201, _sessionBody));

    await gateway.signUp(
      const SignUpCommand(
        name: 'Juan Pérez',
        email: 'juan.perez@example.com',
        password: 'establo2026',
        consentAccepted: true,
      ),
    );

    expect(adapter.last!.path, '/auth/register');
    expect(adapter.lastBody, {
      'name': 'Juan Pérez',
      'email': 'juan.perez@example.com',
      'password': 'establo2026',
      'consent_accepted': true,
    });
  });

  test('refresh sends the refresh token', () async {
    final (gateway, adapter) = gatewayAnswering(_Adapter(200, _sessionBody));

    await gateway.refresh('r.s.t');

    expect(adapter.last!.path, '/auth/refresh');
    expect(adapter.lastBody, {'refresh_token': 'r.s.t'});
  });

  test('an error of the backend keeps its Spanish message', () async {
    final (gateway, _) = gatewayAnswering(
      _Adapter(401, {
        'code': 'credenciales_invalidas',
        'message': 'Correo o contraseña incorrectos',
        'details': [],
      }),
    );

    await expectLater(
      gateway.signIn(email: 'juan@example.com', password: 'mala1234'),
      throwsA(
        isA<AuthException>()
            .having((e) => e.code, 'code', 'credenciales_invalidas')
            .having(
              (e) => e.message,
              'message',
              'Correo o contraseña incorrectos',
            ),
      ),
    );
  });

  test('no answer at all means no connection', () async {
    final (gateway, _) = gatewayAnswering(_Adapter(0, null, unreachable: true));

    await expectLater(
      gateway.signIn(email: 'juan@example.com', password: 'x'),
      throwsA(isA<NetworkUnavailableException>()),
    );
  });

  test('a proxy page instead of the API is treated as no connection', () async {
    final (gateway, _) = gatewayAnswering(
      _Adapter(502, '<html>Bad Gateway</html>', contentType: 'text/html'),
    );

    await expectLater(
      gateway.refresh('r.s.t'),
      throwsA(isA<NetworkUnavailableException>()),
    );
  });

  test('the base URL of the API can be chosen at build time', () {
    expect(ApiConfig.apiUrl, endsWith('/api/v1'));
  });
}
