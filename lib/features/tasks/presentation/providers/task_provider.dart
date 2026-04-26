import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/services/local_notification_service.dart';
import 'package:student_hub/features/notifications/data/repositories/firebase/firebase_notification_repository.dart';
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';
import 'package:student_hub/features/notifications/domain/repositories/notification_repository.dart';
import 'package:student_hub/features/tasks/data/repositories/task_repository.dart';
import 'package:student_hub/features/tasks/data/repositories/firebase/firebase_task_repository.dart';
import 'package:student_hub/features/tasks/domain/entities/task_item.dart';

class TaskState {
  final List<TaskItem> tasks;
  final bool isLoading;
  final String? error;

  TaskState({this.tasks = const [], this.isLoading = false, this.error});

  TaskState copyWith({List<TaskItem>? tasks, bool? isLoading, String? error}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final LocalNotificationService _localNotifications;
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<TaskItem>>? _taskSubscription;
  StreamSubscription<User?>? _authSubscription;
  final Set<String> _knownTaskIds = {};
  bool _hasReceivedInitialSnapshot = false;
  String? _activeUserId;

  TaskNotifier(
    this._repository, {
    LocalNotificationService? localNotifications,
    NotificationRepository? notificationRepository,
  }) : _localNotifications = localNotifications ?? LocalNotificationService(),
       _notificationRepository =
           notificationRepository ?? FirebaseNotificationRepository(),
       super(TaskState()) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        clearTasks();
      } else {
        watchTasks();
      }
    });
    watchTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void watchTasks() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      clearTasks();
      return;
    }

    if (_activeUserId == userId && _taskSubscription != null) {
      return;
    }

    _taskSubscription?.cancel();
    _taskSubscription = null;
    _activeUserId = userId;
    _hasReceivedInitialSnapshot = false;
    _knownTaskIds.clear();

    state = state.copyWith(isLoading: true, error: null);
    _taskSubscription = _repository.watchTasks().listen(
      (tasks) {
        unawaited(_notifyAboutNewTasks(tasks));
        state = state.copyWith(tasks: tasks, isLoading: false, error: null);
      },
      onError: (Object error) {
        state = state.copyWith(error: error.toString(), isLoading: false);
      },
    );
  }

  void clearTasks() {
    _taskSubscription?.cancel();
    _taskSubscription = null;
    _activeUserId = null;
    _knownTaskIds.clear();
    _hasReceivedInitialSnapshot = false;
    state = TaskState();
  }

  Future<void> _notifyAboutNewTasks(List<TaskItem> tasks) async {
    final currentIds = tasks.map((task) => task.id).where((id) => id.isNotEmpty).toSet();
    if (!_hasReceivedInitialSnapshot) {
      _knownTaskIds
        ..clear()
        ..addAll(currentIds);
      _hasReceivedInitialSnapshot = true;
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) return;

    for (final task in tasks) {
      if (task.id.isEmpty || _knownTaskIds.contains(task.id)) continue;
      if (await _notificationRepository.hasNotificationForSource(task.id)) {
        continue;
      }

      final title = task.title.trim().isEmpty ? 'Без названия' : task.title.trim();
      await _localNotifications.showNewTaskNotification(
        taskTitle: title,
        taskId: task.id,
      );
      await _notificationRepository.createNotification(
        NotificationItem(
          id: task.id,
          title: 'Новый дедлайн',
          message: 'Добавлена задача: $title',
          type: NotificationType.taskDeadline,
          createdAt: DateTime.now(),
          actionUrl: '/app/tasks',
          sourceId: task.id,
        ),
      );
    }

    _knownTaskIds
      ..clear()
      ..addAll(currentIds);
  }

  Future<void> updateTaskStatus(String id, String status) async {
    try {
      final task = state.tasks.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(status: status);
      await _repository.updateTask(id, updatedTask);
      final tasks = await _repository.getTasks();
      state = state.copyWith(tasks: tasks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addTask(TaskItem task) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addTask(task);
      final tasks = await _repository.getTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      final tasks = await _repository.getTasks();
      state = state.copyWith(tasks: tasks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<TaskItem> getTasksByStatus(String status) {
    return state.tasks.where((task) => task.status == status).toList();
  }

  List<TaskItem> getOverdueTasks() {
    final now = DateTime.now();
    return state.tasks
        .where(
          (task) => task.dueDate.isBefore(now) && task.status != 'Выполнено',
        )
        .toList();
  }

  List<TaskItem> getUpcomingTasks() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return state.tasks
        .where(
          (task) =>
              task.dueDate.isAfter(now) && task.dueDate.isBefore(nextWeek),
        )
        .toList();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(FirebaseTaskRepository()),
);
