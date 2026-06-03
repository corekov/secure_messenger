import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: false, // Prevents nested navigator overlays (like dropdowns) from rendering under the bottom nav bar
      body: navigationShell,
      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Remove solid color from here so the shadow works, but background is transparent
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 50 : 10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: (Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).cardColor).withValues(alpha: isDark ? 0.8 : 0.85),
                  child: BottomNavigationBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: isDark ? Colors.blueAccent : Theme.of(context).primaryColor,
                    unselectedItemColor: isDark ? Colors.white : Colors.black87,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                currentIndex: navigationShell.currentIndex,
                onTap: (int index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.chat_bubble_outline),
                    activeIcon: const Icon(Icons.chat_bubble),
                    label: l10n.chatsTitle,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person),
                    label: l10n.profile,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: const Icon(Icons.settings),
                    label: l10n.settings,
                  ),
                ],
              ),
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }
}
