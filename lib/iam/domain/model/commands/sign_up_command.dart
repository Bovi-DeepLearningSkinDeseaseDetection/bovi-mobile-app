/// Data of a new account (HU14, scenario 1).
class SignUpCommand {
  final String name;
  final String email;
  final String password;

  /// The farmer read and accepted the data consent (Ley N.° 29733).
  final bool consentAccepted;

  const SignUpCommand({
    required this.name,
    required this.email,
    required this.password,
    required this.consentAccepted,
  });
}
