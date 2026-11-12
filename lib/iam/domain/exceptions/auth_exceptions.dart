/// The backend refused the request; [message] is in Spanish and is shown to
/// the farmer as it comes (for example "Correo o contraseña incorrectos").
class AuthException implements Exception {
  /// Stable code of the backend, for example `credenciales_invalidas`.
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  /// The session can no longer be renewed: the farmer must sign in again.
  bool get endsSession =>
      code == 'token_invalido' ||
      code == 'no_autenticado' ||
      code == 'cuenta_desactivada';

  @override
  String toString() => 'AuthException($code): $message';
}

/// There is no session, or it expired more than 30 days ago.
class SessionExpiredException implements Exception {
  static const message = 'Su sesión venció. Inicie sesión de nuevo.';

  const SessionExpiredException();

  @override
  String toString() => 'SessionExpiredException';
}
