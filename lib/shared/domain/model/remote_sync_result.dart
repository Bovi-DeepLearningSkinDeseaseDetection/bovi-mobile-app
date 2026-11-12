/// Answer of the backend for one record of a sync batch (HU12, RNF10).
enum RemoteSyncStatus {
  accepted,
  duplicate,
  merged,
  rejected;

  static RemoteSyncStatus parse(String value) => values.byName(value);
}

class RemoteSyncResult {
  /// Rejections the next attempt can solve by itself: the record stays
  /// pending instead of failing.
  static const retryableCodes = {
    'imagen_no_encontrada',
    'animal_no_sincronizado',
    'reintentar',
  };

  final String id;
  final RemoteSyncStatus status;
  final String? canonicalId;
  final String? code;
  final String? message;

  const RemoteSyncResult({
    required this.id,
    required this.status,
    this.canonicalId,
    this.code,
    this.message,
  });

  factory RemoteSyncResult.fromJson(Map<String, dynamic> json) =>
      RemoteSyncResult(
        id: json['id'] as String,
        status: RemoteSyncStatus.parse(json['status'] as String),
        canonicalId: json['canonical_id'] as String?,
        code: json['code'] as String?,
        message: json['message'] as String?,
      );

  /// Already in the cloud: "Sincronizado" (scenario 2).
  bool get isSynced => status != RemoteSyncStatus.rejected;

  bool get isRetryable =>
      status == RemoteSyncStatus.rejected && retryableCodes.contains(code);

  /// Rejected for good: "Error al sincronizar" with [message].
  bool get isFailed => status == RemoteSyncStatus.rejected && !isRetryable;
}
