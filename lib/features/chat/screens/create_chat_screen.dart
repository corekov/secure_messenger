import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../user/services/user_service.dart';
import '../services/chat_service.dart';

class CreateChatScreen extends ConsumerStatefulWidget {
  const CreateChatScreen({super.key});

  @override
  ConsumerState<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends ConsumerState<CreateChatScreen> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final userService = ref.read(userServiceProvider);
      final results = await userService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createChat(String targetUserId) async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final chatData = await chatService.createDirectChat(targetUserId);
      if (mounted) {
        context.pop();
        context.push('/chat/${chatData['id']}', extra: chatData['name'] ?? 'Chat');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create chat', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search username...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Colors.blueAccent))
          else if (_searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Search for a username to start chatting', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1, indent: 76),
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  final username = user['username'] ?? 'Unknown';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(username, style: const TextStyle(color: Colors.white)),
                    onTap: () => _createChat(user['id']),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
