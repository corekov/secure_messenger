import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const CircleAvatar(
                radius: 56,
                backgroundColor: Color(0xFF1E1E1E),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: profileAsync.when(
              data: (profile) => Text(
                profile?.username ?? 'Secure User',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Failed to load', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
          const Center(
            child: Text(
              'Active',
              style: TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),
          ),
          const SizedBox(height: 48),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            subtitle: 'End-to-End Encryption is ON',
            iconColor: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            subtitle: 'Message tones, vibration',
            iconColor: Colors.amberAccent,
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Dark theme',
            iconColor: Colors.purpleAccent,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Trigger secure logout sequence
              ref.read(authProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withAlpha(200),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10)),
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
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () {}, // Placeholder
      ),
    );
  }
}
