import 'dart:async';
import 'package:student_hub/features/chat/domain/entities/chat_entities.dart';
import 'package:student_hub/features/chat/domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final List<ChatRoom> _chatRooms = [];
  final Map<String, List<Message>> _messages = {};

  MockChatRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _chatRooms.addAll([
      ChatRoom(
        id: 'cr001',
        name: 'Группа по Алгоритмам',
        lastMessage: 'Когда следующая лекция?',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isGroup: true,
        participants: ['user1', 'user2', 'user3'],
      ),
      ChatRoom(
        id: 'cr002',
        name: 'Мария Петрова',
        lastMessage: 'Спасибо за помощь с задачей!',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isGroup: false,
        participants: ['user1', 'user2'],
      ),
      ChatRoom(
        id: 'cr003',
        name: 'Команда проекта',
        lastMessage: 'Встреча в 15:00 в аудитории 301',
        lastMessageTime: now.subtract(const Duration(hours: 4)),
        unreadCount: 1,
        isGroup: true,
        participants: ['user1', 'user2', 'user3', 'user4'],
      ),
      ChatRoom(
        id: 'cr004',
        name: 'Алексей Иванов',
        lastMessage: 'Можешь поделиться конспектом?',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isGroup: false,
        participants: ['user1', 'user3'],
      ),
    ]);

    // Initialize messages for each chat
    for (final chat in _chatRooms) {
      _messages[chat.id] = [
        Message(
          id: 'm001_${chat.id}',
          chatId: chat.id,
          senderId: 'user2',
          senderName: 'Другой пользователь',
          content: chat.lastMessage,
          timestamp: chat.lastMessageTime,
          isRead: chat.unreadCount == 0,
        ),
      ];
    }
  }

  @override
  Future<List<ChatRoom>> getChatRooms() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_chatRooms);
  }

  @override
  Future<ChatRoom?> getChatRoomById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _chatRooms.where((chat) => chat.id == id).firstOrNull;
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_messages[chatId] ?? []);
  }

  @override
  Future<void> sendMessage(Message message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_messages.containsKey(message.chatId)) {
      _messages[message.chatId] = [];
    }
    _messages[message.chatId]!.add(message);

    // Update last message in chat room
    final chatIndex = _chatRooms.indexWhere((chat) => chat.id == message.chatId);
    if (chatIndex != -1) {
      _chatRooms[chatIndex] = _chatRooms[chatIndex].copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
      );
    }
  }

  @override
  Future<void> markAsRead(String chatId, String messageId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final messages = _messages[chatId];
    if (messages != null) {
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].copyWith(isRead: true);
      }
    }

    // Update unread count
    final chatIndex = _chatRooms.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _chatRooms[chatIndex] = _chatRooms[chatIndex].copyWith(unreadCount: 0);
    }
  }

  @override
  Future<void> createChatRoom(ChatRoom chatRoom) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _chatRooms.add(chatRoom);
    _messages[chatRoom.id] = [];
  }
}