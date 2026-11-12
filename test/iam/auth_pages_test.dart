import 'package:bov_mobile_app/iam/application/internal/commandservices/auth_command_service.dart';
import 'package:bov_mobile_app/iam/domain/exceptions/auth_exceptions.dart';
import 'package:bov_mobile_app/iam/interfaces/ui/pages/auth_gate.dart';
import 'package:bov_mobile_app/iam/interfaces/ui/pages/profile_page.dart';
import 'package:bov_mobile_app/iam/interfaces/ui/pages/sign_in_page.dart';
import 'package:bov_mobile_app/iam/interfaces/ui/pages/sign_up_page.dart';
import 'package:bov_mobile_app/iam/interfaces/ui/viewmodels/session_view_model.dart';
import 'package:bov_mobile_app/iam/interfaces/ui/widgets/consent_sheet.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'iam_fakes.dart';

const _app = 'Pantalla principal';

void main() {
  late FakeAuthGateway gateway;
  late MemorySessionRepository sessions;

  setUp(() {
    gateway = FakeAuthGateway();
    sessions = MemorySessionRepository();
  });

  Future<void> pumpApp(WidgetTester tester, {Widget? signedIn}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final auth = AuthCommandService(gateway, sessions, clock: () => now);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SessionViewModel(auth)..load(),
        child: MaterialApp(
          theme: AppTheme.light,
          home: AuthGate(child: signedIn ?? const Scaffold(body: Text(_app))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillSignIn(WidgetTester tester, String password) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'juan.perez@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      password,
    );
    await tester.tap(find.text(SignInPage.submitLabel));
    await tester.pumpAndSettle();
  }

  testWidgets('without a session the sign in is shown', (tester) async {
    await pumpApp(tester);

    expect(find.text(SignInPage.title), findsOneWidget);
    expect(find.text(_app), findsNothing);
  });

  // HU14, scenario 2.
  testWidgets('correct credentials open the app', (tester) async {
    await pumpApp(tester);

    await fillSignIn(tester, 'establo2026');

    expect(find.text(_app), findsOneWidget);
    expect(sessions.stored, isNotNull);
  });

  // HU14, scenario 3.
  testWidgets('wrong credentials show the message and do not enter', (
    tester,
  ) async {
    gateway.failure = wrongCredentials;
    await pumpApp(tester);

    await fillSignIn(tester, 'mala1234');

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.text(_app), findsNothing);
  });

  testWidgets('the fields are checked before sending', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(SignInPage.submitLabel));
    await tester.pumpAndSettle();

    expect(find.text('Ingrese su correo electrónico.'), findsOneWidget);
    expect(find.text('Ingrese su contraseña.'), findsOneWidget);
    expect(gateway.calls, isEmpty);
  });

  testWidgets('signing in for the first time needs internet', (tester) async {
    gateway.failure = offline;
    await pumpApp(tester);

    await fillSignIn(tester, 'establo2026');

    expect(find.text(SessionViewModel.offlineSignIn), findsOneWidget);
  });

  // HU14, scenario 4.
  testWidgets('a saved session opens the app without internet', (tester) async {
    sessions.stored = session(accessLeft: const Duration(days: -20));
    gateway.failure = offline;

    await pumpApp(tester);

    expect(find.text(_app), findsOneWidget);
    expect(sessions.stored, isNotNull);
  });

  testWidgets('a session older than 30 days asks to sign in again', (
    tester,
  ) async {
    sessions.stored = session(refreshLeft: const Duration(days: -1));

    await pumpApp(tester);

    expect(find.text(SignInPage.title), findsOneWidget);
    expect(find.text(SessionExpiredException.message), findsOneWidget);
  });

  testWidgets('a revoked session goes back to the sign in', (tester) async {
    sessions.stored = session(accessLeft: const Duration(minutes: -5));
    gateway.failure = revokedToken;

    await pumpApp(tester);

    expect(find.text(SignInPage.title), findsOneWidget);
    expect(find.text(SessionExpiredException.message), findsOneWidget);
  });

  group('Sign up (HU14, scenario 1)', () {
    Future<void> fillSignUp(WidgetTester tester) async {
      await tester.tap(find.text(SignInPage.signUpLabel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre completo'),
        'Juan Pérez',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        'juan.perez@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'establo2026',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repita la contraseña'),
        'establo2026',
      );
    }

    Future<void> submit(WidgetTester tester) async {
      final button = find.widgetWithText(FilledButton, SignUpPage.submitLabel);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('without the consent the account is not created', (
      tester,
    ) async {
      await pumpApp(tester);
      await fillSignUp(tester);

      await submit(tester);

      expect(find.text(SignUpPage.consentMissing), findsOneWidget);
      expect(gateway.calls, isEmpty);
    });

    testWidgets('reading and accepting the consent creates the account', (
      tester,
    ) async {
      await pumpApp(tester);
      await fillSignUp(tester);

      final link = find.textContaining(
        'consentimiento de tratamiento',
        findRichText: true,
      );
      await tester.ensureVisible(link);
      await tester.tapOnText(
        find.textRange.ofSubstring('consentimiento de tratamiento de datos'),
      );
      await tester.pumpAndSettle();
      expect(find.text(ConsentText.title), findsOneWidget);
      // The international transfer is told before accepting (Ley N.° 29733).
      await tester.scrollUntilVisible(
        find.text('Dónde se guardan'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining('São Paulo, Brasil'), findsOneWidget);
      await tester.tap(find.text('Acepto'));
      await tester.pumpAndSettle();
      await submit(tester);

      expect(find.text(_app), findsOneWidget);
      expect(gateway.lastSignUp!.consentAccepted, isTrue);
      expect(sessions.stored!.accessToken, 'access-signup');
    });

    testWidgets('different passwords are reported', (tester) async {
      await pumpApp(tester);
      await fillSignUp(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repita la contraseña'),
        'otra2026',
      );

      await submit(tester);

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });

    testWidgets('a taken e-mail shows the message of the backend', (
      tester,
    ) async {
      gateway.failure = const AuthException(
        'correo_registrado',
        'Ya existe una cuenta con este correo. Inicie sesión.',
      );
      await pumpApp(tester);
      await fillSignUp(tester);
      await tester.tap(find.byType(Checkbox));

      await submit(tester);

      expect(
        find.text('Ya existe una cuenta con este correo. Inicie sesión.'),
        findsOneWidget,
      );
      expect(find.text(_app), findsNothing);
    });
  });

  group('Profile', () {
    testWidgets('shows the farmer and signs out', (tester) async {
      sessions.stored = session();
      await pumpApp(tester, signedIn: const ProfilePage());

      expect(find.text(farmer.name), findsOneWidget);
      expect(find.text(farmer.email), findsOneWidget);

      await tester.tap(find.text(ProfilePage.signOutLabel));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, ProfilePage.signOutLabel),
      );
      await tester.pumpAndSettle();

      expect(find.text(SignInPage.title), findsOneWidget);
      expect(sessions.stored, isNull);
    });
  });
}
