import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/theme_provider.dart';

part 'locale_provider.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  static const _localeKey = 'app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_localeKey, locale.languageCode);
  }
}
