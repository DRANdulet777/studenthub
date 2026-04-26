import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleItem {
  final String id;
  final String subjectId;
  final String subjectName;
  final String teacher;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String dayOfWeek;
  final String type;
  final int colorIndex;

  ScheduleItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.type,
    required this.colorIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': dayOfWeek,
      'subject': subjectName,
      'teacher': teacher,
      'room': room,
      'startTime': _formatTime(startTime),
      'endTime': _formatTime(endTime),
      'type': type,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    final startTime = _parseTime(json['startTime']);
    final endTime = _parseTime(json['endTime']);

    return ScheduleItem(
      id: json['id'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      subjectName:
          json['subject'] as String? ?? json['subjectName'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      room: json['room'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      dayOfWeek: json['day'] as String? ?? json['dayOfWeek'] as String? ?? '',
      type: json['type'] as String? ?? '',
      colorIndex: json['colorIndex'] as int? ?? 0,
    );
  }

  static DateTime _parseTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final isoDate = DateTime.tryParse(value);
      if (isoDate != null) return isoDate;

      final parts = value.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
