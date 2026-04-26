import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_hub/features/tasks/data/repositories/task_repository.dart';
import 'package:student_hub/features/tasks/domain/entities/task_item.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTaskRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<TaskItem>> getTasks() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskItem.fromJson(_withDocumentId(doc)))
          .toList();
    } catch (e) {
      debugPrint('FirebaseTaskRepository getTasks error: $e');
      return [];
    }
  }

  @override
  Stream<List<TaskItem>> watchTasks() {
    final userId = _getCurrentUserId();
    if (userId == null) return Stream.value(const []);

    return _tasksCollection(userId)
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskItem.fromJson(_withDocumentId(doc)))
              .toList(),
        );
  }

  @override
  Future<TaskItem> addTask(TaskItem task) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    final collection = _tasksCollection(userId);
    final docRef = task.id.isEmpty ? collection.doc() : collection.doc(task.id);
    final taskToSave = task.id.isEmpty ? task.copyWith(id: docRef.id) : task;

    await docRef.set(_toFirestore(taskToSave));
    return taskToSave;
  }

  @override
  Future<TaskItem> createTask(TaskItem task) {
    return addTask(task);
  }

  @override
  Future<TaskItem> updateTask(String id, TaskItem task) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    final taskToUpdate = task.copyWith(id: id);
    await _tasksCollection(userId).doc(id).update(_toFirestore(taskToUpdate));

    return taskToUpdate;
  }

  @override
  Future<void> deleteTask(String id) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    await _tasksCollection(userId).doc(id).delete();
  }

  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Map<String, dynamic> _toFirestore(TaskItem task) {
    final data = task.toJson();
    data['dueDate'] = Timestamp.fromDate(task.dueDate);
    return data;
  }

  Map<String, dynamic> _withDocumentId(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    data['id'] ??= doc.id;
    final dueDate = data['dueDate'];
    if (dueDate is Timestamp) {
      data['dueDate'] = dueDate.toDate();
    }
    return data;
  }
}
