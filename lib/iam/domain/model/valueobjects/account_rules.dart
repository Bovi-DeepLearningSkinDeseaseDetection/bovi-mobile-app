import 'dart:convert';

/// Rules of the account fields, the same the backend applies (HU14), so the
/// farmer sees the problem before sending the form.
class AccountRules {
  AccountRules._();

  static const nameMinLength = 2;
  static const nameMaxLength = 100;
  static const passwordMinLength = 8;

  /// bcrypt only reads the first 72 bytes of a password.
  static const passwordMaxBytes = 72;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Trimmed and in lower case, as the backend stores it.
  static String normalizeEmail(String text) => text.trim().toLowerCase();

  /// Inner spaces collapsed.
  static String normalizeName(String text) =>
      text.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).join(' ');

  /// Message for the user, or null when the name is valid.
  static String? validateName(String text) {
    final name = normalizeName(text);
    if (name.length < nameMinLength || name.length > nameMaxLength) {
      return 'Ingrese su nombre (entre $nameMinLength y $nameMaxLength '
          'caracteres).';
    }
    return null;
  }

  static String? validateEmail(String text) {
    final email = normalizeEmail(text);
    if (email.isEmpty) return 'Ingrese su correo electrónico.';
    if (email.length > 254 || !_email.hasMatch(email)) {
      return 'El correo electrónico no es válido.';
    }
    return null;
  }

  /// Only for a new password; signing in accepts whatever was saved before.
  static String? validateNewPassword(String text) {
    if (text.length < passwordMinLength) {
      return 'Use al menos $passwordMinLength caracteres.';
    }
    if (utf8.encode(text).length > passwordMaxBytes) {
      return 'La contraseña es demasiado larga.';
    }
    final hasLetter = RegExp(r'\p{L}', unicode: true).hasMatch(text);
    final hasDigit = RegExp(r'\d').hasMatch(text);
    if (!hasLetter || !hasDigit) {
      return 'Use al menos una letra y un número.';
    }
    return null;
  }
}
