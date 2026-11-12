import '../../../domain/exceptions/auth_exceptions.dart';
import '../../../domain/model/aggregates/auth_session.dart';
import '../../../domain/model/commands/sign_up_command.dart';
import '../../../domain/model/valueobjects/account_rules.dart';
import '../../../domain/repositories/session_repository.dart';
import '../../../domain/services/auth_gateway.dart';

/// Account and session of the farmer on this phone (HU14, RF12).
class AuthCommandService {
  static const consentRequired = AuthException(
    'consentimiento_requerido',
    'Debe aceptar el consentimiento de tratamiento de datos para crear su '
        'cuenta.',
  );

  final AuthGateway _gateway;
  final SessionRepository _sessions;
  final DateTime Function() _clock;
  Future<String>? _refreshing;

  AuthCommandService(
    this._gateway,
    this._sessions, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// The saved session if it is still active; it needs no internet
  /// (scenario 4). An expired one is removed.
  Future<AuthSession?> activeSession() async =>
      (await restoreSession()).session;

  /// Like [activeSession], and also tells whether a saved session had
  /// expired, so the farmer is told why they must sign in again.
  Future<({AuthSession? session, bool expired})> restoreSession() async {
    final session = await _sessions.read();
    if (session == null) return (session: null, expired: false);
    if (session.isActive(_clock())) return (session: session, expired: false);
    await _sessions.clear();
    return (session: null, expired: true);
  }

  /// Scenario 1: creates the account and keeps the session at once.
  Future<AuthSession> signUp(SignUpCommand command) async {
    // Ley N.° 29733: nothing is sent without the consent (RNF7).
    if (!command.consentAccepted) throw consentRequired;
    final session = await _gateway.signUp(
      SignUpCommand(
        name: AccountRules.normalizeName(command.name),
        email: AccountRules.normalizeEmail(command.email),
        password: command.password,
        consentAccepted: true,
      ),
    );
    await _sessions.save(session);
    return session;
  }

  /// Scenarios 2 and 3. Throws [AuthException] with the message of the
  /// backend ("Correo o contraseña incorrectos").
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _gateway.signIn(
      email: AccountRules.normalizeEmail(email),
      password: password,
    );
    await _sessions.save(session);
    return session;
  }

  Future<void> signOut() => _sessions.clear();

  /// Access token to call the backend (HU12, HU13), renewed when needed.
  ///
  /// Throws [SessionExpiredException] when the farmer must sign in again,
  /// and [NetworkUnavailableException] when the token needed renewing but
  /// there is no connection (the session stays: it is retried later).
  Future<String> validAccessToken() async {
    final session = await activeSession();
    if (session == null) throw const SessionExpiredException();
    if (session.hasValidAccess(_clock())) return session.accessToken;
    // Several calls at once renew the token only once.
    return _refreshing ??= _refresh(
      session,
    ).whenComplete(() => _refreshing = null);
  }

  Future<String> _refresh(AuthSession session) async {
    try {
      final renewed = await _gateway.refresh(session.refreshToken);
      await _sessions.save(renewed);
      return renewed.accessToken;
    } on AuthException catch (error) {
      if (!error.endsSession) rethrow;
      await _sessions.clear();
      throw const SessionExpiredException();
    }
  }
}
