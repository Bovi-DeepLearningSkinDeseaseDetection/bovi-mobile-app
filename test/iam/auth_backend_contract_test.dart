// Contract with the real backend (bovi-backend, B1). Skipped unless
// BOVI_API_URL is set, for example with the backend of docker-compose:
//
//   BOVI_API_URL=http://localhost:8000 flutter test test/iam/auth_backend_contract_test.dart
import 'dart:io';
import 'dart:math';

import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/domain/exceptions/auth_exceptions.dart';
import 'package:bov_mobile_app/iam/domain/model/commands/sign_up_command.dart';
import 'package:bov_mobile_app/iam/infrastructure/http/auth_http_gateway.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'iam_fakes.dart';

void main() {
  final baseUrl = Platform.environment['BOVI_API_URL'];
  final skip = baseUrl == null ? 'BOVI_API_URL no está definida' : null;

  late AuthHttpGateway gateway;
  late MemorySessionRepository sessions;
  late AuthCommandService auth;
  final email = 'app-${Random().nextInt(1 << 32)}@bovi.test';

  setUp(() {
    gateway = AuthHttpGateway(createApiClient(baseUrl: '$baseUrl/api/v1'));
    sessions = MemorySessionRepository();
    auth = AuthCommandService(gateway, sessions);
  });

  test('sign up, sign in, wrong password and refresh', () async {
    final created = await auth.signUp(
      SignUpCommand(
        name: 'Ganadero  de la app',
        email: email.toUpperCase(),
        password: 'establo2026',
        consentAccepted: true,
      ),
    );
    expect(created.farmer.email, email);
    expect(created.farmer.name, 'Ganadero de la app');

    final signedIn = await auth.signIn(email: email, password: 'establo2026');
    expect(signedIn.farmer.id, created.farmer.id);
    expect(
      signedIn.refreshExpiresAt.difference(DateTime.now()).inDays,
      inInclusiveRange(29, 30),
    );

    await expectLater(
      auth.signIn(email: email, password: 'otraClave99'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Correo o contraseña incorrectos',
        ),
      ),
    );

    final renewed = await gateway.refresh(signedIn.refreshToken);
    expect(renewed.accessToken, isNot(signedIn.accessToken));
  }, skip: skip);

  test('a taken e-mail and the missing consent come back in Spanish', () async {
    await expectLater(
      gateway.signUp(
        SignUpCommand(
          name: 'Otro',
          email: email,
          password: 'establo2026',
          consentAccepted: true,
        ),
      ),
      throwsA(
        isA<AuthException>().having((e) => e.code, 'code', 'correo_registrado'),
      ),
    );
    await expectLater(
      gateway.signUp(
        const SignUpCommand(
          name: 'Sin consentimiento',
          email: 'sin-consentimiento@bovi.test',
          password: 'establo2026',
          consentAccepted: false,
        ),
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          'consentimiento_requerido',
        ),
      ),
    );
  }, skip: skip);
}
