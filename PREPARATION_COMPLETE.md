# StudentHub - Подготовка проекта к Firebase ✅

**Дата:** 21 апреля 2026 г.  
**Статус:** Готово к интеграции Firebase  
**Версия:** v1.0.0

## 📋 Что было сделано

### ✅ 1. Добавлены Firebase зависимости

Обновлен `pubspec.yaml` со следующими пакетами:
```yaml
firebase_core: ^2.24.2              # Ядро Firebase
firebase_auth: ^4.15.3              # Аутентификация
cloud_firestore: ^4.13.6            # База данных
firebase_messaging: ^14.7.10        # Push-уведомления
firebase_storage: ^11.5.6           # Облачное хранилище
```

### ✅ 2. Инициализирован Firebase в проекте

- Обновлен `lib/main.dart` для инициализации Firebase при запуске
- Создан `lib/firebase_options.dart` с шаблоном конфигурации
- Firebase инициализируется ДО запуска приложения

### ✅ 3. Созданы интерфейсы репозиториев

В `lib/core/repositories/` созданы интерфейсы для всех модулей:
- `schedule_repository_interface.dart` - Расписание
- `task_repository_interface.dart` - Задачи
- `material_repository_interface.dart` - Материалы
- `chat_repository_interface.dart` - Чаты
- `grade_repository_interface.dart` - Оценки
- `profile_repository_interface.dart` - Профиль
- `notification_repository_interface.dart` - Уведомления

### ✅ 4. Подготовлена Firebase реализация Auth

Создана шаблонная версия Firebase репозитория:
- `lib/features/auth/data/repositories/firebase/firebase_auth_repository.dart`
- Готова к замене Mock версии при подключении Firebase

### ✅ 5. Созданы документацы по настройке

- `FIREBASE_SETUP.md` - Полная инструкция по настройке Firebase
- `FIREBASE_MIGRATION.md` - План миграции модулей с Mock на Firebase

### ✅ 6. Зависимости загружены

Запущен `flutter pub get` - все Firebase пакеты установлены

## 🚀 Текущее состояние

**Mock режим:** ✅ Работает  
**Firebase готов:** ✅ Да  
**Интерфейсы определены:** ✅ Да  
**Примеры кода:** ✅ Да  

## 📝 Следующие шаги

### 1. Настроить Firebase (одноразово)
```bash
# Установить FlutterFire CLI
dart pub global activate flutterfire_cli

# На ПК Linux/Mac (если есть Android SDK и Firebase CLI)
flutterfire configure
```

### 2. Получить конфигурацию
1. Перейти в [Firebase Console](https://console.firebase.google.com)
2. Создать проект "StudentHub"
3. Добавить Android приложение
4. Скачать `google-services.json`
5. Поместить в `android/app/`

### 3. Обновить `firebase_options.dart`
Заменить dummy данные на реальные из Firebase Console

### 4. Протестировать инициализацию
```bash
flutter run
```

## 🔄 Как перейти на Firebase

### Для Authentication (Auth)

1. **Текущее состояние:**
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // <- Mock версия
});
```

2. **После настройки Firebase:**
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(); // <- Firebase версия
});
```

3. **Добавить импорт:**
```dart
import 'package:student_hub/features/auth/data/repositories/firebase/firebase_auth_repository.dart';
```

4. **Повторить для других модулей** (Schedule, Tasks, Materials, Chat, Grades, Profile, Notifications)

## 📚 Структура Firestore

Для корректной работы создайте следующие коллекции:

```
firestore/
├── users/
│   └── {userId}/
│       ├── firstName, lastName, email, role
│       ├── faculty, group, avatarUrl
│       └── createdAt
├── schedules/
├── tasks/
├── materials/
├── chats/
├── grades/
└── notifications/
```

Читайте `FIREBASE_SETUP.md` для полных спецификаций.

## ⚙️ Правила безопасности Firestore

**Тестовый режим (во время разработки):**
```
allow read, write: if true;
```

**Production (когда готово):**
```firestore
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

Полные правила см. в `FIREBASE_SETUP.md`.

## 🧪 Тестирование

### Локальное тестирование (Mock)
```bash
flutter run
```

### Тестирование с Firebase Emulator (опционально)
```bash
firebase emulators:start
```

### Тестирование на реальном Firebase
1. Убедиться, что сервисы включены в Firebase Console
2. Заменить Mock на Firebase репозитории
3. Запустить `flutter run`

## 📦 Файловая структура после подготовки

```
lib/
├── firebase_options.dart                    # NEW - конфигурация Firebase
├── main.dart                                # UPDATED - инициализация Firebase
├── core/
│   └── repositories/                        # NEW - интерфейсы репозиториев
│       ├── schedule_repository_interface.dart
│       ├── task_repository_interface.dart
│       ├── material_repository_interface.dart
│       ├── chat_repository_interface.dart
│       ├── grade_repository_interface.dart
│       ├── profile_repository_interface.dart
│       └── notification_repository_interface.dart
└── features/
    └── auth/
        └── data/
            └── repositories/
                ├── mock_auth_repository.dart        # Mock версия
                └── firebase/
                    └── firebase_auth_repository.dart # NEW - Firebase версия
```

## 🎯 Инструкции для демонстрации

1. **Текущее состояние** (Mock режим):
   ```bash
   flutter run
   ```
   - Приложение работает с локальными данными
   - Вся функциональность доступна
   - Идеально для демонстрации UI/UX

2. **После подключения Firebase**:
   - Данные синхронизируются с облаком
   - Возможна работа на нескольких устройствах
   - Real-time обновления (для чата)

## ⚠️ Важные примечания

1. **Firebase конфигурация** требует реальных данных из Firebase Console
2. **Mock режим** полностью функционален для разработки и демонстрации
3. **Миграция** можно выполнять постепенно (один модуль за раз)
4. **Откат** на Mock можно выполнить в любой момент (если что-то пошло не так)

## 📞 Поддержка

**Обратитесь к:**
- `FIREBASE_SETUP.md` для детальной инструкции по настройке
- `FIREBASE_MIGRATION.md` для плана миграции модулей
- [Firebase Documentation](https://firebase.google.com/docs)

---

✅ **Проект полностью подготовлен к подключению Firebase!**

Вы можете:
1. Продолжать разработку с Mock данными
2. В любой момент перейти на Firebase, следуя инструкциям выше
3. Тестировать целиком перед тем, как переезжать на реальную БД

