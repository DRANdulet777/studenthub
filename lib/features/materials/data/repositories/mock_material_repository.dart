import 'dart:async';
import 'package:student_hub/features/materials/domain/entities/material_item.dart';

class MockMaterialRepository {
  final List<MaterialItem> _materials = [];

  MockMaterialRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _materials.addAll([
      MaterialItem(
        id: 'm001',
        title: 'Теория вероятностей — лекции',
        subjectId: 'sub005',
        subjectName: 'Математика',
        fileUrl: 'https://example.com/lecture1.pdf',
        type: 'Документы',
        description: 'Полный курс лекций по теории вероятностей с примерами и задачами.',
        fileSize: '2.5 MB',
        uploadedAt: now.subtract(const Duration(days: 2)),
        isFavorite: true,
      ),
      MaterialItem(
        id: 'm002',
        title: 'Презентация по вёрстке',
        subjectId: 'sub003',
        subjectName: 'Веб-разработка',
        fileUrl: 'https://example.com/presentation.pptx',
        type: 'Презентации',
        description: 'Презентация с основами HTML и CSS вёрстки.',
        fileSize: '5.1 MB',
        uploadedAt: now.subtract(const Duration(days: 5)),
        isFavorite: false,
      ),
      MaterialItem(
        id: 'm003',
        title: 'Базовый конспект по Java',
        subjectId: 'sub006',
        subjectName: 'Программирование',
        fileUrl: 'https://example.com/notes.docx',
        type: 'Документы',
        description: 'Конспект основных понятий языка Java с примерами кода.',
        fileSize: '1.8 MB',
        uploadedAt: now.subtract(const Duration(days: 8)),
        isFavorite: true,
      ),
      MaterialItem(
        id: 'm004',
        title: 'Видео-лекция по Flutter',
        subjectId: 'sub007',
        subjectName: 'Мобильная разработка',
        fileUrl: 'https://example.com/flutter_video.mp4',
        type: 'Видео',
        description: 'Видео-лекция по основам разработки мобильных приложений на Flutter.',
        fileSize: '45.2 MB',
        uploadedAt: now.subtract(const Duration(days: 1)),
        isFavorite: false,
      ),
      MaterialItem(
        id: 'm005',
        title: 'Лабораторные работы по физике',
        subjectId: 'sub008',
        subjectName: 'Физика',
        fileUrl: 'https://example.com/physics_lab.pdf',
        type: 'Документы',
        description: 'Сборник лабораторных работ по общей физике.',
        fileSize: '3.7 MB',
        uploadedAt: now.subtract(const Duration(days: 12)),
        isFavorite: false,
      ),
    ]);
  }

  Future<List<MaterialItem>> getMaterials() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return List.from(_materials);
  }

  Future<MaterialItem?> getMaterialById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _materials.where((material) => material.id == id).firstOrNull;
  }

  Future<List<MaterialItem>> getMaterialsBySubject(String subjectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _materials.where((material) => material.subjectId == subjectId).toList();
  }

  Future<List<MaterialItem>> getFavoriteMaterials() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _materials.where((material) => material.isFavorite).toList();
  }

  Future<List<MaterialItem>> getRecentMaterials() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _materials.where((material) => material.uploadedAt.isAfter(weekAgo)).toList();
  }

  Future<void> toggleFavorite(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _materials.indexWhere((material) => material.id == id);
    if (index != -1) {
      _materials[index] = _materials[index].copyWith(
        isFavorite: !_materials[index].isFavorite,
      );
    }
  }

  Future<void> addMaterial(MaterialItem material) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _materials.add(material);
  }

  Future<void> updateMaterial(MaterialItem material) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materials[index] = material;
    }
  }

  Future<void> deleteMaterial(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _materials.removeWhere((material) => material.id == id);
  }
}
