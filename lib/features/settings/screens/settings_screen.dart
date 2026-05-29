import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.shield_outlined,
            title: l10n.privacySecurity,
            subtitle: l10n.e2eEncryptionOn,
            iconColor: Colors.blueAccent,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none_outlined,
            title: l10n.notifications,
            subtitle: l10n.messageTones,
            iconColor: Colors.amberAccent,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildThemeTile(context, ref, themeMode, l10n),
          const SizedBox(height: 16),
          _buildLanguageTile(context, ref, locale, l10n),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref, ThemeMode currentMode, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purpleAccent.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.palette_outlined, color: Colors.purpleAccent, size: 24),
        ),
        title: Text(l10n.appearance, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(l10n.chooseTheme, style: const TextStyle(fontSize: 13)),
        trailing: DropdownButton<ThemeMode>(
          value: currentMode,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.system)),
            DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
            DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
          ],
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, Locale currentLocale, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.language_outlined, color: Colors.teal, size: 24),
        ),
        title: Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(currentLocale.languageCode == 'ru' ? l10n.russian : l10n.english, style: const TextStyle(fontSize: 13)),
        trailing: DropdownButton<String>(
          value: currentLocale.languageCode,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            DropdownMenuItem(value: 'en', child: Text(l10n.english)),
            DropdownMenuItem(value: 'ru', child: Text(l10n.russian)),
          ],
          onChanged: (langCode) {
            if (langCode != null) {
              ref.read(localeProvider.notifier).setLocale(Locale(langCode));
            }
          },
        ),
      ),
    );
  }
}
