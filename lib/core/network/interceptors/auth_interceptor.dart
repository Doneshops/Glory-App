import 'package:dio/dio.dart';

import '../../network/auth_token_events.dart';
import '../../network/endpoints.dart';
import '../../storage/secure_storage.dart';
import '../../storage/storage_keys.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final ISecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        _shouldRecoverSession(err.requestOptions)) {
      final refreshed = await _tryRefreshToken(err.requestOptions);
      if (refreshed != null) {
        handler.resolve(refreshed);
        return;
      }
      await _clearStoredSession();
      AuthTokenEvents.notifySessionExpired();
    }
    handler.next(err);
  }

  bool _shouldRecoverSession(RequestOptions options) {
    // A guest request (e.g. browsing the video library) carries no token, so
    // a 401 there has no session to refresh or expire.
    if (!options.headers.containsKey('Authorization')) return false;

    const publicAuthPaths = {
      Endpoints.login,
      Endpoints.register,
      Endpoints.verifyOtp,
      Endpoints.resendOtp,
      Endpoints.completeRegistration,
      Endpoints.forgotPassword,
      Endpoints.resetPassword,
    };
    return !publicAuthPaths.contains(options.path);
  }

  Future<void> _clearStoredSession() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _secureStorage.delete(StorageKeys.userId);
  }

  Future<Response<dynamic>?> _tryRefreshToken(RequestOptions original) async {
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.post<Map<String, dynamic>>(
        Endpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      if (body == null || body['success'] != true) return null;

      final data = body['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) return null;

      await _secureStorage.write(StorageKeys.accessToken, newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _secureStorage.write(StorageKeys.refreshToken, newRefreshToken);
      }

      AuthTokenEvents.notifyRefreshed();

      original.headers['Authorization'] = 'Bearer $newAccessToken';
      return dio.fetch<dynamic>(original);
    } catch (_) {
      return null;
    }
  }
}
