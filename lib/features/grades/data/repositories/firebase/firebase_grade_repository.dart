import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_hub/features/grades/domain/repositories/grade_repository.dart';
import 'package:student_hub/features/grades/domain/entities/grade_item.dart';

class FirebaseGradeRepository implements GradeRepository {
  final FirebaseFirestore _firestore;

  FirebaseGradeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<GradeItem>> getGrades() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _gradesCollection(
        userId,
      ).orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => _fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('FirebaseGradeRepository getGrades error: $e');
      return [];
    }
  }

  @override
  Stream<List<GradeItem>> watchGrades() {
    final userId = _getCurrentUserId();
    if (userId == null) {
      return Stream.value(const []);
    }

    return _gradesCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<List<GradeItem>> getGradesBySubject(String subjectId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _gradesCollection(userId)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('FirebaseGradeRepository getGradesBySubject error: $e');
      return [];
    }
  }

  @override
  Future<GradeItem?> getGradeById(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return null;

      final doc = await _gradesCollection(userId).doc(id).get();

      return doc.exists ? _fromFirestore(doc) : null;
    } catch (e) {
      debugPrint('FirebaseGradeRepository getGradeById error: $e');
      return null;
    }
  }

  @override
  Future<List<SubjectGrades>> getSubjectGrades() async {
    try {
      return _buildSubjectGrades(await getGrades());
    } catch (e) {
      debugPrint('FirebaseGradeRepository getSubjectGrades error: $e');
      return [];
    }
  }

  @override
  Future<double> getOverallAverage() async {
    try {
      return _calculateAverage(await getGrades());
    } catch (e) {
      debugPrint('FirebaseGradeRepository getOverallAverage error: $e');
      return 0.0;
    }
  }

  double _calculateAverage(List<GradeItem> grades) {
    if (grades.isEmpty) return 0.0;
    double totalWeighted = 0.0;
    double totalWeight = 0.0;
    for (final grade in grades) {
      totalWeighted += grade.numericGrade * grade.weight;
      totalWeight += grade.weight;
    }
    return totalWeight > 0 ? totalWeighted / totalWeight : 0.0;
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>> _gradesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('grades');
  }

  Map<String, dynamic> _withDocumentId(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    return data;
  }

  GradeItem _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = _withDocumentId(doc);
    return GradeItem.fromJson({
      ...data,
      'subject': data['subject'] ?? '',
    });
  }

  List<SubjectGrades> _buildSubjectGrades(List<GradeItem> allGrades) {
    final Map<String, List<GradeItem>> groupedBySubject = {};
    for (final grade in allGrades) {
      final subjectKey = grade.subjectId.isNotEmpty
          ? grade.subjectId
          : grade.subject;
      groupedBySubject.putIfAbsent(subjectKey, () => []).add(grade);
    }

    return groupedBySubject.entries.map((entry) {
      final grades = entry.value;
      final average = _calculateAverage(grades);
      return SubjectGrades(
        subjectId: entry.key,
        subject: grades.first.subject,
        subjectName: grades.first.subjectName,
        grades: grades,
        averageGrade: average,
        trend: 'stable',
      );
    }).toList();
  }
}
