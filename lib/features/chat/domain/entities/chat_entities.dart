class ChatRoom {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String avatarUrl;
  final bool isGroup;
  final List<String> participants;

  ChatRoom({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.avatarUrl = '',
    this.isGroup = false,
    this.participants = const [],
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? avatarUrl,
    bool? isGroup,
    List<String>? participants,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroup: isGroup ?? this.isGroup,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'avatarUrl': avatarUrl,
      'isGroup': isGroup,
      'participants': participants,
    };
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isGroup: json['isGroup'] as bool? ?? false,
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: _parseMessageType(json['type'] as String? ?? 'text'),
    );
  }

  static MessageType _parseMessageType(String value) {
    return MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => MessageType.text,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  system,
}