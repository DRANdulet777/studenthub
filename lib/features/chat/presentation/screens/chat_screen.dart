import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/widgets/empty_state.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/core/widgets/loading_state.dart';
import 'package:student_hub/features/chat/domain/entities/chat_entities.dart';
import 'package:student_hub/features/chat/presentation/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            onPressed: () => _showCreateChatDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: chatState.isLoading
          ? const LoadingState()
          : chatState.error != null
              ? Center(child: Text('Ошибка: ${chatState.error}'))
              : chatState.chatRooms.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'Нет чатов',
                      message: 'Начните общение с одногруппниками',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: chatState.chatRooms.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat = chatState.chatRooms[index];
                        return HubCard(
                          onTap: () => _openChat(context, chat),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: chat.isGroup
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
                                    : Theme.of(context).colorScheme.secondary.withOpacity(0.14),
                                child: chat.isGroup
                                    ? Icon(
                                        Icons.group,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : Text(
                                        chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chat.name,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (chat.unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              chat.unreadCount.toString(),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chat.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTime(chat.lastMessageTime),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}';
    }
  }

  void _openChat(BuildContext context, ChatRoom chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chat: chat),
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    // TODO: Implement create chat dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция создания чата будет реализована')),
    );
  }
}

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ChatRoom chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).selectChat(widget.chat.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.chat.isGroup
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.14),
              child: widget.chat.isGroup
                  ? Icon(
                      Icons.group,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Text(
                      widget.chat.name.isNotEmpty ? widget.chat.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.chat.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(child: Text('Нет сообщений'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isOwnMessage = message.senderId == 'user1'; // TODO: Get current user ID

                      return Align(
                        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isOwnMessage
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!widget.chat.isGroup && !isOwnMessage)
                                Text(
                                  message.senderName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isOwnMessage
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                message.content,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isOwnMessage
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMessageTime(message.timestamp),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isOwnMessage
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(
        content,
        'user1', // TODO: Get current user ID
        'Вы', // TODO: Get current user name
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
