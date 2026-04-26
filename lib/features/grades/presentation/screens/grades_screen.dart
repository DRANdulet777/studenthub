import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/widgets/empty_state.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/core/widgets/loading_state.dart';
import 'package:student_hub/features/grades/domain/entities/grade_item.dart';
import 'package:student_hub/features/grades/presentation/providers/grade_provider.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradeState = ref.watch(gradeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оценки'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'По предметам'),
            Tab(text: 'Все оценки'),
          ],
        ),
      ),
      body: gradeState.isLoading
          ? const LoadingState()
          : gradeState.error != null
              ? Center(child: Text('Ошибка: ${gradeState.error}'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSubjectsView(gradeState),
                    _buildAllGradesView(gradeState),
                  ],
                ),
    );
  }

  Widget _buildSubjectsView(GradeState gradeState) {
    if (gradeState.subjectGrades.isEmpty) {
      return const EmptyState(
        icon: Icons.grade_outlined,
        title: 'Нет оценок',
        message: 'Оценки появятся после проведения контрольных мероприятий',
      );
    }

    return Column(
      children: [
        // Overall average card
        Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Средний балл',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gradeState.overallAverage.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.trending_up,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: gradeState.subjectGrades.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final subjectGrade = gradeState.subjectGrades[index];
              final subject = subjectGrade.subject.isNotEmpty
                  ? subjectGrade.subject
                  : 'Без предмета';
              return HubCard(
                onTap: () => _showSubjectDetails(context, subjectGrade),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getGradeColor(subjectGrade.averageGrade).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          subjectGrade.averageGrade.toStringAsFixed(1),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${subjectGrade.grades.length} оценок',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTrendColor(subjectGrade.trend),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getTrendIcon(subjectGrade.trend),
                                size: 14,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                subjectGrade.trend == 'up' ? 'Рост' :
                                subjectGrade.trend == 'down' ? 'Падение' : 'Стабильно',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllGradesView(GradeState gradeState) {
    if (gradeState.grades.isEmpty) {
      return const EmptyState(
        icon: Icons.grade_outlined,
        title: 'Нет оценок',
        message: 'Оценки появятся после проведения контрольных мероприятий',
      );
    }

    // Sort grades by date (newest first)
    final sortedGrades = List<GradeItem>.from(gradeState.grades)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: sortedGrades.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final grade = sortedGrades[index];
        final subject = grade.subject.isNotEmpty ? grade.subject : 'Без предмета';
        return HubCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getGradeColor(grade.numericGrade).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    grade.grade,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGradeTypeText(grade.type),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${grade.date.day.toString().padLeft(2, '0')}.${grade.date.month.toString().padLeft(2, '0')}.${grade.date.year} · ${grade.teacher}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (grade.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        grade.comment,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 4.5) return Colors.green;
    if (grade >= 3.5) return Colors.orange;
    if (grade >= 2.5) return Colors.yellow;
    return Colors.red;
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  String _getGradeTypeText(String type) {
    switch (type) {
      case 'exam':
        return 'Экзамен';
      case 'test':
        return 'Контрольная';
      case 'homework':
        return 'Домашнее задание';
      case 'project':
        return 'Проект';
      default:
        return type;
    }
  }

  void _showSubjectDetails(BuildContext context, SubjectGrades subjectGrade) {
    final subject = subjectGrade.subject.isNotEmpty
        ? subjectGrade.subject
        : 'Без предмета';

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
                      color: _getGradeColor(subjectGrade.averageGrade).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        subjectGrade.averageGrade.toStringAsFixed(1),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${subjectGrade.grades.length} оценок',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Оценки',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: subjectGrade.grades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final grade = subjectGrade.grades[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getGradeColor(grade.numericGrade).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                grade.grade,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGradeTypeText(grade.type),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${grade.date.day.toString().padLeft(2, '0')}.${grade.date.month.toString().padLeft(2, '0')}.${grade.date.year}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (grade.comment.isNotEmpty)
                                  Text(
                                    grade.comment,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
