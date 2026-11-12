import '../model/aggregates/auth_session.dart';
import '../model/commands/sign_up_command.dart';

/// The account service of the backend (/api/v1/auth).
///
/// Throws [AuthException] when the backend refuses the request and
/// [NetworkUnavailableException] when it cannot be reached.
abstract class AuthGateway {
  Future<AuthSession> signUp(SignUpCommand command);

  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> refresh(String refreshToken);
}
