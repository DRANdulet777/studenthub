import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/services/local_notification_service.dart';
import 'package:student_hub/features/notifications/data/repositories/firebase/firebase_notification_repository.dart';
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';
import 'package:student_hub/features/notifications/domain/repositories/notification_repository.dart';
import 'package:student_hub/features/grades/domain/repositories/grade_repository.dart';
import 'package:student_hub/features/grades/data/repositories/firebase/firebase_grade_repository.dart';
import 'package:student_hub/features/grades/domain/entities/grade_item.dart';

class GradeState {
  final List<GradeItem> grades;
  final List<SubjectGrades> subjectGrades;
  final double overallAverage;
  final bool isLoading;
  final String? error;

  GradeState({
    this.grades = const [],
    this.subjectGrades = const [],
    this.overallAverage = 0.0,
    this.isLoading = false,
    this.error,
  });

  GradeState copyWith({
    List<GradeItem>? grades,
    List<SubjectGrades>? subjectGrades,
    double? overallAverage,
    bool? isLoading,
    String? error,
  }) {
    return GradeState(
      grades: grades ?? this.grades,
      subjectGrades: subjectGrades ?? this.subjectGrades,
      overallAverage: overallAverage ?? this.overallAverage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GradeNotifier extends StateNotifier<GradeState> {
  final GradeRepository _repository;
  final LocalNotificationService _localNotifications;
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<GradeItem>>? _gradesSubscription;
  final Set<String> _knownGradeIds = {};
  bool _hasReceivedInitialSnapshot = false;

  GradeNotifier(
    this._repository, {
    LocalNotificationService? localNotifications,
    NotificationRepository? notificationRepository,
  }) : _localNotifications = localNotifications ?? LocalNotificationService(),
       _notificationRepository =
           notificationRepository ?? FirebaseNotificationRepository(),
       super(GradeState()) {
    _watchGrades();
  }

  @override
  void dispose() {
    _gradesSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadGrades() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final grades = await _repository.getGrades();
      _setGrades(grades);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void _watchGrades() {
    state = state.copyWith(isLoading: true, error: null);
    _gradesSubscription = _repository.watchGrades().listen(
      _setGrades,
      onError: (Object error) {
        state = state.copyWith(error: error.toString(), isLoading: false);
      },
    );
  }

  void _setGrades(List<GradeItem> grades) {
    unawaited(_notifyAboutNewGrades(grades));
    state = state.copyWith(
      grades: grades,
      subjectGrades: _buildSubjectGrades(grades),
      overallAverage: _calculateAverage(grades),
      isLoading: false,
      error: null,
    );
  }

  Future<void> _notifyAboutNewGrades(List<GradeItem> grades) async {
    final currentIds = grades
        .map((grade) => grade.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    if (!_hasReceivedInitialSnapshot) {
      _knownGradeIds
        ..clear()
        ..addAll(currentIds);
      _hasReceivedInitialSnapshot = true;
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) return;

    for (final grade in grades) {
      if (grade.id.isEmpty || _knownGradeIds.contains(grade.id)) continue;
      if (await _notificationRepository.hasNotificationForSource(grade.id)) {
        continue;
      }

      final subject = grade.subject.trim().isNotEmpty
          ? grade.subject.trim()
          : grade.subjectName.trim().isNotEmpty
              ? grade.subjectName.trim()
              : 'Без предмета';
      await _localNotifications.showGradeNotification(
        subject: subject,
        grade: grade.grade,
        subjectId: grade.id,
      );
      await _notificationRepository.createNotification(
        NotificationItem(
          id: grade.id,
          title: 'Новая оценка',
          message: '$subject: ${grade.grade}',
          type: NotificationType.gradePosted,
          createdAt: DateTime.now(),
          actionUrl: '/app/grades',
          sourceId: grade.id,
        ),
      );
    }

    _knownGradeIds
      ..clear()
      ..addAll(currentIds);
  }

  List<GradeItem> getGradesBySubject(String subjectId) {
    return state.grades.where((grade) => grade.subjectId == subjectId).toList();
  }

  List<GradeItem> getRecentGrades() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return state.grades
        .where((grade) => grade.date.isAfter(thirtyDaysAgo))
        .toList();
  }

  String getGradeTrend(String subjectId) {
    final subjectGrade = state.subjectGrades
        .where((sg) => sg.subjectId == subjectId)
        .firstOrNull;
    return subjectGrade?.trend ?? 'stable';
  }

  Color getGradeColor(double grade) {
    if (grade >= 4.5) return const Color(0xFF4CAF50); // Green
    if (grade >= 3.5) return const Color(0xFFFF9800); // Orange
    if (grade >= 2.5) return const Color(0xFFFFC107); // Yellow
    return const Color(0xFFF44336); // Red
  }

  String formatGrade(double grade) {
    return grade.toStringAsFixed(1);
  }

  List<SubjectGrades> _buildSubjectGrades(List<GradeItem> grades) {
    final groupedBySubject = <String, List<GradeItem>>{};
    for (final grade in grades) {
      final subjectKey = grade.subjectId.isNotEmpty
          ? grade.subjectId
          : grade.subject;
      groupedBySubject.putIfAbsent(subjectKey, () => []).add(grade);
    }

    return groupedBySubject.entries.map((entry) {
      final subjectGrades = entry.value;
      return SubjectGrades(
        subjectId: entry.key,
        subject: subjectGrades.first.subject,
        subjectName: subjectGrades.first.subjectName,
        grades: subjectGrades,
        averageGrade: _calculateAverage(subjectGrades),
        trend: 'stable',
      );
    }).toList();
  }

  double _calculateAverage(List<GradeItem> grades) {
    if (grades.isEmpty) return 0.0;
    var totalWeighted = 0.0;
    var totalWeight = 0.0;
    for (final grade in grades) {
      totalWeighted += grade.numericGrade * grade.weight;
      totalWeight += grade.weight;
    }
    return totalWeight > 0 ? totalWeighted / totalWeight : 0.0;
  }
}

final gradeProvider = StateNotifierProvider<GradeNotifier, GradeState>(
  (ref) => GradeNotifier(FirebaseGradeRepository()),
);
