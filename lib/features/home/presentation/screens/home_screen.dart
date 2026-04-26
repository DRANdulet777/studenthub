import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_hub/features/notifications/presentation/providers/notification_provider.dart';
import 'package:student_hub/features/schedule/domain/entities/schedule_item.dart';
import 'package:student_hub/features/schedule/presentation/providers/schedule_provider.dart';
import 'package:student_hub/features/tasks/domain/entities/task_item.dart';
import 'package:student_hub/features/tasks/presentation/providers/task_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final scheduleState = ref.watch(scheduleProvider);
    final taskState = ref.watch(taskProvider);
    final notificationState = ref.watch(notificationProvider);
    final userName = authState.user?.fullName ?? 'Студент';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            onPressed: () => context.go('/app/notifications'),
            icon: Badge.count(
              count: notificationState.unreadCount,
              isLabelVisible: notificationState.unreadCount > 0,
              child: const Icon(Icons.notifications_none),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(scheduleProvider);
          ref.invalidate(taskProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Привет, $userName', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('План на сегодня', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            HubCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ближайшая пара', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  scheduleState.isLoading
                      ? const Text('Загрузка...')
                      : scheduleState.error != null
                          ? const Text('Ошибка')
                          : Builder(
                              builder: (context) {
                                final nextClass = _getNextClassToday(scheduleState.schedules);
                                if (nextClass == null) {
                                  return const Text('Сегодня пар нет', style: TextStyle(fontSize: 16));
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nextClass.subjectName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('${nextClass.startTime.hour.toString().padLeft(2, '0')}:${nextClass.startTime.minute.toString().padLeft(2, '0')} - ${nextClass.endTime.hour.toString().padLeft(2, '0')}:${nextClass.endTime.minute.toString().padLeft(2, '0')}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('Ауд. ${nextClass.room}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                                  ],
                                );
                              },
                            ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HubCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Дедлайны', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 14),
                    taskState.isLoading
                        ? const Text('Загрузка...')
                        : taskState.error != null
                            ? const Text('Ошибка')
                            : Text(
                                '${_countActiveDeadlines(taskState.tasks)} задач до срока',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScheduleItem? _getNextClassToday(List<ScheduleItem> schedules) {
    final now = DateTime.now();
    final todayName = _dayName(now.weekday);
    final todaySchedules = schedules
        .where((item) => item.dayOfWeek == todayName)
        .where((item) => _timeToday(item.endTime).isAfter(now))
        .toList()
      ..sort(
        (a, b) => _timeToday(a.startTime).compareTo(_timeToday(b.startTime)),
      );

    return todaySchedules.isEmpty ? null : todaySchedules.first;
  }

  int _countActiveDeadlines(List<TaskItem> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((task) {
      final status = task.status.toString().toLowerCase();
      final isCompleted = status == 'completed' || status == 'выполнено';
      final dueDate = task.dueDate;
      final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

      return !isCompleted && !dueDay.isBefore(today);
    }).length;
  }

  DateTime _timeToday(DateTime value) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, value.hour, value.minute);
  }

  String _dayName(int weekday) {
    const dayNames = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return dayNames[weekday - 1];
  }
}
