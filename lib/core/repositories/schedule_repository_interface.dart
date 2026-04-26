/// Абстрактный интерфейс для репозиториев расписания
abstract class IScheduleRepository {
  /// Получить все элементы расписания
  Future<List<dynamic>> getSchedules(String userId);

  /// Создать новое расписание
  Future<void> createSchedule(String userId, dynamic schedule);

  /// Обновить расписание
  Future<void> updateSchedule(String userId, String scheduleId, dynamic schedule);

  /// Удалить расписание
  Future<void> deleteSchedule(String userId, String scheduleId);

  /// получить расписание на конкретный день
  Future<List<dynamic>> getScheduleByDate(String userId, DateTime date);

  /// Получить расписание на неделю
  Future<List<dynamic>> getWeeklySchedule(String userId, DateTime startDate);
}
