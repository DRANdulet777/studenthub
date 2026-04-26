import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/features/chat/domain/repositories/chat_repository.dart';
import 'package:student_hub/features/chat/data/repositories/firebase/firebase_chat_repository.dart';
import 'package:student_hub/features/chat/domain/entities/chat_entities.dart';

class ChatState {
  final List<ChatRoom> chatRooms;
  final bool isLoading;
  final String? error;
  final ChatRoom? selectedChat;
  final List<Message> messages;

  ChatState({
    this.chatRooms = const [],
    this.isLoading = false,
    this.error,
    this.selectedChat,
    this.messages = const [],
  });

  ChatState copyWith({
    List<ChatRoom>? chatRooms,
    bool? isLoading,
    String? error,
    ChatRoom? selectedChat,
    List<Message>? messages,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedChat: selectedChat ?? this.selectedChat,
      messages: messages ?? this.messages,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super(ChatState()) {
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final chatRooms = await _repository.getChatRooms();
      state = state.copyWith(chatRooms: chatRooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> selectChat(String chatId) async {
    try {
      final chatRoom = await _repository.getChatRoomById(chatId);
      final messages = await _repository.getMessages(chatId);
      state = state.copyWith(selectedChat: chatRoom, messages: messages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendMessage(String content, String senderId, String senderName) async {
    if (state.selectedChat == null) return;

    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: state.selectedChat!.id,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
    );

    try {
      await _repository.sendMessage(message);
      final updatedMessages = [...state.messages, message];
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markMessagesAsRead(String messageId) async {
    if (state.selectedChat == null) return;

    try {
      await _repository.markAsRead(state.selectedChat!.id, messageId);
      final updatedMessages = state.messages.map((msg) =>
        msg.id == messageId ? msg.copyWith(isRead: true) : msg
      ).toList();
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  int get totalUnreadCount {
    return state.chatRooms.fold(0, (sum, chat) => sum + chat.unreadCount);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(FirebaseChatRepository()),
);