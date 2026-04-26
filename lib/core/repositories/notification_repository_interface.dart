/// Абстрактный интерфейс для репозиториев уведомлений
abstract class INotificationRepository {
  /// Получить все уведомления пользователя
  Future<List<dynamic>> getNotifications(String userId);

  /// Получить непрочитанные уведомления
  Future<List<dynamic>> getUnreadNotifications(String userId);

  /// Получить уведомления по типу
  Future<List<dynamic>> getNotificationsByType(String userId, String type);

  /// Создать уведомление (для системы или администраторов)
  Future<void> createNotification(String userId, dynamic notification);

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String userId, String notificationId);

  /// Отметить все уведомления как прочитанные
  Future<void> markAllAsRead(String userId);

  /// Удалить уведомление
  Future<void> deleteNotification(String userId, String notificationId);

  /// Получить настройки уведомлений
  Future<dynamic> getNotificationSettings(String userId);

  /// Обновить настройки уведомлений
  Future<void> updateNotificationSettings(String userId, dynamic settings);

  /// Подписаться на push-уведомления
  Future<void> subscribeToPushNotifications(String userId, String deviceToken);

  /// Отписаться от push-уведомлений
  Future<void> unsubscribeFromPushNotifications(String userId, String deviceToken);
}
