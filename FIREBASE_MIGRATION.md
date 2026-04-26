# Миграция с Mock на Firebase репозитории

## Общий процесс

Каждый модуль (Auth, Schedule, Tasks, Materials, Chat, Grades, Profile, Notifications) имеет свой Mock репозиторий. Для миграции на Firebase нужно:

1. **Создать Firebase репозиторий** (реализует тот же интерфейс)
2. **Обновить провайдер** для использования Firebase версии
3. **Протестировать** функциональность
4. **Повторить** для каждого модуля

## Пример миграции Authentication

### 1. Текущая структура (Mock)

```dart
// lib/features/auth/data/repositories/mock_auth_repository.dart
class MockAuthRepository implements AuthRepository {
  // реализация с локальными данными
}

// lib/features/auth/presentation/providers/auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // <- используется Mock
});
```

### 2. Создать Firebase версию

```dart
// lib/features/auth/data/repositories/firebase/firebase_auth_repository.dart
class FirebaseAuthRepository implements AuthRepository {
  // реализация с Firebase
}
```

### 3. Обновить провайдер

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(); // <- используется Firebase
});

// или условно выбирать:
const USE_FIREBASE = true;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return USE_FIREBASE
      ? FirebaseAuthRepository()
      : MockAuthRepository();
});
```

### 4. Обновить импорты (если нужно)

```dart
import 'package:student_hub/features/auth/data/repositories/firebase/firebase_auth_repository.dart';
```

## Приоритет миграции модулей

### Фаза 1: Critical (Критичные)
1. **Auth** - требуется для всего остального
2. **User Profile** - для связи с остальными данными

### Фаза 2: Core (Основные)
3. **Schedule** - основная функция
4. **Tasks** - основная функция
5. **Materials** - основная функция

### Фаза 3: Additional (Дополнительные)
6. **Chat** - требует real-time (Stream)
7. **Grades** - только чтение для студентов
8. **Notifications** - может быть локальным или сетевым

## Проверка работы при миграции каждого модуля

```bash
# 1. Запустить анализ кода
flutter analyze

# 2. Запустить приложение
flutter run

# 3. Протестировать функциональность:
# -登登, регистрация, выход
# - CRUD операции (create, read, update, delete)
# - Фильтрация и поиск
# - Real-time обновления (для чата)

# 4. Проверить логи в Android Studio
# - Firebase инициализация
# - Ошибки сетевых запросов
# - Правила безопасности Firestore
```

## Возможные проблемы и решения

### 1. "ProviderScope not found"
**Решение:** Убедиться, что `ProviderScope` оборачивает приложение в `main.dart`

### 2. Firebase инициализация не завершена
**Решение:** Убедиться, что `await Firebase.initializeApp()` вызывается в `main()` перед запуском приложения

### 3. Firestore правила безопасности не позволяют доступ
**Решение:** Обновить правила в Firebase Console или использовать тестовый режим временно

### 4. "Missing google-services.json"
**Решение:** Скачать файл из Firebase Console и скопировать в `android/app/`

## Мониторинг Firebase

### Firebase Console
https://console.firebase.google.com -> Проект StudentHub

**Что проверять:**
- **Authentication:** Список пользователей, методы входа
- **Firestore:** Структура данных, размер базы
- **Storage:** Загруженные файлы
- **Cloud Messaging:** Статус отправки уведомлений

### Android Studio Logcat
```
# Поиск Firebase ошибок
logcat | grep -i firebase

# Поиск Firestore ошибок
logcat | grep -i firestore
```

## Environment переменные (опционально)

Для удобства можно добавить переменную окружения выбора версии репозитория:

```dart
// lib/config/environment.dart
class Environment {
  static const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: false);
}

// Использование:
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return Environment.useFirebase
      ? FirebaseAuthRepository()
      : MockAuthRepository();
});
```

Запуск:
```bash
flutter run --dart-define=USE_FIREBASE=true
```

## Откат на Mock (если что-то пошло не так)

1. Если Firebase не работает, можно быстро откатиться на Mock:

```dart
// В auth_provider.dart
return MockAuthRepository(); // <- откат
```

2. Потом найти и исправить ошибку
3. Миграция на Firebase

## Timeframe

Примерное время для миграции одного модуля:
- **Простые модули** (Profile, Grades, Notifications): 30-60 минут
- **Средние модули** (Schedule, Tasks, Materials): 1-2 часа с тестированием
- **Сложные модули** (Chat с real-time): 2-3 часа с тестированием Stream
- **Общее время:** ~10-15 часов полной миграции всех модулей

