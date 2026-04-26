import 'package:student_hub/features/tasks/domain/entities/task_item.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasks();
  Future<TaskItem> addTask(TaskItem task);
  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(String id, TaskItem task);
  Future<void> deleteTask(String id);
}
