/// Абстрактный интерфейс для репозиториев чатов
abstract class IChatRepository {
  /// Получить все чаты пользователя
  Future<List<dynamic>> getChats(String userId);

  /// Создать новый чат
  Future<void> createChat(String userId, dynamic chat);

  /// Получить сообщения чата (с потоком для real-time)
  Stream<List<dynamic>> getChatMessages(String chatId);

  /// Отправить сообщение
  Future<void> sendMessage(String chatId, dynamic message);

  /// Получить участников чата
  Future<List<dynamic>> getChatMembers(String chatId);

  /// Добавить участника в чат
  Future<void> addMemberToChat(String chatId, String userId);

  /// Удалить участника из чата
  Future<void> removeMemberFromChat(String chatId, String userId);

  /// Обновить информацию о чате
  Future<void> updateChat(String chatId, dynamic chatData);

  /// Удалить чат
  Future<void> deleteChat(String chatId);

  /// Получить последнее сообщение в чате
  Future<dynamic> getLastMessage(String chatId);
}
