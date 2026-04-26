import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GradeItem {
  final String id;
  final String subjectId;
  final String subject;
  final String subjectName;
  final String grade;
  final String type; // 'exam', 'test', 'homework', 'project'
  final DateTime date;
  final String teacher;
  final String comment;
  final double weight; // вес оценки для расчета среднего

  GradeItem({
    required this.id,
    required this.subjectId,
    this.subject = '',
    required this.subjectName,
    required this.grade,
    required this.type,
    required this.date,
    required this.teacher,
    this.comment = '',
    this.weight = 1.0,
  });

  GradeItem copyWith({
    String? id,
    String? subjectId,
    String? subject,
    String? subjectName,
    String? grade,
    String? type,
    DateTime? date,
    String? teacher,
    String? comment,
    double? weight,
  }) {
    return GradeItem(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subject: subject ?? this.subject,
      subjectName: subjectName ?? this.subjectName,
      grade: grade ?? this.grade,
      type: type ?? this.type,
      date: date ?? this.date,
      teacher: teacher ?? this.teacher,
      comment: comment ?? this.comment,
      weight: weight ?? this.weight,
    );
  }

  double get numericGrade {
    // Convert letter grades to numeric (assuming 5-point system)
    switch (grade.toUpperCase()) {
      case 'A':
      case '5':
        return 5.0;
      case 'B':
      case '4':
        return 4.0;
      case 'C':
      case '3':
        return 3.0;
      case 'D':
      case '2':
        return 2.0;
      case 'F':
      case '1':
        return 1.0;
      default:
        return double.tryParse(grade) ?? 0.0;
    }
  }

  Color getGradeColor(BuildContext context) {
    final numeric = numericGrade;
    if (numeric >= 4.5) return Colors.green;
    if (numeric >= 3.5) return Colors.orange;
    if (numeric >= 2.5) return Colors.yellow;
    return Colors.red;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subject': subject,
      'subjectName': subjectName,
      'grade': grade,
      'type': type,
      'date': date.toIso8601String(),
      'teacher': teacher,
      'comment': comment,
      'weight': weight,
    };
  }

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    final rawGrade = json['grade'];
    final rawDate = json['date'];

    return GradeItem(
      id: json['id'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      subjectName:
          json['subjectName'] as String? ?? json['subject'] as String? ?? '',
      grade: rawGrade is num
          ? _formatNumber(rawGrade)
          : rawGrade?.toString() ?? '',
      type: json['type'] as String? ?? '',
      date: _parseDate(rawDate),
      teacher: json['teacher'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  static String _formatNumber(num value) {
    final asDouble = value.toDouble();
    if (asDouble == asDouble.truncateToDouble()) {
      return asDouble.toInt().toString();
    }
    return asDouble.toString();
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

class SubjectGrades {
  final String subjectId;
  final String subject;
  final String subjectName;
  final List<GradeItem> grades;
  final double averageGrade;
  final String trend; // 'up', 'down', 'stable'

  SubjectGrades({
    required this.subjectId,
    this.subject = '',
    required this.subjectName,
    required this.grades,
    required this.averageGrade,
    required this.trend,
  });

  double get weightedAverage {
    if (grades.isEmpty) return 0.0;
    double totalWeighted = 0.0;
    double totalWeight = 0.0;
    for (final grade in grades) {
      totalWeighted += grade.numericGrade * grade.weight;
      totalWeight += grade.weight;
    }
    return totalWeight > 0 ? totalWeighted / totalWeight : 0.0;
  }
}
