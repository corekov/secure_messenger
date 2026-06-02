class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String messageType;
  final String? fileId;
  final String? fileName;
  final int? fileSize;
  final String? localFilePath;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
    this.fileId,
    this.fileName,
    this.fileSize,
    this.localFilePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
      'message_type': messageType,
      'file_id': fileId,
      'file_name': fileName,
      'file_size': fileSize,
      'local_file_path': localFilePath,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      chatId: map['chat_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isRead: (map['is_read'] as int) == 1,
      messageType: map['message_type'] as String? ?? 'text',
      fileId: map['file_id'] as String?,
      fileName: map['file_name'] as String?,
      fileSize: map['file_size'] as int?,
      localFilePath: map['local_file_path'] as String?,
    );
  }
}
