import 'dart:async';
import 'package:student_hub/core/services/auth_storage_service.dart';
import 'package:student_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:student_hub/features/auth/domain/entities/user.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  MockAuthRepository() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _currentUser = await AuthStorageService.getUser();
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Имитация проверки учетных данных
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Неверный email или пароль');
    }

    _currentUser = User(
      id: 'u001',
      firstName: 'Алексей',
      lastName: 'Смирнов',
      email: email,
      role: 'Студент',
      faculty: 'Прикладная математика',
      group: 'ИВТ-21',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      createdAt: DateTime.now().subtract(const Duration(days: 320)),
    );

    // Сохраняем пользователя в постоянное хранилище
    await AuthStorageService.saveUser(_currentUser!);

    return _currentUser!;
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String faculty,
    required String group,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Имитация проверки существования пользователя
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Все поля обязательны для заполнения');
    }

    _currentUser = User(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      faculty: faculty,
      group: group,
      avatarUrl:
          'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 50 + 1}',
      createdAt: DateTime.now(),
    );

    // Сохраняем пользователя в постоянное хранилище
    await AuthStorageService.saveUser(_currentUser!);

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    // Очищаем сохраненные данные
    await AuthStorageService.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser == null) {
      await _loadUserFromStorage();
    }
    return _currentUser;
  }

  @override
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String faculty,
    required String group,
  }) async {
    if (_currentUser == null) {
      await _loadUserFromStorage();
    }
    if (_currentUser == null) {
      throw Exception('Not authenticated');
    }

    _currentUser = _currentUser!.copyWith(
      firstName: firstName,
      lastName: lastName,
      faculty: faculty,
      group: group,
    );
    await AuthStorageService.saveUser(_currentUser!);
    return _currentUser!;
  }
}
