import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/storage/secure_storage_service.dart';

part 'pin_auth_service.g.dart';

class PinAuthService {
  final SecureStorageService _storage;
  PinAuthService(this._storage);

  String _hashPin(String pin) {
    // Simple SHA-256 hash so we don't store plain text PINs, even in secure storage
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> savePin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.savePin(hash);
  }

  Future<bool> verifyPin(String pin) async {
    final hash = _hashPin(pin);
    final storedHash = await _storage.getPin();
    return hash == storedHash;
  }

  Future<bool> hasPin() async {
    final storedHash = await _storage.getPin();
    return storedHash != null && storedHash.isNotEmpty;
  }

  Future<void> clearPin() async {
    await _storage.deletePin();
  }
}

@riverpod
PinAuthService pinAuthService(Ref ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return PinAuthService(storage);
}
