import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/providers/auth_provider.dart';

part 'dio_client.g.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storage;
  final Auth _authProvider;
  final Dio _dio;

  AuthInterceptor(this._storage, this._authProvider, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final success = await _refreshToken();
      if (success) {
        // Retry the original request
        try {
          final token = await _storage.getAccessToken();
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $token';

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      } else {
        // Refresh failed, logout
        _authProvider.forceLogout();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

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
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api/v1'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  final storage = ref.watch(secureStorageServiceProvider);
  final authProviderValue = ref.watch(authProvider.notifier);

  dio.interceptors.add(AuthInterceptor(storage, authProviderValue, dio));

  return dio;
}
