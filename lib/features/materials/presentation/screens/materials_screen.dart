import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/core/widgets/empty_state.dart';
import 'package:student_hub/core/widgets/hub_card.dart';
import 'package:student_hub/core/widgets/loading_state.dart';
import 'package:student_hub/features/materials/domain/entities/material_item.dart';
import 'package:student_hub/features/materials/presentation/providers/materials_provider.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Все';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialState = ref.watch(materialsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Материалы'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Все'),
            Tab(text: 'Избранное'),
            Tab(text: 'Недавние'),
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
              const PopupMenuItem(value: 'Все', child: Text('Все')),
              const PopupMenuItem(value: 'Документы', child: Text('Документы')),
              const PopupMenuItem(value: 'Видео', child: Text('Видео')),
              const PopupMenuItem(value: 'Презентации', child: Text('Презентации')),
            ],
          ),
        ],
      ),
      body: materialState.isLoading
          ? const LoadingState()
          : materialState.error != null
              ? Center(child: Text('Ошибка: ${materialState.error}'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMaterialsList(materialState.materials, _selectedFilter),
                    _buildMaterialsList(ref.read(materialsProvider.notifier).getFavoriteMaterials(), _selectedFilter),
                    _buildMaterialsList(ref.read(materialsProvider.notifier).getRecentMaterials(), _selectedFilter),
                  ],
                ),
    );
  }

  Widget _buildMaterialsList(List<MaterialItem> materials, String filter) {
    final filteredMaterials = filter == 'Все'
        ? materials
        : materials.where((material) => material.type == filter).toList();

    if (filteredMaterials.isEmpty) {
      return const EmptyState(
        icon: Icons.library_books,
        title: 'Нет материалов',
        message: 'Материалы появятся здесь после загрузки',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: filteredMaterials.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = filteredMaterials[index];
        return HubCard(
          onTap: () => _showMaterialDetails(context, item),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMaterialIcon(item.type),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.type} · ${item.subjectName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.uploadedAt.day}.${item.uploadedAt.month}.${item.uploadedAt.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(materialsProvider.notifier).toggleFavorite(item.id),
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'Документы':
        return Icons.description;
      case 'Видео':
        return Icons.video_library;
      case 'Презентации':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showMaterialDetails(BuildContext context, MaterialItem item) {
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMaterialIcon(item.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          item.subjectName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(materialsProvider.notifier).toggleFavorite(item.id),
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: item.isFavorite ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Описание',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
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
                      'Тип',
                      item.type,
                      Icons.category,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      'Размер',
                      item.fileSize,
                      Icons.storage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoChip(
                context,
                'Загружено',
                '${item.uploadedAt.day}.${item.uploadedAt.month}.${item.uploadedAt.year}',
                Icons.calendar_today,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Implement download functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Загрузка начата')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Скачать'),
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

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
}
