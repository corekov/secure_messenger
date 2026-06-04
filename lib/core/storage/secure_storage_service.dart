import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _privateKeyKey = 'private_key';
  static const String _publicKeyKey = 'public_key';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveKeyPair({
    required String privateKey,
    required String publicKey,
  }) async {
    await _storage.write(key: _privateKeyKey, value: privateKey);
    await _storage.write(key: _publicKeyKey, value: publicKey);
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: _privateKeyKey);
  }

  Future<String?> getPublicKey() async {
    return await _storage.read(key: _publicKeyKey);
  }

  Future<String?> getDeviceFingerprint() async {
    return await _storage.read(key: 'device_fp');
  }

  Future<void> saveDeviceFingerprint(String fp) async {
    await _storage.write(key: 'device_fp', value: fp);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _privateKeyKey);
    await _storage.delete(key: _publicKeyKey);
  }

  Future<void> savePin(String pinHash) async {
    await _storage.write(key: 'app_pin_hash', value: pinHash);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: 'app_pin_hash');
  }

  Future<void> deletePin() async {
    await _storage.delete(key: 'app_pin_hash');
  }
}

@riverpod
SecureStorageService secureStorageService(Ref ref) {
  const secureStorage = FlutterSecureStorage();
  return const SecureStorageService(secureStorage);
}
