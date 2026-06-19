import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../navigation/app_navigator.dart';

// dart:io is not available on web — conditionally import for cert pinning
import 'dio_client_native.dart' if (dart.library.html) 'dio_client_web.dart'
    as platform_config;

class DioClient {
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(_AuthInterceptor());

    // Certificate pinning — only on native platforms, not on web
    platform_config.configureCertPinning(dio);

    return dio;
  }

  static Dio get instance => _dio;
}

class _AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (!options.path.contains('/auth/login') && !options.path.contains('/auth/register')) {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Continue without token if secure storage is unavailable
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Avoid refresh loop on auth endpoints
      if (err.requestOptions.path.contains('/auth/')) {
        await _logout();
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshToken = await SecureStorage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
            final res = await refreshDio.post(
              '/auth/refresh',
              options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
            );
            final newAccess = res.data['accessToken'] as String;
            final newRefresh = res.data['refreshToken'] as String;
            await SecureStorage.saveTokens(newAccess, newRefresh);
            // Unblock all requests that were waiting for the refresh
            for (final c in _refreshWaiters) {
              c.complete();
            }
            _refreshWaiters.clear();
            // Retry the original request with the new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
            final retried = await DioClient.instance.fetch(err.requestOptions);
            return handler.resolve(retried);
          }
        } catch (e) {
          // Refresh failed — unblock waiters with error so they can logout too
          for (final c in _refreshWaiters) {
            c.completeError(e);
          }
          _refreshWaiters.clear();
        } finally {
          _isRefreshing = false;
        }
        await _logout();
      } else {
        // Refresh already in progress — queue this request and wait for it to finish
        final completer = Completer<void>();
        _refreshWaiters.add(completer);
        try {
          await completer.future;
          final newToken = await SecureStorage.getToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retried = await DioClient.instance.fetch(err.requestOptions);
          return handler.resolve(retried);
        } catch (_) {
          await _logout();
          return handler.next(err);
        }
      }
    }
    handler.next(err);
  }

  Future<void> _logout() async {
    await SecureStorage.clearTokens();
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
