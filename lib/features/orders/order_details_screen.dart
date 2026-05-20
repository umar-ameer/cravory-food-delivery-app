import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

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

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return AppTheme.success;
      case OrderStatus.pickedUp:
      case OrderStatus.preparing:
      case OrderStatus.accepted:
      case OrderStatus.placed:
        return AppTheme.primary;
    }
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final orders = orderState.value ?? [];

    OrderModel? order;

    for (final item in orders) {
      if (item.id == orderId) {
        order = item;
        break;
      }
    }

    if (order == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          foregroundColor: AppTheme.darkText,
          title: const Text(
            'Order Details',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Order not found',
            style: TextStyle(
              color: AppTheme.lightText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final canReview = order.status == OrderStatus.delivered;
    final restaurantId = order.items.isNotEmpty
        ? order.items.first.foodItem.restaurantId
        : '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canReview && restaurantId.isNotEmpty) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/add-review/$restaurantId');
                  },
                  icon: const Icon(Icons.star_rounded),
                  label: const Text(
                    'Write Review',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(
                      color: AppTheme.primary,
                    ),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  cartNotifier.clearCart();

                  for (final cartItem in order!.items) {
                    for (int i = 0; i < cartItem.quantity; i++) {
                      cartNotifier.addItem(cartItem.foodItem);
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Items added to cart again'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Reorder',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
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
                Text(
                  'Order #${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusText(order.status),
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const _SectionTitle(title: 'Order Items'),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: Column(
              children: order.items.map((cartItem) {
                return OrderDetailItemRow(cartItem: cartItem);
              }).toList(),
            ),
          ),

          const SizedBox(height: 26),

          const _SectionTitle(title: 'Delivery Address'),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  order.address.title.toLowerCase() == 'home'
                      ? Icons.home_outlined
                      : Icons.location_on_outlined,
                  color: AppTheme.primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.address.title,
                        style: const TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        order.address.fullAddress,
                        style: const TextStyle(
                          color: AppTheme.lightText,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        order.address.phoneNumber,
                        style: const TextStyle(
                          color: AppTheme.lightText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const _SectionTitle(title: 'Payment Method'),

          const SizedBox(height: 14),

          Container(
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
                const Icon(
                  Icons.payments_outlined,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  order.paymentMethod,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const _SectionTitle(title: 'Bill Summary'),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: Column(
              children: [
                _PriceRow(
                  title: 'Subtotal',
                  value: '₹${order.subtotal.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _PriceRow(
                  title: 'Delivery fee',
                  value: '₹${order.deliveryFee.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _PriceRow(
                  title: 'Platform fee',
                  value: '₹${order.platformFee.toStringAsFixed(0)}',
                ),
                const Divider(
                  height: 30,
                  color: AppTheme.borderColor,
                ),
                _PriceRow(
                  title: 'Total',
                  value: '₹${order.totalAmount.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

class OrderDetailItemRow extends StatelessWidget {
  final CartItemModel cartItem;

  const OrderDetailItemRow({
    super.key,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final foodItem = cartItem.foodItem;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${cartItem.quantity} × ${foodItem.name}',
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '₹${cartItem.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const _PriceRow({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isBold ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 17 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 17 : 14,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.darkText,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}