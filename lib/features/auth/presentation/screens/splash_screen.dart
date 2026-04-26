import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_hub/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _handleNextRoute);
  }

  void _handleNextRoute() {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      context.go('/app/home');
      return;
    }

    if (authState.hasCompletedOnboarding) {
      context.go('/login');
      return;
    }

    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D4CF5), Color(0xFF40C4FF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 84, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(height: 18),
            Text('StudentHub', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 36, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text('Учебный хаб для современной группы', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16)),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
