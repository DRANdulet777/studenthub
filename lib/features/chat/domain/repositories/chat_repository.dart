import 'dart:async';
import 'package:student_hub/features/chat/domain/entities/chat_entities.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getChatRooms();
  Future<ChatRoom?> getChatRoomById(String id);
  Future<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<void> markAsRead(String chatId, String messageId);
  Future<void> createChatRoom(ChatRoom chatRoom);
}