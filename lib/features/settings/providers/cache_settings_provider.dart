import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cache_settings_provider.g.dart';

@riverpod
class CacheSettings extends _$CacheSettings {
  static const _key = 'cache_retention_days';

  @override
  int build() {
    // 0 means never clear. Default to 0.
    _loadFromPrefs();
    return 0;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(_key) ?? 0;
    if (val != state) {
      state = val;
    }
  }

  Future<void> setRetentionDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, days);
    state = days;
  }
}
