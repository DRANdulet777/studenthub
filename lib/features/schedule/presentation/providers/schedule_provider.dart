import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/features/schedule/data/repositories/firebase/firebase_schedule_repository.dart';
import 'package:student_hub/features/schedule/data/repositories/schedule_repository.dart';
import 'package:student_hub/features/schedule/domain/entities/schedule_item.dart';

class ScheduleState {
  final List<ScheduleItem> schedules;
  final bool isLoading;
  final String? error;

  ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    List<ScheduleItem>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;
  StreamSubscription<List<ScheduleItem>>? _scheduleSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUserId;

  ScheduleNotifier(this._repository) : super(ScheduleState()) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        clearSchedules();
      } else {
        watchSchedules();
      }
    });
    watchSchedules();
  }

  Future<void> loadSchedules() async {
    state = state.copyWith(isLoading: true);
    try {
      final schedules = await _repository.getSchedule();
      state = state.copyWith(
        schedules: schedules,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void watchSchedules() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      clearSchedules();
      return;
    }

    if (_activeUserId == userId && _scheduleSubscription != null) {
      return;
    }

    _scheduleSubscription?.cancel();
    _scheduleSubscription = null;
    _activeUserId = userId;

    state = state.copyWith(isLoading: true, error: null);
    _scheduleSubscription = _repository.watchSchedule().listen(
      (schedules) {
        state = state.copyWith(
          schedules: schedules,
          isLoading: false,
          error: null,
        );
      },
      onError: (Object error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  void clearSchedules() {
    _scheduleSubscription?.cancel();
    _scheduleSubscription = null;
    _activeUserId = null;
    state = ScheduleState();
  }

  Future<void> addLesson(ScheduleItem lesson) async {
    await _repository.addLesson(lesson);
  }

  Future<void> updateLesson(ScheduleItem lesson) async {
    await _repository.updateLesson(lesson);
  }

  Future<void> deleteLesson(String lessonId) async {
    await _repository.deleteLesson(lessonId);
  }

  List<ScheduleItem> getSchedulesForDay(String dayOfWeek) {
    return state.schedules
        .where((schedule) => schedule.dayOfWeek == dayOfWeek)
        .toList();
  }

  List<ScheduleItem> getTodaySchedules() {
    final today = DateTime.now().weekday;
    final dayNames = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    final todayName = dayNames[today - 1];
    return getSchedulesForDay(todayName);
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(FirebaseScheduleRepository()),
);
