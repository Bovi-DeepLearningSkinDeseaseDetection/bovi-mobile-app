import 'package:flutter/foundation.dart';

import '../../../../shared/domain/exceptions/network_unavailable_exception.dart';
import '../../../application/internal/commandservices/auth_command_service.dart';
import '../../../domain/exceptions/auth_exceptions.dart';
import '../../../domain/model/aggregates/auth_session.dart';
import '../../../domain/model/commands/sign_up_command.dart';

enum SessionStatus { loading, signedOut, signedIn }

/// Who is using the app: decides between the sign in and the main screens.
class SessionViewModel extends ChangeNotifier {
  static const offlineSignIn =
      'No se pudo conectar con el servidor de Bovi. Revise su internet: para '
      'ingresar por primera vez en este celular necesita conexión.';

  final AuthCommandService _auth;

  SessionStatus _status = SessionStatus.loading;
  Farmer? _farmer;
  String? _notice;

  SessionViewModel(this._auth);

  SessionStatus get status => _status;
  Farmer? get farmer => _farmer;

  /// Message for the sign in screen, for example an expired session.
  String? get notice => _notice;

  /// Opens the app with the saved session, without internet (scenario 4).
  Future<void> load() async {
    final (:session, :expired) = await _auth.restoreSession();
    if (session == null) {
      _signOutLocally(expired ? SessionExpiredException.message : null);
      return;
    }
    _signInLocally(session);
    // With internet, renew the access token now; without it, nothing changes.
    try {
      await _auth.validAccessToken();
    } on SessionExpiredException {
      _signOutLocally(SessionExpiredException.message);
    } on NetworkUnavailableException {
      // Offline: the session stays.
    } on AuthException {
      // A transient answer of the backend: retried on the next call.
    }
  }

  /// Null when it worked; otherwise the message for the farmer.
  Future<String?> signIn(String email, String password) =>
      _run(() => _auth.signIn(email: email, password: password));

  Future<String?> signUp(SignUpCommand command) =>
      _run(() => _auth.signUp(command));

  Future<void> signOut() async {
    await _auth.signOut();
    _signOutLocally(null);
  }

  Future<String?> _run(Future<AuthSession> Function() action) async {
    try {
      _signInLocally(await action());
      return null;
    } on AuthException catch (error) {
      return error.message;
    } on NetworkUnavailableException {
      return offlineSignIn;
    }
  }

  void _signInLocally(AuthSession session) {
    _farmer = session.farmer;
    _notice = null;
    _status = SessionStatus.signedIn;
    notifyListeners();
  }

  void _signOutLocally(String? notice) {
    _farmer = null;
    _notice = notice;
    _status = SessionStatus.signedOut;
    notifyListeners();
  }
}
