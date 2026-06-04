import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:open_filex/open_filex.dart';
import '../models/message_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/messages_provider.dart';
import '../screens/media_viewer_screen.dart';

class ChatBubble extends ConsumerStatefulWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  ConsumerState<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends ConsumerState<ChatBubble> {
  bool _isDownloading = false;
  Timer? _expireTimer;

  @override
  void initState() {
    super.initState();
    _startExpireTimer();
  }

  @override
  void didUpdateWidget(ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.expiresAt != oldWidget.message.expiresAt) {
      _startExpireTimer();
    }
  }

  void _startExpireTimer() {
    _expireTimer?.cancel();
    if (widget.message.expiresAt != null) {
      _expireTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _expireTimer?.cancel();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  Future<void> _saveToDevice() async {
    final path = widget.message.localFilePath;
    if (path == null) return;

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      if (widget.message.messageType == 'image') {
        await Gal.putImage(path);
      } else if (widget.message.messageType == 'video') {
        await Gal.putVideo(path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.savedToGallery)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleTap() async {
    if (widget.message.localFilePath == null && widget.message.fileId != null) {
      setState(() => _isDownloading = true);
      try {
        await ref
            .read(messagesProvider(widget.message.chatId).notifier)
            .downloadFile(widget.message.id);
      } finally {
        if (mounted) {
          setState(() => _isDownloading = false);
        }
      }
    } else if (widget.message.localFilePath != null) {
      if (widget.message.messageType == 'image' ||
          widget.message.messageType == 'video') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaViewerScreen(
              filePath: widget.message.localFilePath!,
              isVideo: widget.message.messageType == 'video',
            ),
          ),
        );
      } else if (widget.message.messageType == 'file') {
        OpenFilex.open(widget.message.localFilePath!);
      }
    }
  }

  void _handleLongPress() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                l10n.deleteForMe,
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(messagesProvider(widget.message.chatId).notifier)
                    .deleteMessage(widget.message, forEveryone: false);
              },
            ),
            if (widget.isMe)
              ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                title: Text(
                  l10n.deleteForEveryone,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(messagesProvider(widget.message.chatId).notifier)
                      .deleteMessage(widget.message, forEveryone: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    Widget contentWidget;

    if (widget.message.messageType == 'image') {
      contentWidget = _buildImageContent(theme, l10n);
    } else if (widget.message.messageType == 'video') {
      contentWidget = _buildVideoContent(theme, l10n);
    } else if (widget.message.messageType == 'file') {
      contentWidget = _buildFileContent(theme, l10n);
    } else {
      final text =
          (widget.message.content == 'Secure message' ||
              widget.message.content == 'Decryption failed' ||
              widget.message.content == 'Decryption error' ||
              widget.message.content == 'Ошибка расшифровки')
          ? l10n.secureMessageFallback
          : widget.message.content;

      contentWidget = Text(
        text,
        style: TextStyle(
          color: widget.isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontSize: 16,
          height: 1.3,
        ),
      );
    }

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isMe
                ? const LinearGradient(
                    colors: [Color(0xFF2879FE), Color(0xFF1E5BBF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isMe
                ? null
                : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: widget.isMe ? const Radius.circular(4) : null,
              bottomLeft: !widget.isMe ? const Radius.circular(4) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: widget.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              contentWidget,
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.message.timestamp.hour.toString().padLeft(2, '0')}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.isMe
                          ? Colors.white70
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                  if (widget.message.expiresAt != null) ...[
                    const SizedBox(width: 4),
                    _buildExpireTimer(isDark),
                  ],
                  if (widget.isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpireTimer(bool isDark) {
    final expiresAt = widget.message.expiresAt;
    if (expiresAt == null) return const SizedBox.shrink();

    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return const SizedBox.shrink();

    final seconds = remaining.inSeconds % 60;
    final minutes = remaining.inMinutes % 60;
    final hours = remaining.inHours;

    String timeStr;
    if (hours > 0) {
      timeStr = '${hours}h';
    } else if (minutes > 0) {
      timeStr = '${minutes}m';
    } else {
      timeStr = '${seconds}s';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 12,
          color: widget.isMe
              ? Colors.white70
              : (isDark ? Colors.white54 : Colors.black54),
        ),
        const SizedBox(width: 2),
        Text(
          timeStr,
          style: TextStyle(
            fontSize: 10,
            color: widget.isMe
                ? Colors.white70
                : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color = Colors.white70;

    switch (widget.message.status) {
      case 'sending':
        icon = Icons.access_time;
        break;
      case 'error':
        icon = Icons.error_outline;
        color = Colors.redAccent;
        break;
      case 'read':
        icon = Icons.done_all;
        color = Colors.blue.shade200;
        break;
      case 'delivered':
        icon = Icons.done_all;
        break;
      case 'sent':
      default:
        icon = Icons.check;
        break;
    }

    final iconWidget = Icon(icon, size: 12, color: color);

    if (widget.message.status == 'error') {
      return GestureDetector(
        onTap: () {
          ref
              .read(messagesProvider(widget.message.chatId).notifier)
              .resendMessage(widget.message);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.tapToRetry,
              style: TextStyle(fontSize: 10, color: color),
            ),
            const SizedBox(width: 4),
            iconWidget,
          ],
        ),
      );
    }

    return iconWidget;
  }

  Widget _buildImageContent(ThemeData theme, AppLocalizations l10n) {
    if (widget.message.localFilePath != null &&
        File(widget.message.localFilePath!).existsSync()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.message.localFilePath!),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          _buildActionRow(theme),
        ],
      );
    }

    return _buildDownloadPrompt(Icons.image, l10n.photoTapToDownload, theme);
  }

  Widget _buildVideoContent(ThemeData theme, AppLocalizations l10n) {
    if (widget.message.localFilePath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildActionRow(theme),
        ],
      );
    }

    return _buildDownloadPrompt(Icons.videocam, l10n.videoTapToDownload, theme);
  }

  Widget _buildFileContent(ThemeData theme, AppLocalizations l10n) {
    if (widget.message.localFilePath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: widget.isMe ? Colors.white : theme.iconTheme.color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.fileName ?? 'File',
                      style: TextStyle(
                        color: widget.isMe
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.message.fileSize != null
                          ? _formatFileSize(widget.message.fileSize!)
                          : '',
                      style: TextStyle(
                        color: widget.isMe
                            ? Colors.white70
                            : theme.textTheme.bodyMedium?.color?.withAlpha(150),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildActionRow(theme),
        ],
      );
    }

    return _buildDownloadPrompt(
      Icons.insert_drive_file,
      widget.message.fileName ?? 'Tap to download',
      theme,
    );
  }

  Widget _buildDownloadPrompt(IconData icon, String title, ThemeData theme) {
    final color = widget.isMe ? Colors.white : theme.iconTheme.color;
    final textColor = widget.isMe
        ? Colors.white
        : theme.textTheme.bodyMedium?.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isDownloading)
          SizedBox(
            width: 48,
            height: 48,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: color, strokeWidth: 3),
            ),
          )
        else
          Icon(icon, color: color, size: 48),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            if (widget.message.fileSize != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatFileSize(widget.message.fileSize!),
                  style: TextStyle(
                    color: widget.isMe
                        ? Colors.white70
                        : textColor?.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionRow(ThemeData theme) {
    final textColor = widget.isMe
        ? Colors.white70
        : theme.textTheme.bodyMedium?.color?.withAlpha(150);
    final isDocument = widget.message.messageType == 'file';

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.message.fileSize != null)
          Text(
            _formatFileSize(widget.message.fileSize!),
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        const SizedBox(width: 16),
        InkWell(
          onTap: isDocument ? _handleTap : _saveToDevice,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Icon(
                  isDocument ? Icons.open_in_new : Icons.download,
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isDocument ? 'Open' : AppLocalizations.of(context)!.save,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
