import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/role_redirect.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class SwitchRoleScreen extends ConsumerWidget {
  const SwitchRoleScreen({super.key});

  Future<void> _changeRole({
    required BuildContext context,
    required WidgetRef ref,
    required String role,
  }) async {
    await ref.read(authProvider.notifier).updateUserRole(role);

    final user = ref.read(authProvider).value;

    if (!context.mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to switch role'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${role.toUpperCase()} mode'),
        backgroundColor: AppTheme.primary,
      ),
    );

    redirectUserByRole(context, user);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;
    final currentRole = currentUser?.role ?? 'customer';
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Switch Role',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose app mode',
                  style: TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Switch between Customer, Admin and Delivery panels directly from the app for your project demo.',
                  style: TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Current role: ${currentRole.toUpperCase()}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          RoleCard(
            icon: Icons.person_rounded,
            title: 'Customer',
            subtitle: 'Browse restaurants, order food, apply coupons and track delivery.',
            role: 'customer',
            currentRole: currentRole,
            isLoading: isLoading,
            color: AppTheme.primary,
            onTap: () {
              _changeRole(
                context: context,
                ref: ref,
                role: 'customer',
              );
            },
          ),

          RoleCard(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin',
            subtitle: 'Manage restaurants, food items, orders, coupons and reviews.',
            role: 'admin',
            currentRole: currentRole,
            isLoading: isLoading,
            color: AppTheme.primary,
            onTap: () {
              _changeRole(
                context: context,
                ref: ref,
                role: 'admin',
              );
            },
          ),

          RoleCard(
            icon: Icons.delivery_dining_rounded,
            title: 'Delivery Partner',
            subtitle: 'View assigned orders, pickup tasks and delivery status.',
            role: 'delivery',
            currentRole: currentRole,
            isLoading: isLoading,
            color: AppTheme.success,
            onTap: () {
              _changeRole(
                context: context,
                ref: ref,
                role: 'delivery',
              );
            },
          ),
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String role;
  final String currentRole;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.role,
    required this.currentRole,
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentRole == role;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? color : AppTheme.borderColor,
              width: isSelected ? 1.7 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
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

              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: color,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.lightText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}