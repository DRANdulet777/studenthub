/// Абстрактный интерфейс для репозиториев задач
abstract class ITaskRepository {
  /// Получить все задачи пользователя
  Future<List<dynamic>> getTasks(String userId);

  /// Создать новую задачу
  Future<void> createTask(String userId, dynamic task);

  /// Обновить задачу
  Future<void> updateTask(String userId, String taskId, dynamic task);

  /// Удалить задачу
  Future<void> deleteTask(String userId, String taskId);

  /// Получить задачи по статусу
  Future<List<dynamic>> getTasksByStatus(String userId, String status);

  /// Получить задачи по приоритету
  Future<List<dynamic>> getTasksByPriority(String userId, String priority);

  /// Получить задачи с дедлайном на сегодня
  Future<List<dynamic>> getTodayTasks(String userId);

  /// Обновить статус задачи
  Future<void> updateTaskStatus(String userId, String taskId, String status);
}
