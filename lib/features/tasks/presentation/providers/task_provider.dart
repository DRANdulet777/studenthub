import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      error: error ?? this.error,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(TaskState()) {
    loadTasks();
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
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(FirebaseTaskRepository()),
);
