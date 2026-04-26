# Подготовка StudentHub к Firebase

## 1. Что было сделано

✅ **Добавлены Firebase зависимости в pubspec.yaml:**
- `firebase_core: ^2.24.2` - ядро Firebase
- `firebase_auth: ^4.15.3` - аутентификация
- `cloud_firestore: ^4.13.6` - база данных
- `firebase_messaging: ^14.7.10` - push-уведомления
- `firebase_storage: ^11.5.6` - облачное хранилище

✅ **Обновлен main.dart:**
- Импорт Firebase
- Инициализация Firebase при запуске приложения
- Загрузка конфигурации из firebase_options.dart

✅ **Создан firebase_options.dart:**
- Шаблон для конфигурации Firebase для всех платформ
- Готов к замене на реальные данные из Firebase Console

✅ **Созданы интерфейсы репозиториев в lib/core/repositories/:**
- `schedule_repository_interface.dart` - интерфейс для расписания
- `task_repository_interface.dart` - интерфейс для задач
- `material_repository_interface.dart` - интерфейс для материалов
- `chat_repository_interface.dart` - интерфейс для чатов
- `grade_repository_interface.dart` - интерфейс для оценок
- `profile_repository_interface.dart` - интерфейс для профиля
- `notification_repository_interface.dart` - интерфейс для уведомлений

## 2. Следующие шаги для подключения Firebase

### Шаг 1: Создать проект в Firebase Console
1. Перейти на https://console.firebase.google.com
2. Нажать "Создать проект"
3. Назвать проект (например, "StudentHub")
4. Включить Google Analytics (опционально)
5. Создать проект

### Шаг 2: Настроить Android
1. В Firebase Console нажать "Добавить приложение" → выбрать Android
2. Заполнить пакет приложения: `com.example.student_hub`
3. Скачать `google-services.json`
4. Скопировать файл в `android/app/`
5. Firebase автоматически обновит `android/build.gradle`

### Шаг 3: Обновить firebase_options.dart
1. Установить FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. На ПК с настроенным Firebase SDK запустить:
```bash
flutterfire configure
```

3. Выбрать платформы (Android, iOS, web)
4. Скопировать сгенерированный код в `firebase_options.dart`

### Шаг 4: Запустить `flutter pub get`
```bash
flutter pub get
```

### Шаг 5: Включить сервисы в Firebase Console

**Authentication:**
- Перейти в Authentication → Sign-in method
- Включить Email/Password
- Опционально: Google Sign-In

**Firestore Database:**
- Перейти в Firestore Database
- Нажать "Создать базу данных"
- Выбрать регион (например, us-central1)
- Начать в режиме тестирования (позже настроить правила безопасности)

**Cloud Storage:**
- Перейти в Storage
- Нажать "Начало работы"
- Выбрать тот же регион

**Cloud Messaging:**
- Перейти в Cloud Messaging
- Получить "Server API Key" (для отправки push-уведомлений)

### Шаг 6: Настроить правила Firestore Security
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Пользователь может читать/писать только свои данные
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    match /schedules/{document=**} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    match /tasks/{document=**} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    match /materials/{document=**} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    match /grades/{document=**} {
      allow read: if request.auth.uid == resource.data.userId;
    }
    
    // Чаты доступны всем участникам
    match /chats/{chatId} {
      allow read: if request.auth.uid in resource.data.members;
      allow create: if request.auth.uid in request.resource.data.members;
      match /messages/{messageId} {
        allow read: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.members;
        allow create: if request.auth.uid == request.resource.data.userId;
      }
    }
    
    match /notifications/{document=**} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 3. Структура коллекций Firestore

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── fullName: string
│       ├── avatar: string
│       ├── bio: string
│       ├── group: string
│       ├── semester: number
│       └── settings: object
│
├── schedules/
│   └── {scheduleId}/
│       ├── userId: string
│       ├── subject: string
│       ├── type: string (lecture|practice|lab)
│       ├── dayOfWeek: number (0-6)
│       ├── startTime: timestamp
│       ├── endTime: timestamp
│       ├── room: string
│       ├── teacher: string
│       └── createdAt: timestamp
│
├── tasks/
│   └── {taskId}/
│       ├── userId: string
│       ├── title: string
│       ├── description: string
│       ├── status: string (todo|in_progress|review|completed)
│       ├── priority: string (low|medium|high)
│       ├── dueDate: timestamp
│       ├── subject: string
│       ├── attachments: array
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── materials/
│   └── {materialId}/
│       ├── userId: string
│       ├── title: string
│       ├── description: string
│       ├── type: string (pdf|document|link|video)
│       ├── fileUrl: string
│       ├── isFavorite: boolean
│       ├── subject: string
│       ├── uploadedAt: timestamp
│       └── lastModified: timestamp
│
├── chats/
│   └── {chatId}/
│       ├── name: string
│       ├── description: string
│       ├── members: array<string> (userIds)
│       ├── createdBy: string
│       ├── createdAt: timestamp
│       ├── lastMessage: string
│       ├── lastMessageTime: timestamp
│       └── messages/
│           └── {messageId}/
│               ├── userId: string
│               ├── userName: string
│               ├── message: string
│               ├── timestamp: timestamp
│               ├── attachments: array
│               └── reactions: map
│
├── grades/
│   └── {gradeId}/
│       ├── userId: string
│       ├── subject: string
│       ├── grade: number (0-100)
│       ├── maxGrade: number
│       ├── weight: number
│       ├── date: timestamp
│       ├── teacher: string
│       ├── description: string
│       └── createdAt: timestamp
│
└── notifications/
    └── {notificationId}/
        ├── userId: string
        ├── type: string (event|task|grade|system)
        ├── title: string
        ├── message: string
        ├── read: boolean
        ├── relatedId: string
        ├── createdAt: timestamp
        └── settings: object
```

## 4. Когда нужно использовать Mock vs Firebase репозитории

**Mock репозитории (текущая реализация):**
- Разработка локально без Firebase
- Тестирование UI без сетевых задержек
- Демонстрация прототипа

**Firebase репозитории (после настройки):**
- Production среда
- Real-time синхронизация данных
- Для использования в реальном приложении

## 5. Переход на Firebase репозитории

1. Создать `FirebaseAuthRepository` в `lib/features/auth/data/repositories/`
2. Имплементировать методы из интерфейса `IAuthRepository`
3. Обновить provнры в `auth_provider.dart` для использования Firebase версии
4. Повторить для других модулей (Schedule, Task, Material, Chat, Grade, Profile, Notification)
5. Протестировать каждый модуль

## 6. Текущее состояние проекта

✅ Готово:
- Clean Architecture с интерфейсами репозиториев
- Mock реализации для разработки
- Структура папок и файлов
- Firebase зависимости добавлены
- firebase_options.dart создан

⏳ Следующие шаги:
- Настроить Firebase в консоли
- Получить google-services.json
- Обновить firebase_options.dart реальными данными
- Создать Firebase реализации репозиториев

