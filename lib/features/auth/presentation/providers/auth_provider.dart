import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/services/auth_storage_service.dart';
import 'package:student_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:student_hub/features/auth/data/repositories/firebase/firebase_auth_repository.dart';
import 'package:student_hub/features/auth/domain/entities/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool hasCompletedOnboarding;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.hasCompletedOnboarding = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? hasCompletedOnboarding,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    // Загружаем состояние онбординга
    final hasCompletedOnboarding =
        await AuthStorageService.getOnboardingCompleted();
    state = state.copyWith(hasCompletedOnboarding: hasCompletedOnboarding);

    // Загружаем сохраненного пользователя
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(user: user, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String faculty,
    required String group,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
        faculty: faculty,
        group: group,
      );
      state = state.copyWith(user: user, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = state.copyWith(user: null, isLoading: false);
  }

  Future<void> refreshCurrentUser() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String faculty,
    required String group,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        faculty: faculty,
        group: group,
      );
      state = state.copyWith(user: user, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await AuthStorageService.saveOnboardingCompleted(true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(FirebaseAuthRepository()),
);
