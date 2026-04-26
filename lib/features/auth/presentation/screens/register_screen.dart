import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_hub/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final facultyController = TextEditingController();
  final groupController = TextEditingController();
  String role = 'Студент';

  void _register() async {
    try {
      await ref.read(authProvider.notifier).register(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            role: role,
            faculty: facultyController.text.trim(),
            group: groupController.text.trim(),
          );
      if (mounted && ref.read(authProvider).user != null) {
        context.go('/app/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка регистрации: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    facultyController.dispose();
    groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Создайте профиль', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Заполните короткую анкету для доступа к StudentHub.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Имя')),
              const SizedBox(height: 16),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Фамилия')),
              const SizedBox(height: 16),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
              const SizedBox(height: 16),
              TextField(controller: facultyController, decoration: const InputDecoration(labelText: 'Факультет')),
              const SizedBox(height: 16),
              TextField(controller: groupController, decoration: const InputDecoration(labelText: 'Группа')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'Студент', child: Text('Студент')),
                  DropdownMenuItem(value: 'Преподаватель', child: Text('Преподаватель')),
                  DropdownMenuItem(value: 'Админ', child: Text('Админ')),
                ],
                onChanged: (value) => setState(() => role = value ?? role),
                decoration: const InputDecoration(labelText: 'Роль'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary, strokeWidth: 2))
                      : const Text('Зарегистрироваться'),
                ),
              ),
              if (authState.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 14),
              TextButton(onPressed: () => context.go('/login'), child: const Text('Уже есть аккаунт? Войти')),
            ],
          ),
        ),
      ),
    );
  }
}
