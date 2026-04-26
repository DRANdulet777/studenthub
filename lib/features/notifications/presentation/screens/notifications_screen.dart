import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:student_hub/core/widgets/empty_state.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/core/widgets/loading_state.dart';
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';
import 'package:student_hub/features/notifications/presentation/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              onPressed: () => _showClearAllDialog(context, ref),
              icon: const Icon(Icons.clear_all),
              tooltip: 'Очистить все',
            ),
          IconButton(
            onPressed: () => _showSettingsDialog(context, ref),
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Все',
              icon: Badge.count(
                count: notificationState.notifications.length,
                isLabelVisible: notificationState.notifications.isNotEmpty,
                child: const Icon(Icons.notifications),
              ),
            ),
            Tab(
              text: 'Непрочитанные',
              icon: Badge.count(
                count: notificationState.unreadCount,
                isLabelVisible: notificationState.unreadCount > 0,
                child: const Icon(Icons.notifications_active),
              ),
            ),
          ],
        ),
      ),
      body: notificationState.isLoading
          ? const LoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllNotifications(notificationState),
                _buildUnreadNotifications(notificationState),
              ],
            ),
    );
  }

  Widget _buildAllNotifications(NotificationState state) {
    if (state.notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'Нет уведомлений',
        message: 'Здесь будут отображаться ваши уведомления',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).loadNotifications();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _buildNotificationCard(notification, context, ref);
        },
      ),
    );
  }

  Widget _buildUnreadNotifications(NotificationState state) {
    if (state.unreadNotifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_active_outlined,
        title: 'Нет непрочитанных уведомлений',
        message: 'Все уведомления прочитаны',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).loadNotifications();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.unreadNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = state.unreadNotifications[index];
          return _buildNotificationCard(notification, context, ref);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, BuildContext context, WidgetRef ref) {
    return HubCard(
      onTap: () => _handleNotificationTap(notification, context, ref),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _getPriorityIcon(notification.priority),
                      size: 14,
                      color: _getPriorityColor(notification.priority),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPriorityText(notification.priority),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, notification, ref),
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Text('Отметить как прочитанное'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Удалить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification, BuildContext context, WidgetRef ref) async {
    // Отмечаем как прочитанное
    if (!notification.isRead) {
      await ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    // Переходим по actionUrl если есть
    if (notification.actionUrl != null) {
      context.go(notification.actionUrl!);
    }
  }

  void _handleMenuAction(String action, NotificationItem notification, WidgetRef ref) async {
    switch (action) {
      case 'mark_read':
        await ref.read(notificationProvider.notifier).markAsRead(notification.id);
        break;
      case 'delete':
        await ref.read(notificationProvider.notifier).deleteNotification(notification.id);
        break;
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все уведомления?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(notificationProvider.notifier).clearAllNotifications();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(notificationProvider).settings;

    showDialog(
      context: context,
      builder: (context) => _NotificationSettingsDialog(
        initialSettings: settings,
        onSettingsChanged: (newSettings) {
          ref.read(notificationProvider.notifier).updateSettings(newSettings);
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskDeadline:
        return Colors.red;
      case NotificationType.scheduleReminder:
        return Colors.blue;
      case NotificationType.materialUpdate:
        return Colors.green;
      case NotificationType.gradePosted:
        return Colors.orange;
      case NotificationType.chatMessage:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskDeadline:
        return Icons.alarm;
      case NotificationType.scheduleReminder:
        return Icons.schedule;
      case NotificationType.materialUpdate:
        return Icons.folder;
      case NotificationType.gradePosted:
        return Icons.grade;
      case NotificationType.chatMessage:
        return Icons.chat;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Icons.arrow_downward;
      case NotificationPriority.normal:
        return Icons.remove;
      case NotificationPriority.high:
        return Icons.arrow_upward;
      case NotificationPriority.urgent:
        return Icons.priority_high;
    }
  }

  String _getPriorityText(NotificationPriority priority) {
    return priority.displayName;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else {
      return DateFormat('dd.MM').format(date);
    }
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  final NotificationSettings initialSettings;
  final Function(NotificationSettings) onSettingsChanged;

  const _NotificationSettingsDialog({
    required this.initialSettings,
    required this.onSettingsChanged,
  });

  @override
  State<_NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<_NotificationSettingsDialog> {
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Настройки уведомлений'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Включить уведомления'),
              value: _settings.enabled,
              onChanged: (value) => setState(() => _settings = _settings.copyWith(enabled: value)),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Дедлайны задач'),
              value: _settings.taskDeadlines,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(taskDeadlines: value)) : null,
            ),
            SwitchListTile(
              title: const Text('Напоминания о расписании'),
              value: _settings.scheduleReminders,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(scheduleReminders: value)) : null,
            ),
            SwitchListTile(
              title: const Text('Обновления материалов'),
              value: _settings.materialUpdates,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(materialUpdates: value)) : null,
            ),
            SwitchListTile(
              title: const Text('Новые оценки'),
              value: _settings.gradeNotifications,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(gradeNotifications: value)) : null,
            ),
            SwitchListTile(
              title: const Text('Сообщения в чате'),
              value: _settings.chatMessages,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(chatMessages: value)) : null,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Звук'),
              value: _settings.soundEnabled,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(soundEnabled: value)) : null,
            ),
            SwitchListTile(
              title: const Text('Вибрация'),
              value: _settings.vibrationEnabled,
              onChanged: _settings.enabled ? (value) => setState(() => _settings = _settings.copyWith(vibrationEnabled: value)) : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            widget.onSettingsChanged(_settings);
            Navigator.of(context).pop();
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
