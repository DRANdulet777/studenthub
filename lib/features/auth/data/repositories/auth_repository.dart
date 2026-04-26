import 'package:student_hub/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String faculty,
    required String group,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String faculty,
    required String group,
  });
}
