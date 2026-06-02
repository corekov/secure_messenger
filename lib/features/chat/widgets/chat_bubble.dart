import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../../../l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/messages_provider.dart';
import '../screens/media_viewer_screen.dart';
class ChatBubble extends ConsumerWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    Widget contentWidget;

    if (message.messageType == 'image') {
      contentWidget = _buildImageContent(theme, l10n);
    } else if (message.messageType == 'video') {
      contentWidget = _buildVideoContent(theme, l10n);
    } else if (message.messageType == 'file') {
      contentWidget = _buildFileContent(theme, l10n);
    } else {
      final text = (message.content == 'Secure message' || 
                    message.content == 'Decryption failed' || 
                    message.content == 'Decryption error' || 
                    message.content == 'Ошибка расшифровки') 
          ? l10n.secureMessageFallback 
          : message.content;
          
      contentWidget = Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color, 
          fontSize: 16, 
          height: 1.3
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          if (message.localFilePath == null && message.fileId != null) {
            ref.read(messagesProvider(message.chatId).notifier).downloadFile(message.id);
          } else if (message.localFilePath != null) {
            if (message.messageType == 'image' || message.messageType == 'video') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MediaViewerScreen(
                    filePath: message.localFilePath!,
                    isVideo: message.messageType == 'video',
                  ),
                ),
              );
            } else if (message.messageType == 'file') {
              OpenFilex.open(message.localFilePath!);
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: isMe 
              ? const LinearGradient(
                  colors: [Color(0xFF2879FE), Color(0xFF1E5BBF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
            color: isMe ? null : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isMe ? const Radius.circular(4) : null,
              bottomLeft: !isMe ? const Radius.circular(4) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: contentWidget,
        ),
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme, AppLocalizations l10n) {
    if (message.localFilePath != null && File(message.localFilePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(message.localFilePath!),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.image, color: isMe ? Colors.white : theme.iconTheme.color, size: 48),
        const SizedBox(height: 8),
        Text(
          'Photo (Tap to download)', // TODO: i18n
          style: TextStyle(color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }

  Widget _buildVideoContent(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.videocam, color: isMe ? Colors.white : theme.iconTheme.color, size: 48),
        const SizedBox(height: 8),
        Text(
          'Video (Tap to download)', // TODO: i18n
          style: TextStyle(color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }

  Widget _buildFileContent(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insert_drive_file, color: isMe ? Colors.white : theme.iconTheme.color, size: 32),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.fileName ?? 'File',
                style: TextStyle(color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${(message.fileSize ?? 0) ~/ 1024} KB',
                style: TextStyle(color: isMe ? Colors.white70 : theme.textTheme.bodyMedium?.color?.withAlpha(150), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
