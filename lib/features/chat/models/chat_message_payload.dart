class ChatMessagePayload {
  final String type;
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String? content;
  final DateTime? timestamp;
  final String? fileId;
  final String? fileKey;
  final String? fileName;
  final String? fileMimeType;
  final int? fileSize;

  const ChatMessagePayload({
    required this.type,
    this.id,
    this.senderId,
    this.receiverId,
    this.content,
    this.timestamp,
    this.fileId,
    this.fileKey,
    this.fileName,
    this.fileMimeType,
    this.fileSize,
  });

  factory ChatMessagePayload.fromJson(Map<String, dynamic> json) {
    return ChatMessagePayload(
      type: json['type'] as String,
      id: json['id'] as String?,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      content: json['content'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      fileId: json['file_id'] as String?,
      fileKey: json['file_key'] as String?,
      fileName: json['file_name'] as String?,
      fileMimeType: json['file_mime_type'] as String?,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (fileId != null) 'file_id': fileId,
      if (fileKey != null) 'file_key': fileKey,
      if (fileName != null) 'file_name': fileName,
      if (fileMimeType != null) 'file_mime_type': fileMimeType,
      if (fileSize != null) 'file_size': fileSize,
    };
  }
}
