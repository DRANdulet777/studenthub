enum NotificationType {
  taskDeadline('task_deadline', 'Дедлайн задачи'),
  scheduleReminder('schedule_reminder', 'Напоминание о расписании'),
  materialUpdate('material_update', 'Обновление материалов'),
  gradePosted('grade_posted', 'Новая оценка'),
  chatMessage('chat_message', 'Сообщение в чате'),
  system('system', 'Системное уведомление');

  const NotificationType(this.value, this.displayName);

  final String value;
  final String displayName;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

enum NotificationPriority {
  low('low', 'Низкий'),
  normal('normal', 'Обычный'),
  high('high', 'Высокий'),
  urgent('urgent', 'Срочный');

  const NotificationPriority(this.value, this.displayName);

  final String value;
  final String displayName;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.data,
    this.actionUrl,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'actionUrl': actionUrl,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromString(json['type'] as String),
      priority: NotificationPriority.fromString(json['priority'] as String? ?? 'normal'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt'] as String) : null,
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class NotificationSettings {
  final bool enabled;
  final bool taskDeadlines;
  final bool scheduleReminders;
  final bool materialUpdates;
  final bool gradeNotifications;
  final bool chatMessages;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.enabled = true,
    this.taskDeadlines = true,
    this.scheduleReminders = true,
    this.materialUpdates = true,
    this.gradeNotifications = true,
    this.chatMessages = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? taskDeadlines,
    bool? scheduleReminders,
    bool? materialUpdates,
    bool? gradeNotifications,
    bool? chatMessages,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      taskDeadlines: taskDeadlines ?? this.taskDeadlines,
      scheduleReminders: scheduleReminders ?? this.scheduleReminders,
      materialUpdates: materialUpdates ?? this.materialUpdates,
      gradeNotifications: gradeNotifications ?? this.gradeNotifications,
      chatMessages: chatMessages ?? this.chatMessages,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'taskDeadlines': taskDeadlines,
      'scheduleReminders': scheduleReminders,
      'materialUpdates': materialUpdates,
      'gradeNotifications': gradeNotifications,
      'chatMessages': chatMessages,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      taskDeadlines: json['taskDeadlines'] as bool? ?? true,
      scheduleReminders: json['scheduleReminders'] as bool? ?? true,
      materialUpdates: json['materialUpdates'] as bool? ?? true,
      gradeNotifications: json['gradeNotifications'] as bool? ?? true,
      chatMessages: json['chatMessages'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings();
  }
}