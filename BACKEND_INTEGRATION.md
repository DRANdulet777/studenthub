# Backend Integration Guide - StudentHub API

Полная документация для интеграции backend API с приложением StudentHub.

## 🔌 Подготовка приложения к API интеграции

### 1. Установите Dio (HTTP клиент)

```yaml
dependencies:
  dio: ^5.3.0
```

```bash
flutter pub add dio
```

### 2. Создайте Dio провайдер

```dart
// lib/core/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/services/auth_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.studenthub.com/v1',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Interceptor для добавления токена
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Обработка ошибок
        print('Error: ${error.message}');
        return handler.next(error);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode}');
        return handler.next(response);
      },
    ),
  );

  return dio;
});

Future<String?> _getAuthToken() async {
  // Получите токен из хранилища
  final user = await AuthStorageService.getUser();
  return null; // Замените на фактический токен
}
```

## 📋 API Endpoints Specification

### Authentication `/api/v1/auth`

#### 1. Login
```
POST /auth/login
Content-Type: application/json

Request:
{
  "email": "student@example.com",
  "password": "password123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "u001",
    "firstName": "Иван",
    "lastName": "Иванов",
    "email": "student@example.com",
    "role": "Студент",
    "faculty": "Прикладная математика",
    "group": "ИВТ-21",
    "avatarUrl": "https://...",
    "createdAt": "2023-09-01T10:00:00Z"
  }
}

Error (401):
{
  "error": "Invalid credentials"
}
```

#### 2. Register
```
POST /auth/register
Content-Type: application/json

Request:
{
  "firstName": "Петр",
  "lastName": "Петров",
  "email": "petr@example.com",
  "password": "password123",
  "role": "Студент",
  "faculty": "Информатика",
  "group": "ПМ-22"
}

Response (201):
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { /* user object */ }
}

Error (400):
{
  "errors": {
    "email": "Email already exists"
  }
}
```

#### 3. Refresh Token
```
POST /auth/refresh
Authorization: Bearer <token>

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}

Error (401):
{
  "error": "Invalid token"
}
```

### Schedule `/api/v1/schedule`

#### Get Schedule
```
GET /schedule?date=2024-04-20&startDate=2024-04-20&endDate=2024-04-26
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "s001",
      "subject": "Математика",
      "startTime": "09:00",
      "endTime": "10:30",
      "date": "2024-04-20",
      "room": "101",
      "building": "Главное здание",
      "teacher": "Проф. Смирнов А.А.",
      "type": "Лекция"
    }
  ],
  "total": 1
}
```

#### Create Schedule (Admin Only)
```
POST /schedule
Authorization: Bearer <token>
Content-Type: application/json

Request:
{
  "subject": "Физика",
  "startTime": "11:00",
  "endTime": "12:30",
  "date": "2024-04-21",
  "room": "202",
  "building": "Лабораторный корпус",
  "teacher": "Доц. Иванов И.И.",
  "type": "Практика"
}

Response (201):
{
  "id": "s002",
  "subject": "Физика",
  /* ... rest of data ... */
}
```

### Tasks `/api/v1/tasks`

#### Get All Tasks
```
GET /tasks?status=in_progress&priority=high&sortBy=dueDate
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "t001",
      "title": "Подготовить презентацию",
      "description": "Техническая презентация на 15 слайдов",
      "status": "in_progress",
      "priority": "high",
      "subject": "Управление проектами",
      "dueDate": "2024-04-25T18:00:00Z",
      "createdAt": "2024-04-15T10:00:00Z",
      "completedAt": null
    }
  ]
}
```

#### Create Task
```
POST /tasks
Authorization: Bearer <token>

Request:
{
  "title": "Выполнить упражнения",
  "description": "Стр. 42-50",
  "subject": "Английский язык",
  "priority": "normal",
  "dueDate": "2024-04-30T23:59:59Z"
}

Response (201):
{
  "id": "t002",
  "title": "Выполнить упражнения",
  /* ... rest of data ... */
}
```

#### Update Task Status
```
PUT /tasks/{id}/status
Authorization: Bearer <token>

Request:
{
  "status": "completed"
}

Response (200):
{
  "id": "t001",
  "status": "completed",
  "completedAt": "2024-04-25T17:30:00Z"
}
```

### Materials `/api/v1/materials`

#### Get Materials
```
GET /materials?type=pdf&subject=mathematics&sortBy=date
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "m001",
      "title": "Лекция 5 - Интегралы",
      "description": "Основные методы интегрирования",
      "subject": "Математика",
      "type": "pdf",
      "url": "https://storage.example.com/lecture5.pdf",
      "uploadedAt": "2024-04-15T10:00:00Z",
      "isFavorite": false,
      "downloads": 45
    }
  ]
}
```

#### Add to Favorites
```
POST /materials/{id}/favorite
Authorization: Bearer <token>

Response (200):
{
  "id": "m001",
  "isFavorite": true
}
```

### Grades `/api/v1/grades`

#### Get All Grades
```
GET /grades?subject={subject_id}
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "g001",
      "subjectId": "math",
      "subjectName": "Математика",
      "grade": "4",
      "numericGrade": 4.0,
      "type": "exam",
      "date": "2024-04-10",
      "teacher": "Проф. Смирнов",
      "comment": "Отличное решение",
      "weight": 1.5
    }
  ],
  "overallAverage": 3.8,
  "subjects": [
    {
      "subjectId": "math",
      "subjectName": "Математика",
      "averageGrade": 4.1,
      "trend": "up"
    }
  ]
}
```

### Chats `/api/v1/chats`

#### Get Chats
```
GET /chats
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "c001",
      "name": "Группа ИВТ-21",
      "description": "Общий чат группы",
      "members": 28,
      "lastMessage": {
        "id": "msg_001",
        "sender": "Иван Иванов",
        "text": "Каким-то сообщение",
        "timestamp": "2024-04-20T15:30:00Z"
      },
      "unreadCount": 3
    }
  ]
}
```

#### Get Messages
```
GET /chats/{chatId}/messages?limit=50&offset=0
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "msg_001",
      "chatId": "c001",
      "senderId": "u001",
      "senderName": "Иван Иванов",
      "senderAvatar": "https://...",
      "text": "Привет всем!",
      "timestamp": "2024-04-20T10:00:00Z",
      "isRead": true
    }
  ]
}
```

#### Send Message
```
POST /chats/{chatId}/messages
Authorization: Bearer <token>

Request:
{
  "text": "Новое сообщение"
}

Response (201):
{
  "id": "msg_002",
  "chatId": "c001",
  "senderId": "u001",
  "text": "Новое сообщение",
  "timestamp": "2024-04-20T15:45:00Z"
}
```

### Notifications `/api/v1/notifications`

#### Get Notifications
```
GET /notifications?limit=20&offset=0
Authorization: Bearer <token>

Response (200):
{
  "data": [
    {
      "id": "n001",
      "title": "Новая оценка",
      "message": "Оценка по Математике",
      "type": "grade_posted",
      "priority": "normal",
      "isRead": false,
      "createdAt": "2024-04-20T14:00:00Z",
      "actionUrl": "/app/grades"
    }
  ],
  "unreadCount": 5
}
```

#### Mark as Read
```
PUT /notifications/{id}/read
Authorization: Bearer <token>

Response (200):
{
  "id": "n001",
  "isRead": true
}
```

## 🔄 Замена Mock Repositories на API

### Пример: Auth Repository

**Before (Mock):**
```dart
// lib/features/auth/data/repositories/mock_auth_repository.dart
class MockAuthRepository implements AuthRepository {
  Future<User> login(String email, String password) async {
    // Mock реализация
  }
}
```

**After (API):**
```dart
// lib/features/auth/data/repositories/api_auth_repository.dart
import 'package:dio/dio.dart';

class ApiAuthRepository implements AuthRepository {
  final Dio _dio;
  
  ApiAuthRepository(this._dio);
  
  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;
      
      // Сохраните токен
      await AuthStorageService.saveToken(token);
      
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
```

### Обновите провайдер:
```dart
// lib/features/auth/presentation/providers/auth_provider.dart

// Используйте API вместо Mock
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiAuthRepository(dio);  // Замените MockAuthRepository на ApiAuthRepository
});
```

## 🔐 Обработка ошибок API

```dart
try {
  final user = await _repository.login(email, password);
  // ...
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Неверные учетные данные
    throw Exception('Invalid credentials');
  } else if (e.response?.statusCode == 500) {
    // Ошибка сервера
    throw Exception('Server error');
  } else if (e.type == DioExceptionType.connectionTimeout) {
    // Превышено время ожидания
    throw Exception('Connection timeout');
  }
} catch (e) {
  throw Exception('Unknown error');
}
```

## 📊 Модели данных для API

### User Model
```json
{
  "id": "string",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "role": "string",
  "faculty": "string",
  "group": "string",
  "avatarUrl": "string",
  "createdAt": "ISO8601 datetime"
}
```

### Task Model
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "subject": "string",
  "priority": "low|normal|high",
  "status": "pending|in_progress|completed|overdue",
  "dueDate": "ISO8601 datetime",
  "createdAt": "ISO8601 datetime",
  "completedAt": "ISO8601 datetime or null"
}
```

## 🚀 Deployment

### Environment Variables
```bash
# .env файл
API_BASE_URL=https://api.studenthub.com/v1
API_TIMEOUT=30000
LOG_LEVEL=info
```

### Build для Release:
```bash
# iOS
flutter build ios -t lib/main.dart --release

# Android
flutter build apk -t lib/main.dart --release

# Web
flutter build web -t lib/main.dart --release
```

## ✅ Checklist перед деплоем

- [ ] Все MockRepository заменены на API
- [ ] Dio интерцепторы настроены
- [ ] Обработка ошибок реализована
- [ ] Токены сохраняются безопасно
- [ ] Логирование настроено
- [ ] SSL pinning добавлен (если нужно)
- [ ] Переменные окружения установлены
- [ ] Тесты пройдены

---

**Контакт**: api-support@studenthub.com