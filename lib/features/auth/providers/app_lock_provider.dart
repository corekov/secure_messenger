import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pin_auth_service.dart';

part 'app_lock_provider.g.dart';

@riverpod
class BiometricSettings extends _$BiometricSettings {
  static const _biometricKey = 'is_biometric_enabled';

  @override
  bool build() {
    _loadState();
    return false;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_biometricKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
    state = enabled;
  }
}

@riverpod
class AppLockedState extends _$AppLockedState {
  @override
  bool build() {
    // By default, the app is locked when it cold starts
    return true;
  }

  void unlock() {
    state = false;
  }

  void lock() {
    state = true;
  }
}

@riverpod
class HasPinState extends _$HasPinState {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final pinService = ref.read(pinAuthServiceProvider);
    state = await pinService.hasPin();
  }

  void setHasPin(bool value) {
    state = value;
  }
}
