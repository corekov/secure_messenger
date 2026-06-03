import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../l10n/app_localizations.dart';

import '../providers/chat_list_provider.dart';
import '../../../core/widgets/authenticated_avatar.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showFab = true;

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchChats,
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : Text(l10n.chatsTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
              onPressed: () {},
            ),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            if (!_showFab) setState(() => _showFab = true);
          } else if (notification.direction == ScrollDirection.reverse) {
            if (_showFab) setState(() => _showFab = false);
          }
          return true; // Let the notification continue to bubble up
        },
        child: chatState.when(
          data: (allChats) {
            final chats = allChats.where((chat) {
              return chat.name.toLowerCase().contains(_searchQuery);
            }).toList();

            if (allChats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noSecureChats,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.startChatSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(
                          140,
                        ),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (chats.isEmpty) {
              return Center(
                child: Text(
                  l10n.noChatsFound,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: chats.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.dividerColor.withAlpha(25),
                height: 1,
                indent: 88,
              ),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Slidable(
                  key: ValueKey(chat.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: theme.cardColor,
                              title: Text(l10n.deleteChat),
                              content: Text(l10n.deleteChatConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    l10n.cancel,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withAlpha(150),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    l10n.delete,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await ref
                                  .read(chatListProvider.notifier)
                                  .deleteChat(chat.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to delete chat'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: l10n.delete,
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Stack(
                      children: [
                        AuthenticatedAvatar(
                          avatarUrl: chat.avatarUrl,
                          fallbackText: chat.name,
                          radius: 28,
                        ),
                        if (chat.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent[400],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      chat.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _formatLastMessage(chat.lastMessage, l10n),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(
                            140,
                          ),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(chat.lastMessageTime),
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(
                              100,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (chat.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 20),
                      ],
                    ),
                    onTap: () {
                      context.push('/chat/${chat.id}', extra: chat.name);
                    },
                  ),
                ),
              );
            },
          );
        },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        scale: _showFab ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/create-chat');
          },
          backgroundColor: Colors.blueAccent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.maps_ugc, color: Colors.white, size: 30),
        ),
      ),
    );
  }
  
  String _formatLastMessage(String lastMessage, AppLocalizations l10n) {
    if (lastMessage == 'Secure message' ||
        lastMessage == 'Decryption failed' ||
        lastMessage == 'Decryption error' ||
        lastMessage == 'Ошибка расшифровки') {
      return l10n.secureMessageFallback;
    }
    
    if (lastMessage.startsWith('{') && lastMessage.contains('"type"')) {
      try {
        final payload = jsonDecode(lastMessage);
        if (payload['type'] == 'image') {
          return '📷 ${l10n.photoVideo}';
        } else if (payload['type'] == 'video') {
          return '📹 ${l10n.photoVideo}';
        } else if (payload['type'] == 'file') {
          return '📄 ${l10n.document}';
        }
      } catch (_) {
        // Ignore JSON parse errors, fall back to string
      }
    }
    return lastMessage;
  }
}
