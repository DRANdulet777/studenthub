import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final DateTime dueDate;
  final String status;
  final String priority;
  final List<String> attachments;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.attachments = const [],
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    DateTime? dueDate,
    String? status,
    String? priority,
    List<String>? attachments,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'attachments': attachments,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final dueDate = json['dueDate'];

    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      dueDate: _parseDate(dueDate),
      status: json['status'] as String,
      priority: json['priority'] as String,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
