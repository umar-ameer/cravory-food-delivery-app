import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/switch-role');
            },
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (!context.mounted) return;

              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminHeroCard(
            name: user?.name ?? 'Admin',
            email: user?.email ?? '',
          ),

          const SizedBox(height: 22),

          Row(
            children: const [
              Expanded(
                child: _AdminStatCard(
                  title: 'Orders',
                  value: 'Live',
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  title: 'Restaurants',
                  value: 'CRUD',
                  icon: Icons.restaurant_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: const [
              Expanded(
                child: _AdminStatCard(
                  title: 'Food Items',
                  value: 'Menu',
                  icon: Icons.fastfood_rounded,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  title: 'Delivery',
                  value: 'Panel',
                  icon: Icons.delivery_dining_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Management',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          AdminActionCard(
            icon: Icons.receipt_long_rounded,
            title: 'Manage Orders',
            subtitle: 'View all orders and update order status.',
            badge: 'Live',
            onTap: () {
              context.push('/admin-orders');
            },
          ),

          AdminActionCard(
            icon: Icons.restaurant_rounded,
            title: 'Add Restaurant',
            subtitle: 'Create a new restaurant in Firestore.',
            badge: 'Add',
            onTap: () {
              context.push('/admin-add-restaurant');
            },
          ),

          AdminActionCard(
            icon: Icons.fastfood_rounded,
            title: 'Add Food Item',
            subtitle: 'Create food items and link them with restaurants.',
            badge: 'Add',
            onTap: () {
              context.push('/admin-add-food-item');
            },
          ),

          AdminActionCard(
            icon: Icons.delivery_dining_rounded,
            title: 'Delivery Panel',
            subtitle: 'Switch to delivery partner dashboard.',
            badge: 'Role',
            onTap: () {
              context.push('/switch-role');
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _AdminHeroCard extends StatelessWidget {
  final String name;
  final String email;

  const _AdminHeroCard({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00AEEF),
            Color(0xFF026A91),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 28,
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const AdminActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: const BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
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
                          title,
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.lightText,
            ),
          ],
        ),
      ),
    );
  }
}