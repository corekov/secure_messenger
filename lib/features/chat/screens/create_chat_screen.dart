import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/authenticated_avatar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../user/services/user_service.dart';
import '../services/chat_service.dart';
import 'dart:convert';
import '../../../l10n/app_localizations.dart';

class CreateChatScreen extends ConsumerStatefulWidget {
  const CreateChatScreen({super.key});

  @override
  ConsumerState<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends ConsumerState<CreateChatScreen> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isSecret = false;
  int _messageTtl = 60; // default 60 seconds

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userService = ref.read(userServiceProvider);
      var results = await userService.searchUsers(query);
      
      final storage = ref.read(secureStorageServiceProvider);
      final token = await storage.getAccessToken();
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          try {
            String normalized = base64Url.normalize(parts[1]);
            switch (normalized.length % 4) {
              case 2: normalized += '=='; break;
              case 3: normalized += '='; break;
            }
            final decoded = utf8.decode(base64Url.decode(normalized));
            final currentUserId = jsonDecode(decoded)['user_id'];
            results = results.where((u) => u['id'] != currentUserId).toList();
          } catch (_) {}
        }
      }

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

  Future<void> _createChat(String targetUserId, String username) async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final chatData = await chatService.createDirectChat(
        targetUserId,
        isSecret: _isSecret,
        messageTtl: _isSecret ? _messageTtl : null,
      );
      if (mounted) {
        context.pop();
        context.push(
          '/chat/${chatData['id']}',
          extra: username,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create chat'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.newChat,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: l10n.searchUsername,
                hintStyle: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                ),
                filled: true,
                fillColor: theme.cardColor,
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              l10n.secretChat,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(l10n.secretChatSubtitle),
            value: _isSecret,
            activeThumbColor: Colors.blueAccent,
            onChanged: (val) {
              setState(() {
                _isSecret = val;
              });
            },
          ),
          if (_isSecret)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(l10n.disappearingTimer),
                  const Spacer(),
                  DropdownButton<int>(
                    value: _messageTtl,
                    items: [
                      DropdownMenuItem(value: 10, child: Text(l10n.seconds10)),
                      DropdownMenuItem(value: 30, child: Text(l10n.seconds30)),
                      DropdownMenuItem(value: 60, child: Text(l10n.minute1)),
                      DropdownMenuItem(value: 3600, child: Text(l10n.hour1)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _messageTtl = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          const Divider(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      size: 80,
                      color: theme.iconTheme.color?.withAlpha(50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.findPeople,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.typeUsername,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(
                          150,
                        ),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  color: theme.dividerColor.withAlpha(25),
                  height: 1,
                  indent: 72,
                ),
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  final username = user['username'] ?? 'Unknown';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: AuthenticatedAvatar(
                      avatarUrl: user['avatar_url'],
                      fallbackText: username,
                      radius: 24,
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.tapToStart,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.iconTheme.color?.withAlpha(100),
                    ),
                    onTap: () => _createChat(user['id'], username),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
