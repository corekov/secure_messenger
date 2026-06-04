import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/security/encryption_service.dart';
import '../../user/services/user_service.dart';
import '../../settings/providers/cache_settings_provider.dart';
import '../../chat/repositories/local_chat_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthInit extends _$AuthInit {
  @override
  bool build() => true;

  void complete() {
    state = false;
  }
}

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

      // Ensure encryption keys are initialized and uploaded on app start
      // This heals the state if the user registered before keys logic was added,
      // or if the backend database was wiped.
      final encryptionService = ref.read(encryptionServiceProvider);
      await encryptionService.initialize();
      final publicKey = await encryptionService.getPublicKeyBase64();

      final userService = ref.read(userServiceProvider);
      try {
        await userService.uploadKeys(
          identityKey: publicKey,
          signedPrekey: publicKey,
          prekeySig: 'dummy_sig',
          oneTimeKeys: [],
        );
      } catch (e) {
        // Ignore network errors on startup
      }

      // Clear old cache if configured
      final cacheRetentionDays = ref.read(cacheSettingsProvider);
      if (cacheRetentionDays > 0) {
        final localRepo = ref.read(localChatRepositoryProvider);
        await localRepo.clearOldCache(cacheRetentionDays);
      }
    }

    // Auth check complete
    ref.read(authInitProvider.notifier).complete();
  }

  Future<void> login(String username, String password) async {
    final authService = ref.read(authServiceProvider);
    await authService.login(username, password);

    // Generate/Load keys after successful login
    final encryptionService = ref.read(encryptionServiceProvider);
    await encryptionService.initialize();
    final publicKey = await encryptionService.getPublicKeyBase64();

    // Upload keys to server (if we don't upload, other devices can't get our key if it's a new installation)
    final userService = ref.read(userServiceProvider);
    try {
      await userService.uploadKeys(
        identityKey: publicKey,
        signedPrekey: publicKey,
        prekeySig: 'dummy_sig',
        oneTimeKeys: [],
      );
    } catch (e) {
      // Ignored if server rejects duplicate keys or throws an error.
    }

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
    final storage = ref.read(secureStorageServiceProvider);
    storage.clearTokens();
    state = false;
  }
}
