import 'package:cloud_firestore/cloud_firestore.dart';

import 'address_model.dart';
import 'cart_item_model.dart';

enum OrderStatus {
  placed,
  accepted,
  preparing,
  pickedUp,
  delivered,
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final AddressModel address;
  final double subtotal;
  final double deliveryFee;
  final double platformFee;
  final double totalAmount;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.platformFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    AddressModel? address,
    double? subtotal,
    double? deliveryFee,
    double? platformFee,
    double? totalAmount,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      address: address ?? this.address,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'address': address.toFirestore(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final addressData = data['address'] as Map<String, dynamic>? ?? {};

    return OrderModel(
      id: documentId,
      userId: (data['userId'] ?? '') as String,
      items: itemsData.map((item) {
        return CartItemModel.fromFirestore(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList(),
      address: AddressModel.fromMap(
        Map<String, dynamic>.from(addressData),
        '',
      ),
      subtotal: ((data['subtotal'] ?? 0) as num).toDouble(),
      deliveryFee: ((data['deliveryFee'] ?? 0) as num).toDouble(),
      platformFee: ((data['platformFee'] ?? 0) as num).toDouble(),
      totalAmount: ((data['totalAmount'] ?? 0) as num).toDouble(),
      paymentMethod: (data['paymentMethod'] ?? 'Cash on Delivery') as String,
      status: _statusFromString((data['status'] ?? 'placed') as String),
      createdAt: data['createdAt'] == null
          ? DateTime.now()
          : (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory OrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return OrderModel.fromMap(data, doc.id);
  }
}

OrderStatus _statusFromString(String status) {
  switch (status) {
    case 'accepted':
      return OrderStatus.accepted;
    case 'preparing':
      return OrderStatus.preparing;
    case 'pickedUp':
      return OrderStatus.pickedUp;
    case 'delivered':
      return OrderStatus.delivered;
    case 'placed':
    default:
      return OrderStatus.placed;
  }
}