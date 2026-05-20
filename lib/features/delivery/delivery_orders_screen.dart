import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class DeliveryOrdersScreen extends StatelessWidget {
  const DeliveryOrdersScreen({super.key});

  double _totalAmount(Map<String, dynamic> data) {
    final value = data['totalAmount'];

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
          'Delivery Orders',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collectionGroup('orders').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final status = (doc.data()['status'] ?? '').toString();
            return status == 'pickedUp' ||
                status == 'accepted' ||
                status == 'preparing';
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No delivery orders assigned yet',
                style: TextStyle(
                  color: AppTheme.lightText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final status = (data['status'] ?? 'placed').toString();
              final total = _totalAmount(data);

              return GestureDetector(
                onTap: () {
                  context.push(
                    '/delivery-order-details',
                    extra: doc.reference.path,
                  );
                },
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
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${doc.id}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.lightText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.lightText,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}