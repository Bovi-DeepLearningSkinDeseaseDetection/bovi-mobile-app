import '../../../../iam/interfaces/acl/iam_context_facade.dart';

/// What the livestock context needs from the iam context: who is signed in.
class ExternalIamService {
  final IamContextFacade _iam;

  const ExternalIamService(this._iam);

  Future<String?> currentFarmerId() => _iam.currentFarmerId();
}
