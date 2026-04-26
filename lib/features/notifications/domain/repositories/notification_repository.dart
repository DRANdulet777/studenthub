import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';

abstract class NotificationRepository {
  /// Получить все уведомления
  Future<List<NotificationItem>> getNotifications();

  /// Следить за уведомлениями
  Stream<List<NotificationItem>> watchNotifications();

  /// Получить непрочитанные уведомления
  Future<List<NotificationItem>> getUnreadNotifications();

  /// Получить уведомление по ID
  Future<NotificationItem?> getNotificationById(String id);

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String id);

  /// Отметить все уведомления как прочитанные
  Future<void> markAllAsRead();

  /// Создать новое уведомление
  Future<void> createNotification(NotificationItem notification);

  /// Проверить наличие уведомления по исходному документу
  Future<bool> hasNotificationForSource(String sourceId);

  /// Удалить уведомление
  Future<void> deleteNotification(String id);

  /// Очистить все уведомления
  Future<void> clearAllNotifications();

  /// Получить настройки уведомлений
  Future<NotificationSettings> getNotificationSettings();

  /// Сохранить настройки уведомлений
  Future<void> saveNotificationSettings(NotificationSettings settings);

  /// Запланировать уведомление
  Future<void> scheduleNotification(NotificationItem notification);

  /// Отменить запланированное уведомление
  Future<void> cancelScheduledNotification(String id);

  /// Проверить, включены ли уведомления для данного типа
  Future<bool> isNotificationTypeEnabled(NotificationType type);
}
