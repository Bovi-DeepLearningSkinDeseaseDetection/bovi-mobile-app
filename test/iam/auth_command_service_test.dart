import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/domain/exceptions/auth_exceptions.dart';
import 'package:bov_mobile_app/iam/domain/model/commands/sign_up_command.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import 'iam_fakes.dart';

void main() {
  late FakeAuthGateway gateway;
  late MemorySessionRepository sessions;
  late AuthCommandService auth;

  setUp(() {
    gateway = FakeAuthGateway();
    sessions = MemorySessionRepository();
    auth = AuthCommandService(gateway, sessions, clock: () => now);
  });

  SignUpCommand signUp({bool consent = true}) => SignUpCommand(
    name: '  Juan   Pérez ',
    email: ' Juan.Perez@Example.com',
    password: 'establo2026',
    consentAccepted: consent,
  );

  // HU14, scenario 1.
  test('signing up keeps the session at once', () async {
    await auth.signUp(signUp());

    expect(sessions.stored!.accessToken, 'access-signup');
    expect(gateway.lastSignUp!.name, 'Juan Pérez');
    expect(gateway.lastSignUp!.email, 'juan.perez@example.com');
  });

  // RNF7: nothing leaves the phone without the consent.
  test('without the consent nothing is sent', () async {
    await expectLater(
      auth.signUp(signUp(consent: false)),
      throwsA(
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          'consentimiento_requerido',
        ),
      ),
    );
    expect(gateway.calls, isEmpty);
    expect(sessions.stored, isNull);
  });

  // HU14, scenario 2.
  test('signing in keeps the session', () async {
    await auth.signIn(email: ' JUAN.perez@example.com ', password: 'x');

    expect(gateway.lastEmail, 'juan.perez@example.com');
    expect(sessions.stored!.accessToken, 'access-login');
  });

  // HU14, scenario 3.
  test('wrong credentials keep the farmer signed out', () async {
    gateway.failure = wrongCredentials;

    await expectLater(
      auth.signIn(email: 'juan@example.com', password: 'mala1234'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Correo o contraseña incorrectos',
        ),
      ),
    );
    expect(sessions.stored, isNull);
  });

  // HU14, scenario 4.
  test('a saved session opens without internet for 30 days', () async {
    sessions.stored = session(accessLeft: const Duration(days: -10));
    gateway.failure = offline;

    expect(await auth.activeSession(), isNotNull);
    expect(gateway.calls, isEmpty);
  });

  test('a session older than 30 days is removed', () async {
    sessions.stored = session(refreshLeft: const Duration(minutes: -1));

    expect(await auth.activeSession(), isNull);
    expect(sessions.stored, isNull);
  });

  group('Access token for the sync (HU12)', () {
    test('a valid token is used as is', () async {
      sessions.stored = session();

      expect(await auth.validAccessToken(), 'access-1');
      expect(gateway.calls, isEmpty);
    });

    test('an expired token is renewed and saved', () async {
      sessions.stored = session(accessLeft: const Duration(minutes: -5));

      expect(await auth.validAccessToken(), 'access-refreshed-1');
      expect(sessions.stored!.accessToken, 'access-refreshed-1');
    });

    test('several calls at once renew the token only once', () async {
      sessions.stored = session(accessLeft: const Duration(minutes: -5));

      final tokens = await Future.wait([
        auth.validAccessToken(),
        auth.validAccessToken(),
        auth.validAccessToken(),
      ]);

      expect(tokens.toSet(), {'access-refreshed-1'});
      expect(gateway.refreshes, 1);
    });

    test('without internet the session stays for a later retry', () async {
      sessions.stored = session(accessLeft: const Duration(minutes: -5));
      gateway.failure = offline;

      await expectLater(
        auth.validAccessToken(),
        throwsA(isA<NetworkUnavailableException>()),
      );
      expect(sessions.stored, isNotNull);
    });

    test('a revoked session asks to sign in again', () async {
      sessions.stored = session(accessLeft: const Duration(minutes: -5));
      gateway.failure = revokedToken;

      await expectLater(
        auth.validAccessToken(),
        throwsA(isA<SessionExpiredException>()),
      );
      expect(sessions.stored, isNull);
    });

    test('without a session there is no token', () async {
      await expectLater(
        auth.validAccessToken(),
        throwsA(isA<SessionExpiredException>()),
      );
    });
  });

  test('signing out removes the session', () async {
    sessions.stored = session();

    await auth.signOut();

    expect(sessions.stored, isNull);
  });
}
