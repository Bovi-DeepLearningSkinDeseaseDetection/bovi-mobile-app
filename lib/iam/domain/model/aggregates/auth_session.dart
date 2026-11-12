/// The farmer the evaluations belong to (HU14).
class Farmer {
  /// Id of the account in the cloud.
  final String id;
  final String name;
  final String email;

  const Farmer({required this.id, required this.name, required this.email});

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'email': email};

  factory Farmer.fromJson(Map<String, Object?> json) => Farmer(
    id: json['id']! as String,
    name: json['name']! as String,
    email: json['email']! as String,
  );
}

/// Session of the farmer on this phone, kept in the Android Keystore.
///
/// The access token (1 h) authorizes the calls to the backend; the refresh
/// token (30 days) renews it. While the refresh token is valid the farmer
/// keeps using the app without internet (RF12, HU14 scenario 4).
class AuthSession {
  /// Margin so a token is not sent seconds before it expires.
  static const expirySkew = Duration(minutes: 1);

  final Farmer farmer;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  const AuthSession({
    required this.farmer,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  /// The access token can still be sent to the backend.
  bool hasValidAccess(DateTime now) =>
      accessExpiresAt.subtract(expirySkew).isAfter(now);

  /// The farmer may keep using the app, even offline.
  bool isActive(DateTime now) => refreshExpiresAt.isAfter(now);

  Map<String, Object?> toJson() => {
    'farmer': farmer.toJson(),
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessExpiresAt': accessExpiresAt.toUtc().toIso8601String(),
    'refreshExpiresAt': refreshExpiresAt.toUtc().toIso8601String(),
  };

  factory AuthSession.fromJson(Map<String, Object?> json) => AuthSession(
    farmer: Farmer.fromJson(json['farmer']! as Map<String, Object?>),
    accessToken: json['accessToken']! as String,
    refreshToken: json['refreshToken']! as String,
    accessExpiresAt: DateTime.parse(json['accessExpiresAt']! as String),
    refreshExpiresAt: DateTime.parse(json['refreshExpiresAt']! as String),
  );
}
