class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? peerPublicKey;

  const ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.peerPublicKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.millisecondsSinceEpoch,
      'unread_count': unreadCount,
      'peer_public_key': peerPublicKey,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      name: map['name'] as String,
      lastMessage: map['last_message'] as String,
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['last_message_time'] as int),
      unreadCount: map['unread_count'] as int,
      peerPublicKey: map['peer_public_key'] as String?,
    );
  }
}
