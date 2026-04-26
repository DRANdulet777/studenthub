import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isSent = false;

  void _sendReset() {
    setState(() => isSent = true);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Восстановление пароля')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Сброс пароля', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Укажи email, и мы отправим инструкцию для восстановления.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _sendReset, child: const Text('Отправить инструкцию')),
              ),
              const SizedBox(height: 18),
              if (isSent)
                const Text('Письмо отправлено. Проверьте почту.', style: TextStyle(color: Colors.green)),
              const Spacer(),
              TextButton(onPressed: () => context.go('/login'), child: const Text('Вернуться к входу')),
            ],
          ),
        ),
      ),
    );
  }
}
