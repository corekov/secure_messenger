class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? peerPublicKey;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? peerId;
  final String? avatarUrl;
  final String? bio;
  final DateTime? deletedAt;
  final bool isSecret;
  final int? messageTtl;

  const ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.peerPublicKey,
    this.isOnline = false,
    this.lastSeen,
    this.peerId,
    this.avatarUrl,
    this.bio,
    this.deletedAt,
    this.isSecret = false,
    this.messageTtl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.millisecondsSinceEpoch,
      'unread_count': unreadCount,
      'peer_public_key': peerPublicKey,
      'is_online': isOnline ? 1 : 0,
      'last_seen': lastSeen?.millisecondsSinceEpoch,
      'peer_id': peerId,
      'avatar_url': avatarUrl,
      'bio': bio,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
      'is_secret': isSecret ? 1 : 0,
      'message_ttl': messageTtl,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      name: map['name'] as String,
      lastMessage: map['last_message'] as String,
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['last_message_time'] as int,
      ),
      unreadCount: map['unread_count'] as int,
      peerPublicKey: map['peer_public_key'] as String?,
      isOnline: (map['is_online'] as int?) == 1,
      lastSeen: map['last_seen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_seen'] as int)
          : null,
      peerId: map['peer_id'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deleted_at'] as int)
          : null,
      isSecret: (map['is_secret'] as int?) == 1,
      messageTtl: map['message_ttl'] as int?,
    );
  }

  ChatModel copyWith({
    String? id,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? peerPublicKey,
    bool? isOnline,
    DateTime? lastSeen,
    String? peerId,
    String? avatarUrl,
    String? bio,
    DateTime? deletedAt,
    bool? isSecret,
    int? messageTtl,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      peerPublicKey: peerPublicKey ?? this.peerPublicKey,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      peerId: peerId ?? this.peerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      deletedAt: deletedAt ?? this.deletedAt,
      isSecret: isSecret ?? this.isSecret,
      messageTtl: messageTtl ?? this.messageTtl,
    );
  }
}
