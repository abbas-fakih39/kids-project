
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  final _dio = DioClient.instance;


  /// Login with email + password → saves tokens to secure storage.
  Future<void> login(String email, String password) async {
    final res = await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,       // ✓ matches LoginDto
        'password': password, // ✓ matches LoginDto
      },
    );
    final data = res.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Réponse serveur invalide : token absent');
    }
    await SecureStorage.saveTokens(accessToken, refreshToken ?? '');
  }

  /// Register new user → saves tokens on success.
  Future<void> register({
    required String prenom,
    required String nom,
    required String email,
    String? phone,
    required String password,
  }) async {
    final res = await _dio.post(
      ApiConstants.register,
      data: {
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'number': phone.trim(),
      },
    );
    final data = res.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Réponse serveur invalide : token absent');
    }
    await SecureStorage.saveTokens(accessToken, refreshToken ?? '');
  }

  /// Logout: calls NestJS logout endpoint + clears local tokens.
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Ignore server errors on logout — still clear local tokens
    }
    await SecureStorage.clearTokens();
  }
}
