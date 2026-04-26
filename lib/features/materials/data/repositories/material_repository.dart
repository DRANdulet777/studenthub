import 'package:student_hub/features/materials/domain/entities/material_item.dart';

abstract class MaterialRepository {
  Future<List<MaterialItem>> getMaterials();
  Future<List<MaterialItem>> getMaterialsBySubject(String subjectId);
  Future<List<MaterialItem>> getFavoriteMaterials();
  Future<void> toggleFavorite(String id);
}