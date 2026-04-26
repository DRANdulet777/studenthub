import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/features/notifications/data/repositories/firebase/firebase_notification_repository.dart';
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';
import 'package:student_hub/features/notifications/domain/repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationItem> notifications;
  final List<NotificationItem> unreadNotifications;
  final NotificationSettings settings;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadNotifications = const [],
    this.settings = const NotificationSettings(),
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => unreadNotifications.length;

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    List<NotificationItem>? unreadNotifications,
    NotificationSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const NotificationState()) {
    loadNotifications();
    loadSettings();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _repository.getNotifications();
      final unreadNotifications = await _repository.getUnreadNotifications();

      state = state.copyWith(
        notifications: notifications,
        unreadNotifications: unreadNotifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.getNotificationSettings();
      state = state.copyWith(settings: settings);
    } catch (e) {
      // Не показываем ошибку при загрузке настроек
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications(); // Перезагружаем список
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _repository.clearAllNotifications();
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await _repository.saveNotificationSettings(settings);
      state = state.copyWith(settings: settings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? actionUrl,
    DateTime? scheduledAt,
  }) async {
    try {
      final notification = NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        scheduledAt: scheduledAt,
        data: data,
        actionUrl: actionUrl,
      );

      if (scheduledAt != null) {
        await _repository.scheduleNotification(notification);
      } else {
        await _repository.createNotification(notification);
      }

      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Вспомогательные методы для создания типовых уведомлений
  Future<void> createTaskDeadlineNotification({
    required String taskTitle,
    required Duration timeLeft,
    required String taskId,
  }) async {
    final hours = timeLeft.inHours;
    final message = hours > 0
        ? 'Задача "$taskTitle" истекает через $hours ${hours == 1 ? 'час' : hours < 5 ? 'часа' : 'часов'}'
        : 'Задача "$taskTitle" истекает через ${timeLeft.inMinutes} минут';

    await createNotification(
      title: 'Дедлайн приближается',
      message: message,
      type: NotificationType.taskDeadline,
      priority: NotificationPriority.high,
      data: {'taskId': taskId},
      actionUrl: '/app/tasks',
    );
  }

  Future<void> createScheduleReminder({
    required String subject,
    required Duration timeLeft,
    required String scheduleId,
  }) async {
    final minutes = timeLeft.inMinutes;
    final message = 'Через $minutes ${minutes == 1 ? 'минуту' : minutes < 5 ? 'минуты' : 'минут'} начнется $subject';

    await createNotification(
      title: 'Напоминание о расписании',
      message: message,
      type: NotificationType.scheduleReminder,
      priority: NotificationPriority.normal,
      data: {'scheduleId': scheduleId},
      actionUrl: '/app/schedule',
    );
  }

  Future<void> createGradeNotification({
    required String subject,
    required String grade,
    required String subjectId,
  }) async {
    await createNotification(
      title: 'Новая оценка',
      message: 'Появилась новая оценка ($grade) по предмету "$subject"',
      type: NotificationType.gradePosted,
      priority: NotificationPriority.normal,
      data: {'subjectId': subjectId, 'grade': grade},
      actionUrl: '/app/grades',
    );
  }

  Future<void> createMaterialUpdateNotification({
    required String courseName,
    required String materialId,
  }) async {
    await createNotification(
      title: 'Обновление материалов',
      message: 'Добавлены новые материалы по курсу "$courseName"',
      type: NotificationType.materialUpdate,
      priority: NotificationPriority.low,
      data: {'materialId': materialId},
      actionUrl: '/app/materials',
    );
  }

  Future<void> createChatMessageNotification({
    required String senderName,
    required String chatId,
  }) async {
    await createNotification(
      title: 'Новое сообщение',
      message: 'У вас новое сообщение от $senderName',
      type: NotificationType.chatMessage,
      priority: NotificationPriority.normal,
      data: {'chatId': chatId, 'sender': senderName},
      actionUrl: '/app/chats',
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirebaseNotificationRepository();
});

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});