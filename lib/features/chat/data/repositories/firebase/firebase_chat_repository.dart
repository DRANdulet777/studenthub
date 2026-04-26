import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_hub/features/chat/domain/repositories/chat_repository.dart';
import 'package:student_hub/features/chat/domain/entities/chat_entities.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;

  FirebaseChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs.map((doc) => ChatRoom.fromJson(doc.data())).toList();
    } catch (e) {
      print('FirebaseChatRepository getChatRooms error: $e');
      return [];
    }
  }

  @override
  Future<ChatRoom?> getChatRoomById(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(id)
          .get();

      return doc.exists ? ChatRoom.fromJson(doc.data()!) : null;
    } catch (e) {
      print('FirebaseChatRepository getChatRoomById error: $e');
      return null;
    }
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    } catch (e) {
      print('FirebaseChatRepository getMessages error: $e');
      return [];
    }
  }

  @override
  Future<void> sendMessage(Message message) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      // Update last message in chat room
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(message.chatId)
          .update({
            'lastMessage': message.content,
            'lastMessageTime': message.timestamp.toIso8601String(),
          });
    } catch (e) {
      print('FirebaseChatRepository sendMessage error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('FirebaseChatRepository markAsRead error: $e');
    }
  }

  @override
  Future<void> createChatRoom(ChatRoom chatRoom) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatRoom.id)
          .set(chatRoom.toJson());
    } catch (e) {
      print('FirebaseChatRepository createChatRoom error: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
