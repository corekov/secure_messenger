import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Telegram/Signal dark mode feel
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 0, // Placeholder
        itemBuilder: (context, index) {
          return const ListTile();
        },
      ),
    );
  }
}
