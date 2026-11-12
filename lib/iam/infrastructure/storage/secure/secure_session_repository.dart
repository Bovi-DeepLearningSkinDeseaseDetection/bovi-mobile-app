import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/model/aggregates/auth_session.dart';
import '../../../domain/repositories/session_repository.dart';

/// Keeps the session encrypted with a key of the Android Keystore (RNF6):
/// the tokens never touch plain preferences or the Isar database.
class SecureSessionRepository implements SessionRepository {
  static const _key = 'bovi_session';

  final FlutterSecureStorage _storage;

  SecureSessionRepository([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  @override
  Future<AuthSession?> read() async {
    final text = await _storage.read(key: _key);
    if (text == null) return null;
    try {
      return AuthSession.fromJson(jsonDecode(text) as Map<String, Object?>);
    } on Object {
      // Written by an older version or damaged: ask to sign in again.
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(AuthSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
