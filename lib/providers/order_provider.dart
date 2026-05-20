import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';

class OrderNotifier extends AsyncNotifier<List<OrderModel>> {
  late final FirebaseFirestore _firestore;

  @override
  Future<List<OrderModel>> build() async {
    _firestore = ref.watch(firestoreProvider);
    return [];
  }

  Future<void> loadOrders() async {
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
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<OrderModel?> placeOrder({
    required List<CartItemModel> items,
    required AddressModel address,
    required double subtotal,
    required double deliveryFee,
    required double platformFee,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        state = AsyncValue.error('User not logged in', StackTrace.current);
        return null;
      }

      final orderRef = _firestore
          .collection('users')
          .doc(user.id)
          .collection('orders')
          .doc();

      final order = OrderModel(
        id: orderRef.id,
        userId: user.id,
        items: items,
        address: address,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
      );

      await orderRef.set(order.toFirestore());

      final currentOrders = state.value ?? [];

      state = AsyncValue.data([
        order,
        ...currentOrders,
      ]);

      await ref.read(notificationProvider.notifier).addNotification(
            title: 'Order placed',
            message: 'Your order has been placed successfully.',
            type: AppNotificationType.order,
          );

      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      final user = ref.read(authProvider).value;

      if (user == null) {
        state = AsyncValue.error('User not logged in', StackTrace.current);
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status.name,
      });

      final currentOrders = state.value ?? [];

      final updatedOrders = currentOrders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(
            status: status,
          );
        }

        return order;
      }).toList();

      state = AsyncValue.data(updatedOrders);

      await _createStatusNotification(status);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> moveToNextStatus(String orderId) async {
    final currentOrders = state.value ?? [];

    final orderIndex = currentOrders.indexWhere((order) {
      return order.id == orderId;
    });

    if (orderIndex == -1) {
      return;
    }

    final currentOrder = currentOrders[orderIndex];

    if (currentOrder.status == OrderStatus.delivered) {
      return;
    }

    final nextStatus = OrderStatus.values[currentOrder.status.index + 1];

    await updateOrderStatus(
      orderId: orderId,
      status: nextStatus,
    );
  }

  Future<void> _createStatusNotification(OrderStatus status) async {
    switch (status) {
      case OrderStatus.placed:
        await ref.read(notificationProvider.notifier).addNotification(
              title: 'Order placed',
              message: 'Your order has been placed successfully.',
              type: AppNotificationType.order,
            );
        break;

      case OrderStatus.accepted:
        await ref.read(notificationProvider.notifier).addNotification(
              title: 'Order accepted',
              message: 'The restaurant has accepted your order.',
              type: AppNotificationType.order,
            );
        break;

      case OrderStatus.preparing:
        await ref.read(notificationProvider.notifier).addNotification(
              title: 'Food preparing',
              message: 'The restaurant has started preparing your food.',
              type: AppNotificationType.order,
            );
        break;

      case OrderStatus.pickedUp:
        await ref.read(notificationProvider.notifier).addNotification(
              title: 'Out for delivery',
              message: 'Your courier is on the way.',
              type: AppNotificationType.order,
            );
        break;

      case OrderStatus.delivered:
        await ref.read(notificationProvider.notifier).addNotification(
              title: 'Order delivered',
              message: 'Your order has been delivered. Enjoy your meal!',
              type: AppNotificationType.order,
            );
        break;
    }
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<OrderModel>>(
  OrderNotifier.new,
);