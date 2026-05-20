import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AddressModel address,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text(
            'Delete Address',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${address.title} address?',
            style: const TextStyle(
              color: AppTheme.lightText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await ref.read(addressProvider.notifier).deleteAddress(address.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address deleted'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(addressProvider.notifier).loadAddresses();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 68,
                      width: 68,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primary,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user?.phoneNumber.isNotEmpty == true
                                ? user!.phoneNumber
                                : 'No phone number',
                            style: const TextStyle(
                              color: AppTheme.lightText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user?.email.isNotEmpty == true
                                ? user!.email
                                : 'No email',
                            style: const TextStyle(
                              color: AppTheme.lightText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Role: ${(user?.role ?? 'customer').toUpperCase()}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        context.push('/edit-profile');
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/add-address');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              addressState.when(
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTheme.borderColor,
                        ),
                      ),
                      child: const Text(
                        'No saved addresses found. Tap Add to create one.',
                        style: TextStyle(
                          color: AppTheme.lightText,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: addresses.map((address) {
                      return ProfileAddressCard(
                        address: address,
                        onSetDefault: address.isDefault
                            ? null
                            : () async {
                                await ref
                                    .read(addressProvider.notifier)
                                    .setDefaultAddress(address.id);

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Default address updated'),
                                  ),
                                );
                              },
                        onDelete: () {
                          _showDeleteDialog(
                            context: context,
                            ref: ref,
                            address: address,
                          );
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                error: (error, _) {
                  return Text(
                    error.toString(),
                    style: const TextStyle(
                      color: AppTheme.danger,
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Account',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              ProfileMenuTile(
                icon: Icons.favorite_border,
                title: 'Favourite Restaurants',
                onTap: () {
                  context.push('/favourites');
                },
              ),

              const ProfileMenuTile(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
              ),

              ProfileMenuTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {
                  context.push('/notifications');
                },
              ),

              const ProfileMenuTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
              ),

              const ProfileMenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
              ),

              ProfileMenuTile(
                icon: Icons.swap_horiz_rounded,
                title: 'Switch Role',
                onTap: () {
                  context.push('/switch-role');
                },
              ),

              const SizedBox(height: 14),

              ProfileMenuTile(
                icon: Icons.logout,
                title: 'Logout',
                isDanger: true,
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();

                  if (!context.mounted) return;

                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileAddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onSetDefault;
  final VoidCallback onDelete;

  const ProfileAddressCard({
    super.key,
    required this.address,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: address.isDefault ? AppTheme.primary : AppTheme.borderColor,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                address.title.toLowerCase() == 'home'
                    ? Icons.home_outlined
                    : Icons.location_on_outlined,
                color: AppTheme.primary,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.title,
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.phoneNumber,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSetDefault,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                      color: onSetDefault == null
                          ? AppTheme.borderColor
                          : AppTheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    address.isDefault ? 'Default Address' : 'Set Default',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(
                    color: AppTheme.danger,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppTheme.danger : AppTheme.darkText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDanger ? AppTheme.danger : AppTheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        trailing: isDanger
            ? null
            : const Icon(
                Icons.chevron_right,
                color: AppTheme.lightText,
              ),
        onTap: onTap,
      ),
    );
  }
}