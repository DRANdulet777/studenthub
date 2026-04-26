import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          .map((doc) => NotificationItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('FirebaseNotificationRepository getNotifications error: $e');
      return [];
    }
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
          .map((doc) => NotificationItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('FirebaseNotificationRepository getUnreadNotifications error: $e');
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

      return doc.exists ? NotificationItem.fromJson(doc.data()!) : null;
    } catch (e) {
      print('FirebaseNotificationRepository getNotificationById error: $e');
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
      print('FirebaseNotificationRepository markAsRead error: $e');
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
      print('FirebaseNotificationRepository markAllAsRead error: $e');
    }
  }

  @override
  Future<void> createNotification(NotificationItem notification) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      print('FirebaseNotificationRepository createNotification error: $e');
      throw Exception('Failed to create notification: $e');
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
      print('FirebaseNotificationRepository deleteNotification error: $e');
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
      print('FirebaseNotificationRepository clearAllNotifications error: $e');
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
      print('FirebaseNotificationRepository getNotificationSettings error: $e');
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
      print(
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
          .set(notification.toJson());
    } catch (e) {
      print('FirebaseNotificationRepository scheduleNotification error: $e');
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
      print(
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
}
