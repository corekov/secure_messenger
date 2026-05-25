import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withAlpha(20), width: 1),
          ),
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: const Color(0xFF121212),
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.blueAccent.withAlpha(40),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (int index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.chat_bubble, color: Colors.blueAccent),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
