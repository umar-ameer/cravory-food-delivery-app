import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(orderProvider.notifier).loadOrders();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              const Text(
                'My Orders',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              orderState.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const _EmptyOrders();
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      return OrderHistoryCard(
                        order: order,
                        onTap: () {
                          context.push('/order-details/${order.id}');
                        },
                      );
                    },
                  );
                },
                loading: () {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                error: (error, _) {
                  return Container(
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(0, (sum, item) {
      return sum + item.quantity;
    });

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(26),
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
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.primary,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$itemCount item${itemCount > 1 ? 's' : ''} • ₹${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatOrderDate(order.createdAt),
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusText(order.status),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.lightText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(28),
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
                Icons.receipt_long_outlined,
                size: 50,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No orders yet',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your placed orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusText(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return 'Placed';
    case OrderStatus.accepted:
      return 'Accepted';
    case OrderStatus.preparing:
      return 'Preparing';
    case OrderStatus.pickedUp:
      return 'Picked Up';
    case OrderStatus.delivered:
      return 'Delivered';
  }
}

String _formatOrderDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();

  return '$day/$month/$year';
}