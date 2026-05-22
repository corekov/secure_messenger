class ChatMessagePayload {
  final String type;
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String? content;
  final DateTime? timestamp;

  const ChatMessagePayload({
    required this.type,
    this.id,
    this.senderId,
    this.receiverId,
    this.content,
    this.timestamp,
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
    };
  }
}
