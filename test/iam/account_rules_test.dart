import 'package:bov_mobile_app/iam/domain/model/aggregates/auth_session.dart';
import 'package:bov_mobile_app/iam/domain/model/valueobjects/account_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'iam_fakes.dart';

void main() {
  group('Rules of the account (same as the backend)', () {
    test('the e-mail is trimmed and in lower case', () {
      expect(
        AccountRules.normalizeEmail('  Juan.Perez@Example.COM '),
        'juan.perez@example.com',
      );
      expect(AccountRules.validateEmail('  Juan@Example.com '), isNull);
    });

    test('an invalid e-mail is reported in Spanish', () {
      expect(AccountRules.validateEmail(''), 'Ingrese su correo electrónico.');
      for (final email in ['juan', 'juan@', '@x.com', 'ju an@x.com']) {
        expect(
          AccountRules.validateEmail(email),
          'El correo electrónico no es válido.',
          reason: email,
        );
      }
    });

    test('a new password needs 8 characters, a letter and a number', () {
      expect(AccountRules.validateNewPassword('establo2026'), isNull);
      expect(AccountRules.validateNewPassword('ñandú2026'), isNull);
      expect(
        AccountRules.validateNewPassword('abc12'),
        'Use al menos 8 caracteres.',
      );
      expect(
        AccountRules.validateNewPassword('soloLetras'),
        'Use al menos una letra y un número.',
      );
      expect(
        AccountRules.validateNewPassword('12345678'),
        'Use al menos una letra y un número.',
      );
      expect(
        AccountRules.validateNewPassword('a1${'x' * 80}'),
        'La contraseña es demasiado larga.',
      );
    });

    test('the name collapses its spaces', () {
      expect(AccountRules.normalizeName('  Juan   Pérez '), 'Juan Pérez');
      expect(AccountRules.validateName(' J '), isNotNull);
      expect(AccountRules.validateName('Juan Pérez'), isNull);
    });
  });

  group('Session', () {
    test('the access token is renewed a minute before it expires', () {
      expect(session().hasValidAccess(now), isTrue);
      expect(
        session(accessLeft: const Duration(seconds: 30)).hasValidAccess(now),
        isFalse,
      );
    });

    // RF12: without internet the farmer keeps working up to 30 days.
    test('the session works offline while the refresh token lasts', () {
      expect(
        session(accessLeft: const Duration(hours: -5)).isActive(now),
        isTrue,
      );
      expect(
        session(refreshLeft: const Duration(seconds: -1)).isActive(now),
        isFalse,
      );
    });

    test('the session survives a round trip to storage', () {
      final restored = AuthSession.fromJson(session().toJson());

      expect(restored.farmer.email, farmer.email);
      expect(restored.accessToken, 'access-1');
      expect(restored.refreshExpiresAt, session().refreshExpiresAt);
    });
  });
}
