import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final String orderPath;

  const AdminOrderDetailsScreen({
    super.key,
    required this.orderPath,
  });

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  bool isUpdating = false;

  DocumentReference<Map<String, dynamic>> get orderRef {
    return FirebaseFirestore.instance.doc(widget.orderPath);
  }

  Future<void> updateStatus(String status) async {
    setState(() {
      isUpdating = true;
    });

    try {
      await orderRef.update({
        'status': status,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $status'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  double _number(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Admin Order Details',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: orderRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final doc = snapshot.data!;
          final data = doc.data() ?? {};

          final status = (data['status'] ?? 'placed').toString();
          final total = _number(data['totalAmount']);
          final paymentMethod = (data['paymentMethod'] ?? 'N/A').toString();

          final address = data['address'];
          final addressText = address is Map
              ? (address['fullAddress'] ?? '').toString()
              : 'Address not available';

          final items = data['items'];

          return ListView(
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
                      'Order #${doc.id}',
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
                      'Total: ₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Payment: $paymentMethod',
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Current Status: ${status.toUpperCase()}',
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Update Status',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusButton(
                    title: 'Placed',
                    value: 'placed',
                    currentStatus: status,
                    isLoading: isUpdating,
                    onTap: updateStatus,
                  ),
                  _StatusButton(
                    title: 'Accepted',
                    value: 'accepted',
                    currentStatus: status,
                    isLoading: isUpdating,
                    onTap: updateStatus,
                  ),
                  _StatusButton(
                    title: 'Preparing',
                    value: 'preparing',
                    currentStatus: status,
                    isLoading: isUpdating,
                    onTap: updateStatus,
                  ),
                  _StatusButton(
                    title: 'Picked Up',
                    value: 'pickedUp',
                    currentStatus: status,
                    isLoading: isUpdating,
                    onTap: updateStatus,
                  ),
                  _StatusButton(
                    title: 'Delivered',
                    value: 'delivered',
                    currentStatus: status,
                    isLoading: isUpdating,
                    onTap: updateStatus,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Delivery Address',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

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
                child: Text(
                  addressText,
                  style: const TextStyle(
                    color: AppTheme.lightText,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Items',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

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
                child: Text(
                  items == null ? 'No items found' : items.toString(),
                  style: const TextStyle(
                    color: AppTheme.lightText,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String title;
  final String value;
  final String currentStatus;
  final bool isLoading;
  final Future<void> Function(String status) onTap;

  const _StatusButton({
    required this.title,
    required this.value,
    required this.currentStatus,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentStatus == value;

    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              onTap(value);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primary : AppTheme.surface,
        foregroundColor: isSelected ? Colors.white : AppTheme.darkText,
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.borderColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}