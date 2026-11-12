import '../model/aggregates/auth_session.dart';

/// Where the session is kept on the phone (Android Keystore, RNF6).
abstract class SessionRepository {
  Future<AuthSession?> read();

  Future<void> save(AuthSession session);

  Future<void> clear();
}
