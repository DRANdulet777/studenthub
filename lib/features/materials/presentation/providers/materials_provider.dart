import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_hub/features/materials/data/repositories/material_repository.dart';
import 'package:student_hub/features/materials/data/repositories/firebase/firebase_material_repository.dart';
import 'package:student_hub/features/materials/domain/entities/material_item.dart';

class MaterialState {
  final List<MaterialItem> materials;
  final bool isLoading;
  final String? error;

  MaterialState({
    this.materials = const [],
    this.isLoading = false,
    this.error,
  });

  MaterialState copyWith({
    List<MaterialItem>? materials,
    bool? isLoading,
    String? error,
  }) {
    return MaterialState(
      materials: materials ?? this.materials,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MaterialNotifier extends StateNotifier<MaterialState> {
  final MaterialRepository _repository;

  MaterialNotifier(this._repository) : super(MaterialState()) {
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final materials = await _repository.getMaterials();
      state = state.copyWith(materials: materials, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
      final materials = await _repository.getMaterials();
      state = state.copyWith(materials: materials);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<MaterialItem> getMaterialsBySubject(String subjectId) {
    return state.materials.where((material) => material.subjectId == subjectId).toList();
  }

  List<MaterialItem> getFavoriteMaterials() {
    return state.materials.where((material) => material.isFavorite).toList();
  }

  List<MaterialItem> getRecentMaterials() {
    return state.materials
        .where((material) => material.uploadedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
  }
}

final materialsProvider = StateNotifierProvider<MaterialNotifier, MaterialState>(
  (ref) => MaterialNotifier(FirebaseMaterialRepository()),
);
