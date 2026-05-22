import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    return false; // represents unauthenticated state initially
  }

  Future<void> login(String username, String password) async {
    final authService = ref.read(authServiceProvider);
    await authService.login(username, password);
    state = true;
  }

  Future<void> register(String username, String password) async {
    final authService = ref.read(authServiceProvider);
    await authService.register(username, password);
    state = true;
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    try {
      await authService.logout();
    } catch (e) {
      // ignore logout network errors
    }
    state = false;
  }

  void forceLogout() {
    state = false;
  }
}
