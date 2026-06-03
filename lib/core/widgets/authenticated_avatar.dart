import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';

class AuthenticatedAvatar extends ConsumerWidget {
  final String? avatarUrl;
  final String fallbackText;
  final double radius;

  const AuthenticatedAvatar({
    super.key,
    required this.avatarUrl,
    required this.fallbackText,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildFallback();
    }

    return FutureBuilder<String?>(
      future: ref.read(secureStorageServiceProvider).getAccessToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildFallback();
        }

        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
          ),
          child: ClipOval(
            child: Image.network(
              'http://10.0.2.2:8080$avatarUrl',
              headers: {'Authorization': 'Bearer ${snapshot.data}'},
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.85,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
