import '../../application/internal/commandservices/auth_command_service.dart';

/// What the other bounded contexts may know about the farmer's session.
///
/// The sync (HU12) and the restore (HU13) ask here for the token; they never
/// read the session storage nor call /auth themselves.
class IamContextFacade {
  final AuthCommandService _auth;

  const IamContextFacade(this._auth);

  /// Id of the farmer in the cloud, or null without an active session.
  Future<String?> currentFarmerId() async =>
      (await _auth.activeSession())?.farmer.id;

  /// Token for the `Authorization: Bearer` header, renewed when needed.
  ///
  /// Throws SessionExpiredException (sign in again) or
  /// NetworkUnavailableException (retry later).
  Future<String> accessToken() => _auth.validAccessToken();
}
