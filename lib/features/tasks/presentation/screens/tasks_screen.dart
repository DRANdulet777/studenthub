import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/widgets/empty_state.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/core/widgets/loading_state.dart';
import 'package:student_hub/features/tasks/domain/entities/task_item.dart';
import 'package:student_hub/features/tasks/presentation/providers/task_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Все';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Все'),
            Tab(text: 'В работе'),
            Tab(text: 'Просрочено'),
            Tab(text: 'Выполнено'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Все', child: Text('Все приоритеты')),
              const PopupMenuItem(value: 'Высокий', child: Text('Высокий')),
              const PopupMenuItem(value: 'Средний', child: Text('Средний')),
              const PopupMenuItem(value: 'Низкий', child: Text('Низкий')),
            ],
          ),
        ],
      ),
      body: taskState.isLoading
          ? const LoadingState()
          : taskState.error != null
          ? Center(child: Text('Ошибка: ${taskState.error}'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTasksList(taskState.tasks, _selectedFilter),
                _buildTasksList(
                  ref.read(taskProvider.notifier).getTasksByStatus('В работе'),
                  _selectedFilter,
                ),
                _buildTasksList(
                  ref.read(taskProvider.notifier).getOverdueTasks(),
                  _selectedFilter,
                ),
                _buildTasksList(
                  ref.read(taskProvider.notifier).getTasksByStatus('Выполнено'),
                  _selectedFilter,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksList(List<TaskItem> tasks, String filter) {
    final filteredTasks = filter == 'Все'
        ? tasks
        : tasks.where((task) => task.priority == filter).toList();

    if (filteredTasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt,
        title: 'Нет задач',
        message: 'Все задачи выполнены или нет задач с выбранными фильтрами',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: filteredTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return HubCard(
          onTap: () => _showTaskDetails(context, task),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getPriorityIcon(task.priority),
                  color: _getPriorityColor(task.priority),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.status == 'Выполнено'
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.status,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.flag,
                          size: 16,
                          color: _getPriorityColor(task.priority),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.priority,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _getPriorityColor(task.priority),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    if (task.subjectName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.subjectName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (task.status != 'Выполнено')
                Checkbox(
                  value: false,
                  onChanged: (value) => ref
                      .read(taskProvider.notifier)
                      .updateTaskStatus(task.id, 'Выполнено'),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Высокий':
        return Colors.red;
      case 'Средний':
        return Colors.orange;
      case 'Низкий':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Высокий':
        return Icons.flag;
      case 'Средний':
        return Icons.flag_outlined;
      case 'Низкий':
        return Icons.outlined_flag;
      default:
        return Icons.flag_outlined;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Выполнено':
        return Colors.green;
      case 'Просрочено':
        return Colors.red;
      case 'В работе':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showTaskDetails(BuildContext context, TaskItem task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPriorityIcon(task.priority),
                      color: _getPriorityColor(task.priority),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        if (task.subjectName.isNotEmpty)
                          Text(
                            task.subjectName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      task.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Описание',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      'Приоритет',
                      task.priority,
                      _getPriorityIcon(task.priority),
                      _getPriorityColor(task.priority),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      'Дедлайн',
                      '${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year}',
                      Icons.calendar_today,
                      null,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (task.status != 'Выполнено')
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(taskProvider.notifier)
                        .updateTaskStatus(task.id, 'Выполнено');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Отметить как выполненное'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color? iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const AddTaskDialog(),
    );
  }
}

class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _subjectController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _descriptionFocusNode;
  late final FocusNode _subjectFocusNode;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _priority = 'Средний';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _subjectController = TextEditingController();
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _subjectFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _subjectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить задачу'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              focusNode: _subjectFocusNode,
              decoration: const InputDecoration(
                labelText: 'Предмет',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Приоритет',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Высокий', child: Text('Высокий')),
                DropdownMenuItem(value: 'Средний', child: Text('Средний')),
                DropdownMenuItem(value: 'Низкий', child: Text('Низкий')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Дедлайн'),
              subtitle: Text(
                '${_dueDate.day}.${_dueDate.month}.${_dueDate.year}',
              ),
              onTap: _pickDueDate,
            ),
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
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Future<void> _pickDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (!mounted || selectedDate == null) return;

    setState(() => _dueDate = selectedDate);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final subjectName = _subjectController.text.trim();
    final dueDate = _dueDate;
    final priority = _priority;

    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    final task = TaskItem(
      id: '',
      title: title,
      description: description,
      subjectId: '',
      subjectName: subjectName,
      dueDate: dueDate,
      status: 'В работе',
      priority: priority,
    );

    await ref.read(taskProvider.notifier).addTask(task);
    if (!mounted) return;

    Navigator.of(context).pop();
  }
}
