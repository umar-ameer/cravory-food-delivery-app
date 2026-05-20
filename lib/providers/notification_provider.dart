import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import 'auth_provider.dart';

class NotificationNotifier extends AsyncNotifier<List<AppNotificationModel>> {
  late final FirebaseFirestore _firestore;

  @override
  Future<List<AppNotificationModel>> build() async {
    _firestore = ref.watch(firestoreProvider);
    return [];
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();

    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.id)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = snapshot.docs.map((doc) {
        return AppNotificationModel.fromFirestore(doc);
      }).toList();

      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.general,
  }) async {
    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        return;
      }

      final notificationRef = _firestore
          .collection('users')
          .doc(user.id)
          .collection('notifications')
          .doc();

      final notification = AppNotificationModel(
        id: notificationRef.id,
        title: title,
        message: message,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await notificationRef.set(notification.toFirestore());

      final currentNotifications = state.value ?? [];

      state = AsyncValue.data([
        notification,
        ...currentNotifications,
      ]);
    } catch (_) {
      // Notification should not break main app flow.
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
      });

      final currentNotifications = state.value ?? [];

      final updatedNotifications = currentNotifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }

        return notification;
      }).toList();

      state = AsyncValue.data(updatedNotifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        return;
      }

      final currentNotifications = state.value ?? [];

      final unreadNotifications = currentNotifications.where((notification) {
        return !notification.isRead;
      }).toList();

      final batch = _firestore.batch();

      for (final notification in unreadNotifications) {
        final docRef = _firestore
            .collection('users')
            .doc(user.id)
            .collection('notifications')
            .doc(notification.id);

        batch.update(docRef, {
          'isRead': true,
        });
      }

      await batch.commit();

      final updatedNotifications = currentNotifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      state = AsyncValue.data(updatedNotifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearNotifications() async {
    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        return;
      }

      final currentNotifications = state.value ?? [];

      final batch = _firestore.batch();

      for (final notification in currentNotifications) {
        final docRef = _firestore
            .collection('users')
            .doc(user.id)
            .collection('notifications')
            .doc(notification.id);

        batch.delete(docRef);
      }

      await batch.commit();

      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotificationModel>>(
  NotificationNotifier.new,
);