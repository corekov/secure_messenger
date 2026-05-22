import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';

part 'auth_service.g.dart';

class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;

  const AuthService(this._dio, this._storage);

  Future<void> register(String username, String password) async {
    // Generate a simple device fingerprint (in a real app, use device_info_plus)
    final deviceFp = 'android-emulator-fp';
    
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'password': password,
      'device_name': 'Android Emulator',
      'device_fp': deviceFp,
      'platform': 'android',
    });
    
    await _handleAuthResponse(response);
  }

  Future<void> login(String username, String password) async {
    final deviceFp = 'android-emulator-fp';

    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
      'device_fp': deviceFp,
    });
    
    await _handleAuthResponse(response);
  }

  Future<void> _handleAuthResponse(Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      
      if (accessToken != null && refreshToken != null) {
        await _storage.saveAccessToken(accessToken);
        await _storage.saveRefreshToken(refreshToken);
      } else {
        throw Exception('Invalid token response');
      }
    } else {
      throw Exception('Authentication failed');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _storage.clearTokens();
    }
  }
}

@riverpod
AuthService authService(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthService(dio, storage);
}
