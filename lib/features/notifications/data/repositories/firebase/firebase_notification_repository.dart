import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:student_hub/features/notifications/domain/repositories/notification_repository.dart';
import 'package:student_hub/features/notifications/domain/entities/notification_item.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationItem.fromJson(_withDocumentId(doc)))
          .toList();
    } catch (e) {
      debugPrint('FirebaseNotificationRepository getNotifications error: $e');
      return [];
    }
  }

  @override
  Stream<List<NotificationItem>> watchNotifications() {
    final userId = _getCurrentUserId();
    if (userId == null) return Stream.value(const []);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationItem.fromJson(_withDocumentId(doc)))
              .toList(),
        );
  }

  @override
  Future<List<NotificationItem>> getUnreadNotifications() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationItem.fromJson(_withDocumentId(doc)))
          .toList();
    } catch (e) {
      debugPrint('FirebaseNotificationRepository getUnreadNotifications error: $e');
      return [];
    }
  }

  @override
  Future<NotificationItem?> getNotificationById(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(id)
          .get();

      return doc.exists ? NotificationItem.fromJson(_withDocumentId(doc)) : null;
    } catch (e) {
      debugPrint('FirebaseNotificationRepository getNotificationById error: $e');
      return null;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(id)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('FirebaseNotificationRepository markAsRead error: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      debugPrint('FirebaseNotificationRepository markAllAsRead error: $e');
    }
  }

  @override
  Future<void> createNotification(NotificationItem notification) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');
      if (notification.sourceId != null &&
          await hasNotificationForSource(notification.sourceId!)) {
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(_toFirestore(notification));
    } catch (e) {
      debugPrint('FirebaseNotificationRepository createNotification error: $e');
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<bool> hasNotificationForSource(String sourceId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return false;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('sourceId', isEqualTo: sourceId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('FirebaseNotificationRepository hasNotificationForSource error: $e');
      return false;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('FirebaseNotificationRepository deleteNotification error: $e');
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('FirebaseNotificationRepository clearAllNotifications error: $e');
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        return NotificationSettings.defaultSettings();
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      return doc.exists
          ? NotificationSettings.fromJson(doc.data()!)
          : NotificationSettings.defaultSettings();
    } catch (e) {
      debugPrint('FirebaseNotificationRepository getNotificationSettings error: $e');
      return NotificationSettings.defaultSettings();
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(settings.toJson());
    } catch (e) {
      debugPrint(
        'FirebaseNotificationRepository saveNotificationSettings error: $e',
      );
      throw Exception('Failed to save notification settings: $e');
    }
  }

  @override
  Future<void> scheduleNotification(NotificationItem notification) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scheduledNotifications')
          .doc(notification.id)
          .set(_toFirestore(notification));
    } catch (e) {
      debugPrint('FirebaseNotificationRepository scheduleNotification error: $e');
      throw Exception('Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> cancelScheduledNotification(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scheduledNotifications')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint(
        'FirebaseNotificationRepository cancelScheduledNotification error: $e',
      );
    }
  }

  @override
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    final settings = await getNotificationSettings();
    if (!settings.enabled) return false;

    switch (type) {
      case NotificationType.taskDeadline:
        return settings.taskDeadlines;
      case NotificationType.scheduleReminder:
        return settings.scheduleReminders;
      case NotificationType.materialUpdate:
        return settings.materialUpdates;
      case NotificationType.gradePosted:
        return settings.gradeNotifications;
      case NotificationType.chatMessage:
        return settings.chatMessages;
      case NotificationType.system:
        return true;
    }
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Map<String, dynamic> _toFirestore(NotificationItem notification) {
    final data = notification.toJson();
    data['createdAt'] = Timestamp.fromDate(notification.createdAt);
    if (notification.scheduledAt != null) {
      data['scheduledAt'] = Timestamp.fromDate(notification.scheduledAt!);
    }
    return data;
  }

  Map<String, dynamic> _withDocumentId(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    return data;
  }
}
