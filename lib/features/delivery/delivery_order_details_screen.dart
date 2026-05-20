import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class DeliveryOrderDetailsScreen extends StatefulWidget {
  final String orderPath;

  const DeliveryOrderDetailsScreen({
    super.key,
    required this.orderPath,
  });

  @override
  State<DeliveryOrderDetailsScreen> createState() =>
      _DeliveryOrderDetailsScreenState();
}

class _DeliveryOrderDetailsScreenState
    extends State<DeliveryOrderDetailsScreen> {
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
          content: Text('Status updated to $status'),
          backgroundColor: AppTheme.success,
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
          'Delivery Order Details',
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

          final address = data['address'];
          final addressText = address is Map
              ? (address['fullAddress'] ?? '').toString()
              : 'Address not available';

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
                        color: AppTheme.success,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
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
                'Customer Address',
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

              ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () {
                        updateStatus('pickedUp');
                      },
                icon: const Icon(Icons.delivery_dining_rounded),
                label: const Text(
                  'Mark Picked Up',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () {
                        updateStatus('delivered');
                      },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text(
                  'Mark Delivered',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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