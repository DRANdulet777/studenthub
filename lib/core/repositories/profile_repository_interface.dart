/// Абстрактный интерфейс для репозиториев профиля
abstract class IProfileRepository {
  /// Получить профиль пользователя
  Future<dynamic> getProfile(String userId);

  /// Обновить профиль пользователя
  Future<void> updateProfile(String userId, dynamic profileData);

  /// Загрузить аватар пользователя
  Future<String> uploadAvatar(String userId, dynamic file);

  /// Удалить аватар пользователя
  Future<void> deleteAvatar(String userId);

  /// Получить настройки профиля
  Future<dynamic> getProfileSettings(String userId);

  /// Обновить настройки профиля
  Future<void> updateProfileSettings(String userId, dynamic settings);

  /// Получить информацию об учебных группах
  Future<List<dynamic>> getGroups(String userId);

  /// Получить информацию об учебном периоде
  Future<dynamic> getAcademicPeriod(String userId);
}
