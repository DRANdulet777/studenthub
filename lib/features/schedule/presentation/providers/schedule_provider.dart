import 'dart:async';

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

  ScheduleNotifier(this._repository) : super(ScheduleState()) {
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
    state = state.copyWith(isLoading: true);
    _scheduleSubscription?.cancel();
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
    super.dispose();
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(FirebaseScheduleRepository()),
);
