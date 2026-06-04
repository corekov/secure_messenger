import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/messages_provider.dart';
import '../providers/chat_list_provider.dart';
import '../services/chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/chat_bubble.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/authenticated_avatar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({super.key, required this.chatId, required this.chatName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.markRead(widget.chatId);
      ref.read(chatListProvider.notifier).syncChats();
    } catch (e) {
      // Ignore errors if marking read fails
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    try {
      await ref
          .read(messagesProvider(widget.chatId).notifier)
          .sendMessage(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _showAttachmentOptions() async {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.photoVideo),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(context)!.camera),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(AppLocalizations.of(context)!.document),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedia(bool fromCamera) async {
    final picker = ImagePicker();
    XFile? mediaFile;

    if (fromCamera) {
      mediaFile = await picker.pickImage(source: ImageSource.camera);
    } else {
      mediaFile = await picker.pickMedia();
    }

    if (mediaFile == null) return;

    final file = File(mediaFile.path);
    int size = await file.length();

    String finalPath = file.path;
    final isVideo =
        mediaFile.name.toLowerCase().endsWith('.mp4') ||
        mediaFile.name.toLowerCase().endsWith('.mov');
    final messageType = isVideo ? 'video' : 'image';

    if (!isVideo && size > 15 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.fileTooLargeCompressing,
            ),
          ),
        );
      }

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${file.path}_compressed.jpg',
        quality: 70,
      );

      if (compressedFile != null) {
        finalPath = compressedFile.path;
        size = await File(finalPath).length();
      }
    } else if (isVideo && size > 50 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.videoTooLarge)),
        );
      }
      return;
    }

    try {
      await ref
          .read(messagesProvider(widget.chatId).notifier)
          .sendFileMessage(
            filePath: finalPath,
            messageType: messageType,
            fileName: mediaFile.name,
            mimeType: isVideo ? 'video/mp4' : 'image/jpeg',
            fileSize: size,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send file: $e')));
      }
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = result.files.single;

    try {
      await ref
          .read(messagesProvider(widget.chatId).notifier)
          .sendFileMessage(
            filePath: file.path!,
            messageType: 'file',
            fileName: file.name,
            mimeType: 'application/octet-stream',
            fileSize: file.size,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.chatId));
    final chatList = ref.watch(chatListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Find current chat to get online status
    final chat = chatList.value
        ?.where((c) => c.id == widget.chatId)
        .firstOrNull;
    final isOnline = chat?.isOnline ?? false;

    String statusText = l10n.offline;
    if (isOnline) {
      statusText = l10n.online;
    } else if (chat?.lastSeen != null) {
      final lastSeen = chat!.lastSeen!;
      final now = DateTime.now();
      if (lastSeen.year == now.year &&
          lastSeen.month == now.month &&
          lastSeen.day == now.day) {
        statusText = l10n.lastSeenAt(
          '${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}',
        );
      } else {
        statusText = l10n.lastSeen(
          '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (chat != null) {
              context.push('/peer-profile', extra: chat);
            }
          },
          child: Row(
            children: [
              Stack(
                children: [
                  AuthenticatedAvatar(
                    avatarUrl: chat?.avatarUrl,
                    fallbackText: widget.chatName,
                    radius: 20,
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent[400],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                theme.appBarTheme.backgroundColor ??
                                theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.chatName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (chat != null)
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isOnline
                            ? Colors.greenAccent[400]
                            : theme.textTheme.bodyMedium?.color?.withAlpha(150),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        elevation: 1,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: theme.iconTheme.color?.withAlpha(50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.endToEndEncrypted,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color?.withAlpha(
                              200,
                            ),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noOneOutside,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(
                              150,
                            ),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == 'me';

                    return ChatBubble(message: msg, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
              error: (err, st) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withAlpha(25),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: theme.iconTheme.color?.withAlpha(150),
                      size: 28,
                    ),
                    onPressed: _showAttachmentOptions,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: l10n.secureMessage,
                        hintStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(
                            150,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
