import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/features/schedule/domain/entities/schedule_item.dart';
import 'package:student_hub/features/schedule/presentation/providers/schedule_provider.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final _weekDays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
  String selectedDay = 'Понедельник';

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLessonDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedDay,
              decoration: const InputDecoration(labelText: 'День недели'),
              items: _weekDays
                  .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedDay = value);
                }
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: scheduleState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : scheduleState.error != null
                  ? Center(child: Text('Ошибка: ${scheduleState.error}'))
                  : Builder(
                      builder: (context) {
                        final filtered = scheduleState.schedules
                            .where((item) => item.dayOfWeek == selectedDay)
                            .toList();
                        if (filtered.isEmpty) {
                          return const Center(
                            child: Text('Нет пар на выбранный день'),
                          );
                        }
                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return HubCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: _colorForIndex(item.colorIndex),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.subjectName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${_formatTime(item.startTime)} — ${_formatTime(item.endTime)}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.teacher}, ${item.room} · ${item.type}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddLessonDialog(
        initialDay: selectedDay,
        weekDays: _weekDays,
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _colorForIndex(int index) {
    const colors = [
      Color(0xFF2D4CF5),
      Color(0xFF40C4FF),
      Color(0xFF8C4CFF),
      Color(0xFF28C76F),
    ];
    return colors[index % colors.length];
  }
}

class AddLessonDialog extends ConsumerStatefulWidget {
  final String initialDay;
  final List<String> weekDays;

  const AddLessonDialog({
    super.key,
    required this.initialDay,
    required this.weekDays,
  });

  @override
  ConsumerState<AddLessonDialog> createState() => _AddLessonDialogState();
}

class _AddLessonDialogState extends ConsumerState<AddLessonDialog> {
  late final TextEditingController _subjectController;
  late final TextEditingController _teacherController;
  late final TextEditingController _roomController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _typeController;
  late String _day;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _day = widget.initialDay;
    _subjectController = TextEditingController();
    _teacherController = TextEditingController();
    _roomController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _typeController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить пару'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _day,
              decoration: const InputDecoration(labelText: 'День недели'),
              items: widget.weekDays
                  .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _day = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Предмет'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teacherController,
              decoration: const InputDecoration(labelText: 'Преподаватель'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Аудитория'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: 'Начало, например 09:00'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(labelText: 'Конец, например 10:20'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Тип'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final teacher = _teacherController.text.trim();
    final room = _roomController.text.trim();
    final type = _typeController.text.trim();
    final startTime = _parseTime(_startTimeController.text.trim());
    final endTime = _parseTime(_endTimeController.text.trim());

    if (subject.isEmpty) {
      setState(() => _error = 'Введите предмет');
      return;
    }
    if (startTime == null || endTime == null) {
      setState(() => _error = 'Введите время в формате ЧЧ:ММ');
      return;
    }
    if (!endTime.isAfter(startTime)) {
      setState(() => _error = 'Время окончания должно быть позже начала');
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    final lesson = ScheduleItem(
      id: '',
      subjectId: '',
      subjectName: subject,
      teacher: teacher,
      room: room,
      startTime: startTime,
      endTime: endTime,
      dayOfWeek: _day,
      type: type,
      colorIndex: widget.weekDays.indexOf(_day),
    );

    try {
      await ref.read(scheduleProvider.notifier).addLesson(lesson);
      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _error = 'Не удалось добавить пару: $e';
      });
    }
  }

  DateTime? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
