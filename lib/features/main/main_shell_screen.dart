import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/favourite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/order_history_screen.dart';
import '../profile/profile_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int selectedIndex = 0;

  final screens = const [
    HomeScreen(),
    OrderHistoryScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(addressProvider.notifier).loadAddresses();
      ref.read(orderProvider.notifier).loadOrders();
      ref.read(restaurantProvider.notifier).loadRestaurants();
      ref.read(favouriteProvider.notifier).loadFavourites();
      ref.read(notificationProvider.notifier).loadNotifications();
    });
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
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.secondary,
          selectedIndex: selectedIndex,
          height: 74,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: AppTheme.lightText,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: AppTheme.primary,
              ),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.lightText,
              ),
              selectedIcon: Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.primary,
              ),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: NotificationNavIcon(
                unreadCount: unreadCount,
                isSelected: false,
              ),
              selectedIcon: NotificationNavIcon(
                unreadCount: unreadCount,
                isSelected: true,
              ),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: AppTheme.lightText,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationNavIcon extends StatelessWidget {
  final int unreadCount;
  final bool isSelected;

  const NotificationNavIcon({
    super.key,
    required this.unreadCount,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isSelected
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
          color: isSelected ? AppTheme.primary : AppTheme.lightText,
        ),
        if (unreadCount > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 2,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.danger,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}