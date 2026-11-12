import '../../../../iam/interfaces/acl/iam_context_facade.dart';

/// What the clinical context needs from the iam context (anti-corruption
/// layer): who is signed in and a token for the backend.
class ExternalIamService {
  final IamContextFacade _iam;

  const ExternalIamService(this._iam);

  Future<String?> currentFarmerId() => _iam.currentFarmerId();

  /// Throws SessionExpiredException or NetworkUnavailableException.
  Future<String> accessToken() => _iam.accessToken();
}
