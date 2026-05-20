import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  IconData _notificationIcon(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.order:
        return Icons.receipt_long_rounded;
      case AppNotificationType.coupon:
        return Icons.local_offer_rounded;
      case AppNotificationType.review:
        return Icons.star_rounded;
      case AppNotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _notificationColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.order:
        return AppTheme.primary;
      case AppNotificationType.coupon:
        return const Color(0xFFFFB020);
      case AppNotificationType.review:
        return const Color(0xFFFFC542);
      case AppNotificationType.general:
        return AppTheme.success;
    }
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    final notifications = notificationState.value ?? [];

    final unreadCount = notifications.where((notification) {
      return !notification.isRead;
    }).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              color: AppTheme.surface,
              iconColor: AppTheme.darkText,
              onSelected: (value) {
                if (value == 'read') {
                  ref.read(notificationProvider.notifier).markAllAsRead();
                }

                if (value == 'clear') {
                  ref.read(notificationProvider.notifier).clearNotifications();
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'read',
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: AppTheme.darkText,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        color: AppTheme.danger,
                      ),
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(notificationProvider.notifier).loadNotifications();
        },
        child: notificationState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const _EmptyNotifications();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ...notifications.map((notification) {
                  return NotificationCard(
                    notification: notification,
                    icon: _notificationIcon(notification.type),
                    iconColor: _notificationColor(notification.type),
                    date: _formatDate(notification.createdAt),
                    onTap: () {
                      if (!notification.isRead) {
                        ref
                            .read(notificationProvider.notifier)
                            .markAsRead(notification.id);
                      }
                    },
                  );
                }),
              ],
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppTheme.borderColor,
                    ),
                  ),
                  child: Text(
                    error.toString(),
                    style: const TextStyle(
                      color: AppTheme.danger,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final IconData icon;
  final Color iconColor;
  final String date;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.icon,
    required this.iconColor,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUnread ? AppTheme.primary : AppTheme.borderColor,
            width: isUnread ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          height: 9,
                          width: 9,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    date,
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 105,
                width: 105,
                decoration: const BoxDecoration(
                  color: AppTheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.primary,
                  size: 52,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'No notifications yet',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Order updates and app alerts will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}