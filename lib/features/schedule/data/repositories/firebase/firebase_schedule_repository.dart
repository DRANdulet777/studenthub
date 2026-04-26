import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_hub/features/schedule/data/repositories/schedule_repository.dart';
import 'package:student_hub/features/schedule/domain/entities/schedule_item.dart';

class FirebaseScheduleRepository implements ScheduleRepository {
  final FirebaseFirestore _firestore;

  FirebaseScheduleRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ScheduleItem>> getSchedule() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _scheduleCollection(userId).orderBy('startTime').get();
      return snapshot.docs.map(_fromFirestore).toList();
    } catch (e) {
      debugPrint('FirebaseScheduleRepository getSchedule error: $e');
      return [];
    }
  }

  @override
  Stream<List<ScheduleItem>> watchSchedule() {
    final userId = _getCurrentUserId();
    if (userId == null) return Stream.value(const []);

    return _scheduleCollection(userId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromFirestore).toList());
  }

  @override
  Future<void> addLesson(ScheduleItem lesson) async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    await _scheduleCollection(userId).add(lesson.toJson());
  }

  @override
  Future<void> updateLesson(ScheduleItem lesson) async {
    final userId = _getCurrentUserId();
    if (userId == null || lesson.id.isEmpty) return;

    await _scheduleCollection(userId).doc(lesson.id).update(lesson.toJson());
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    final userId = _getCurrentUserId();
    if (userId == null || lessonId.isEmpty) return;

    await _scheduleCollection(userId).doc(lessonId).delete();
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>> _scheduleCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('schedule');
  }

  ScheduleItem _fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] ??= doc.id;
    return ScheduleItem.fromJson(data);
  }
}
