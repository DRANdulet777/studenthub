import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_hub/features/auth/presentation/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int pageIndex = 0;

  final pages = const [
    _OnboardingPage(
      title: 'Расписание на неделю',
      subtitle: 'Следи за парами, аудиторией и преподавателями в одном месте.',
      icon: Icons.calendar_month,
    ),
    _OnboardingPage(
      title: 'Задания и дедлайны',
      subtitle: 'Контролируй дедлайны и отмечай завершённые задачи.',
      icon: Icons.task_alt,
    ),
    _OnboardingPage(
      title: 'Учебные материалы',
      subtitle: 'Храни конспекты, презентации и полезные ссылки в одном месте.',
      icon: Icons.folder_shared,
    ),
  ];

  void _nextPage() {
    if (pageIndex < pages.length - 1) {
      setState(() => pageIndex++);
      return;
    }
    ref.read(authProvider.notifier).completeOnboarding();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).completeOnboarding();
                    context.go('/login');
                  },
                  child: const Text('Пропустить'),
                ),
              ),
              Expanded(child: pages[pageIndex]),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: pageIndex == index ? 26 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: pageIndex == index ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(pageIndex == pages.length - 1 ? 'Начать' : 'Далее'),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingPage({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 84, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 28),
        Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center, softWrap: true),
      ],
    );
  }
}
