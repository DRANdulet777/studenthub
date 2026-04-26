/// Абстрактный интерфейс для репозиториев материалов
abstract class IMaterialRepository {
  /// Получить все материалы пользователя
  Future<List<dynamic>> getMaterials(String userId);

  /// Создать новый материал
  Future<void> createMaterial(String userId, dynamic material);

  /// Обновить материал
  Future<void> updateMaterial(String userId, String materialId, dynamic material);

  /// Удалить материал
  Future<void> deleteMaterial(String userId, String materialId);

  /// Получить материалы по типу
  Future<List<dynamic>> getMaterialsByType(String userId, String type);

  /// Получить избранные материалы
  Future<List<dynamic>> getFavoriteMaterials(String userId);

  /// Добавить в избранное
  Future<void> addToFavorite(String userId, String materialId);

  /// Удалить из избранного
  Future<void> removeFromFavorite(String userId, String materialId);

  /// Загрузить файл материала
  Future<String> uploadMaterialFile(String userId, String materialId, dynamic file);

  /// Удалить файл материала
  Future<void> deleteMaterialFile(String userId, String fileId);
}
