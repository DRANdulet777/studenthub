import 'package:student_hub/core/services/local_notification_service.dart';
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';
import 'package:student_hub/features/notifications/domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  final List<NotificationItem> _notifications = [];
  NotificationSettings _settings = const NotificationSettings();

  MockNotificationRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();

    _notifications.addAll([
      NotificationItem(
        id: '1',
        title: 'Дедлайн приближается',
        message: 'Задача "Подготовить презентацию" истекает через 2 часа',
        type: NotificationType.taskDeadline,
        priority: NotificationPriority.high,
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
        data: {'taskId': 'task_1'},
        actionUrl: '/app/tasks',
      ),
      NotificationItem(
        id: '2',
        title: 'Новая оценка',
        message: 'Появилась новая оценка по предмету "Математика"',
        type: NotificationType.gradePosted,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
        data: {'subjectId': 'math', 'grade': '4'},
        actionUrl: '/app/grades',
      ),
      NotificationItem(
        id: '3',
        title: 'Напоминание о расписании',
        message: 'Через 30 минут начнется лекция по "Физике"',
        type: NotificationType.scheduleReminder,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(minutes: 35)),
        isRead: true,
        data: {'scheduleId': 'schedule_1'},
        actionUrl: '/app/schedule',
      ),
      NotificationItem(
        id: '4',
        title: 'Обновление материалов',
        message: 'Добавлены новые материалы по курсу "Программирование"',
        type: NotificationType.materialUpdate,
        priority: NotificationPriority.low,
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: true,
        data: {'materialId': 'material_1'},
        actionUrl: '/app/materials',
      ),
      NotificationItem(
        id: '5',
        title: 'Новое сообщение',
        message: 'У вас новое сообщение в чате группы',
        type: NotificationType.chatMessage,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        data: {'chatId': 'chat_1', 'sender': 'Иван Иванов'},
        actionUrl: '/app/chats',
      ),
    ]);
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<NotificationItem>> getUnreadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _notifications.where((n) => !n.isRead).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<NotificationItem?> getNotificationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notifications.cast<NotificationItem?>().firstWhere(
          (n) => n?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> createNotification(NotificationItem notification) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.add(notification);

    // Показываем локальное уведомление, если настройки позволяют
    if (await isNotificationTypeEnabled(notification.type)) {
      await _showLocalNotification(notification);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> clearAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.clear();
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _settings;
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _settings = settings;
  }

  @override
  Future<void> scheduleNotification(NotificationItem notification) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (notification.scheduledAt != null && await isNotificationTypeEnabled(notification.type)) {
      // Планируем уведомление через локальный сервис
      await _localNotificationService.scheduleNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
        scheduledDate: notification.scheduledAt!,
        payload: notification.actionUrl,
        priority: notification.priority,
      );
    }

    _notifications.add(notification);
  }

  Future<void> _showLocalNotification(NotificationItem notification) async {
    await _localNotificationService.showNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.message,
      payload: notification.actionUrl,
      priority: notification.priority,
    );
  }

  @override
  Future<void> cancelScheduledNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // В mock реализации просто удаляем уведомление
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    await Future.delayed(const Duration(milliseconds: 100));
    switch (type) {
      case NotificationType.taskDeadline:
        return _settings.taskDeadlines;
      case NotificationType.scheduleReminder:
        return _settings.scheduleReminders;
      case NotificationType.materialUpdate:
        return _settings.materialUpdates;
      case NotificationType.gradePosted:
        return _settings.gradeNotifications;
      case NotificationType.chatMessage:
        return _settings.chatMessages;
      case NotificationType.system:
        return _settings.enabled;
    }
  }
}