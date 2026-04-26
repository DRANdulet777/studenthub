import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Создаем канал уведомлений для Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'student_hub_channel',
      'Student Hub Notifications',
      description: 'Notifications for Student Hub app',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'student_hub_channel',
      'Student Hub Notifications',
      channelDescription: 'Notifications for Student Hub app',
      importance: _getImportance(priority),
      priority: _getAndroidPriority(priority),
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'student_hub_channel',
      'Student Hub Notifications',
      channelDescription: 'Notifications for Student Hub app',
      importance: _getImportance(priority),
      priority: _getAndroidPriority(priority),
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.urgent:
        return Priority.max;
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    // Обработка нажатия на уведомление
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Здесь можно добавить логику навигации или другие действия
      // Например, открыть определенный экран приложения
    }
  }

  // Вспомогательные методы для создания уведомлений разных типов
  Future<void> showTaskDeadlineNotification({
    required String taskTitle,
    required Duration timeLeft,
    required String taskId,
  }) async {
    final hours = timeLeft.inHours;
    final message = hours > 0
        ? 'Задача "$taskTitle" истекает через $hours ${hours == 1 ? 'час' : hours < 5 ? 'часа' : 'часов'}'
        : 'Задача "$taskTitle" истекает через ${timeLeft.inMinutes} минут';

    await showNotification(
      id: taskId.hashCode,
      title: 'Дедлайн приближается',
      body: message,
      payload: '/app/tasks',
      priority: NotificationPriority.high,
    );
  }

  Future<void> showScheduleReminder({
    required String subject,
    required Duration timeLeft,
    required String scheduleId,
  }) async {
    final minutes = timeLeft.inMinutes;
    final message = 'Через $minutes ${minutes == 1 ? 'минуту' : minutes < 5 ? 'минуты' : 'минут'} начнется $subject';

    await showNotification(
      id: scheduleId.hashCode,
      title: 'Напоминание о расписании',
      body: message,
      payload: '/app/schedule',
      priority: NotificationPriority.normal,
    );
  }

  Future<void> showGradeNotification({
    required String subject,
    required String grade,
    required String subjectId,
  }) async {
    await showNotification(
      id: subjectId.hashCode,
      title: 'Новая оценка',
      body: 'Появилась новая оценка ($grade) по предмету "$subject"',
      payload: '/app/grades',
      priority: NotificationPriority.normal,
    );
  }

  Future<void> showMaterialUpdateNotification({
    required String courseName,
    required String materialId,
  }) async {
    await showNotification(
      id: materialId.hashCode,
      title: 'Обновление материалов',
      body: 'Добавлены новые материалы по курсу "$courseName"',
      payload: '/app/materials',
      priority: NotificationPriority.low,
    );
  }

  Future<void> showChatMessageNotification({
    required String senderName,
    required String chatId,
  }) async {
    await showNotification(
      id: chatId.hashCode,
      title: 'Новое сообщение',
      body: 'У вас новое сообщение от $senderName',
      payload: '/app/chats',
      priority: NotificationPriority.normal,
    );
  }
}