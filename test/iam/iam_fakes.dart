import 'package:bov_mobile_app/iam/domain/exceptions/auth_exceptions.dart';
import 'package:bov_mobile_app/iam/domain/model/aggregates/auth_session.dart';
import 'package:bov_mobile_app/iam/domain/model/commands/sign_up_command.dart';
import 'package:bov_mobile_app/iam/domain/repositories/session_repository.dart';
import 'package:bov_mobile_app/iam/domain/services/auth_gateway.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';

final now = DateTime.utc(2026, 11, 12, 10);

const farmer = Farmer(
  id: '3f1c2a7e-9d4b-4c1a-8f00-000000000001',
  name: 'Juan Pérez',
  email: 'juan.perez@example.com',
);

AuthSession session({
  String access = 'access-1',
  Duration accessLeft = const Duration(hours: 1),
  Duration refreshLeft = const Duration(days: 30),
}) => AuthSession(
  farmer: farmer,
  accessToken: access,
  refreshToken: 'refresh-of-$access',
  accessExpiresAt: now.add(accessLeft),
  refreshExpiresAt: now.add(refreshLeft),
);

class MemorySessionRepository implements SessionRepository {
  AuthSession? stored;

  MemorySessionRepository([this.stored]);

  @override
  Future<AuthSession?> read() async => stored;

  @override
  Future<void> save(AuthSession session) async => stored = session;

  @override
  Future<void> clear() async => stored = null;
}

/// Backend of the tests: decides what each call answers.
class FakeAuthGateway implements AuthGateway {
  final calls = <String>[];
  SignUpCommand? lastSignUp;
  String? lastEmail;

  /// What the next call throws; null answers with a session.
  Object? failure;
  int refreshes = 0;

  @override
  Future<AuthSession> signUp(SignUpCommand command) async {
    calls.add('signUp');
    lastSignUp = command;
    return _answer(session(access: 'access-signup'));
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn');
    lastEmail = email;
    return _answer(session(access: 'access-login'));
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    calls.add('refresh');
    refreshes++;
    // Let concurrent callers queue up behind this one.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _answer(session(access: 'access-refreshed-$refreshes'));
  }

  AuthSession _answer(AuthSession value) {
    final error = failure;
    if (error != null) throw error;
    return value;
  }
}

const wrongCredentials = AuthException(
  'credenciales_invalidas',
  'Correo o contraseña incorrectos',
);
const revokedToken = AuthException(
  'token_invalido',
  'Su sesión no es válida o expiró. Inicie sesión de nuevo.',
);
const offline = NetworkUnavailableException();
