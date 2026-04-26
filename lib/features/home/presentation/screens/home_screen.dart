import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_hub/features/materials/presentation/providers/materials_provider.dart';
import 'package:student_hub/features/notifications/presentation/providers/notification_provider.dart';
import 'package:student_hub/features/schedule/presentation/providers/schedule_provider.dart';
import 'package:student_hub/features/tasks/presentation/providers/task_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final scheduleState = ref.watch(scheduleProvider);
    final taskState = ref.watch(taskProvider);
    final materialState = ref.watch(materialsProvider);
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
          ref.invalidate(materialsProvider);
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
                                final today = scheduleState.schedules.where((item) => item.dayOfWeek == 'Понедельник').toList();
                                if (today.isEmpty) {
                                  return const Text('Сегодня пар нет', style: TextStyle(fontSize: 16));
                                }
                                final nextClass = today.first;
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
            Row(
              children: [
                Expanded(
                  child: HubCard(
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
                                      '${taskState.tasks.where((task) => task.dueDate.isBefore(DateTime.now().add(const Duration(days: 3)))).where((task) => task.status != 'Выполнено').length} задач до срока',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: HubCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Материалы', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 14),
                          materialState.isLoading
                              ? const Text('Загрузка...')
                              : materialState.error != null
                                  ? const Text('Ошибка')
                                  : Text(
                                      '${materialState.materials.length} новых материалов',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Последние материалы', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            materialState.isLoading
                ? const Text('Загрузка...')
                : materialState.error != null
                    ? const Text('Ошибка загрузки материалов')
                    : Builder(
                        builder: (context) {
                          if (materialState.materials.isEmpty) {
                            return const Text('Нет материалов');
                          }
                          return Column(
                            children: materialState.materials.take(3).map((material) => HubCard(
                              child: ListTile(
                                title: Text(material.title),
                                subtitle: Text(material.subjectName),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                            )).toList(),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
