import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/providers/auth_provider.dart';

part 'dio_client.g.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storage;
  final void Function() _onLogout;
  final Dio _dio;

  AuthInterceptor(this._storage, this._onLogout, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers.remove('authorization');
      options.headers.remove('Authorization');
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final newToken = await _refreshToken();
      if (newToken != null) {
        // Retry the original request
        try {
          final options = err.requestOptions;
          options.headers.remove('authorization');
          options.headers.remove('Authorization');
          options.headers['Authorization'] = 'Bearer $newToken';

          if (options.data is FormData) {
            options.data = (options.data as FormData).clone();
          }

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      } else {
        // Refresh failed, logout
        _onLogout();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return null;

      // Use a separate Dio instance to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _storage.saveAccessToken(newAccessToken);
          await _storage.saveRefreshToken(newRefreshToken);
          return newAccessToken;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

@riverpod
Dio dioClient(Ref ref) {
  final defaultUrl = (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) 
      ? 'http://10.0.2.2:8080/api/v1' 
      : 'http://localhost:8080/api/v1';

  final dio = Dio(
    BaseOptions(
      baseUrl: String.fromEnvironment('API_URL', defaultValue: defaultUrl),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  final storage = ref.watch(secureStorageServiceProvider);

  dio.interceptors.add(AuthInterceptor(
    storage, 
    () => ref.read(authProvider.notifier).forceLogout(), 
    dio,
  ));

  return dio;
}
