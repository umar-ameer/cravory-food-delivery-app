import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  String _statusText(Map<String, dynamic> data) {
    return (data['status'] ?? 'placed').toString();
  }

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

  DateTime _createdAt(Map<String, dynamic> data) {
    final value = data['createdAt'];

    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.now();
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Admin Orders',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collectionGroup('orders').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(
                  color: AppTheme.danger,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          docs.sort((a, b) {
            final aDate = _createdAt(a.data());
            final bDate = _createdAt(b.data());
            return bDate.compareTo(aDate);
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders found',
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

              final status = _statusText(data);
              final total = _totalAmount(data);
              final createdAt = _createdAt(data);

              return GestureDetector(
                onTap: () {
                  context.push(
                    '/admin-order-details',
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
                        decoration: const BoxDecoration(
                          color: AppTheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppTheme.primary,
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
                              '${_formatDate(createdAt)} • ₹${total.toStringAsFixed(0)}',
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
                                color: AppTheme.primary,
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