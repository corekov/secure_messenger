import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/security/encryption_service.dart';
import '../../user/services/user_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    _checkInitialAuth();
    return false;
  }

  Future<void> _checkInitialAuth() async {
    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    if (token != null) {
      state = true;
    }
  }

  Future<void> login(String username, String password) async {
    final authService = ref.read(authServiceProvider);
    await authService.login(username, password);
    state = true;
  }

  Future<void> register(String username, String password) async {
    final authService = ref.read(authServiceProvider);
    
    await authService.register(username, password);
    
    // Generate/Load keys after successful registration
    final encryptionService = ref.read(encryptionServiceProvider);
    await encryptionService.initialize();
    final publicKey = await encryptionService.getPublicKeyBase64();

    // Upload keys to server
    final userService = ref.read(userServiceProvider);
    await userService.uploadKeys(
      identityKey: publicKey,
      signedPrekey: publicKey,
      prekeySig: 'dummy_sig',
      oneTimeKeys: [],
    );

    state = true;
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    try {
      await authService.logout();
    } catch (e) {
      // ignore logout network errors
    }
    
    // Clear tokens securely
    final storage = ref.read(secureStorageServiceProvider);
    await storage.clearTokens();
    
    state = false;
  }

  void forceLogout() {
    state = false;
  }
}
