import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_hub/features/materials/data/repositories/material_repository.dart';
import 'package:student_hub/features/materials/domain/entities/material_item.dart';

class FirebaseMaterialRepository implements MaterialRepository {
  final FirebaseFirestore _firestore;

  FirebaseMaterialRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<MaterialItem>> getMaterials() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('materials')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MaterialItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('FirebaseMaterialRepository getMaterials error: $e');
      return [];
    }
  }

  @override
  Future<List<MaterialItem>> getMaterialsBySubject(String subjectId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('materials')
          .where('subjectId', isEqualTo: subjectId)
          .get();

      return snapshot.docs
          .map((doc) => MaterialItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('FirebaseMaterialRepository getMaterialsBySubject error: $e');
      return [];
    }
  }

  @override
  Future<List<MaterialItem>> getFavoriteMaterials() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('materials')
          .where('isFavorite', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => MaterialItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('FirebaseMaterialRepository getFavoriteMaterials error: $e');
      return [];
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('materials')
        .doc(id)
        .get();

    if (doc.exists) {
      final currentFavorite = doc.data()?['isFavorite'] as bool? ?? false;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('materials')
          .doc(id)
          .update({'isFavorite': !currentFavorite});
    }
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
