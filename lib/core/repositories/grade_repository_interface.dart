/// Абстрактный интерфейс для репозиториев оценок
abstract class IGradeRepository {
  /// Получить все оценки пользователя
  Future<List<dynamic>> getGrades(String userId);

  /// Получить оценки по предмету
  Future<List<dynamic>> getGradesBySubject(String userId, String subject);

  /// Создать новую оценку (для преподавателей)
  Future<void> createGrade(String userId, dynamic grade);

  /// Обновить оценку (для преподавателей)
  Future<void> updateGrade(String userId, String gradeId, dynamic grade);

  /// Удалить оценку (для преподавателей)
  Future<void> deleteGrade(String userId, String gradeId);

  /// Получить все предметы пользователя
  Future<List<String>> getSubjects(String userId);

  /// Получить в среднюю оценку по предмету
  Future<double> getAverageGradeBySubject(String userId, String subject);

  /// Получить общую среднюю оценку
  Future<double> getOverallAverageGrade(String userId);

  /// Получить тренд оценок
  Future<List<dynamic>> getGradeTrend(String userId, String subject);
}
