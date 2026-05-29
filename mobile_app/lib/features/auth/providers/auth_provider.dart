import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/dio_client.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  Future<void> loadUser() async {
    try {
      final res = await DioClient.instance.get('/users/profile');
      _user = res.data as Map<String, dynamic>?;
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repo.login(email, password);
      await loadUser();
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      return false;
    } catch (_) {
      _setLoading(false);
      _setError('Impossible de joindre le serveur.');
      return false;
    }
  }

  Future<bool> register({
    required String prenom,
    required String nom,
    required String email,
    String? phone,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repo.register(
        prenom: prenom,
        nom: nom,
        email: email,
        phone: phone,
        password: password,
      );
      await loadUser();
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      return false;
    } catch (_) {
      _setLoading(false);
      _setError('Impossible de joindre le serveur.');
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await _repo.logout();
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is List) return msg.join('\n');
      if (msg is String) return msg;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Délai de connexion dépassé. Vérifiez que le serveur est lancé.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez que le backend est lancé sur le port 3000.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
