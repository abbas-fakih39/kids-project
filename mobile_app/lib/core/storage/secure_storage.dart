import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveTokens(String token, String refreshToken) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.trim().isEmpty) return null;
    return token;
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
