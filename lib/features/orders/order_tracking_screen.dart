import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  double _progressFromStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 0.12;
      case OrderStatus.accepted:
        return 0.32;
      case OrderStatus.preparing:
        return 0.52;
      case OrderStatus.pickedUp:
        return 0.78;
      case OrderStatus.delivered:
        return 1.0;
    }
  }

  String _statusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order placed';
      case OrderStatus.accepted:
        return 'Restaurant accepted';
      case OrderStatus.preparing:
        return 'Food is being prepared';
      case OrderStatus.pickedUp:
        return 'Courier is on the way';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String _statusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'We have received your order.';
      case OrderStatus.accepted:
        return 'The restaurant confirmed your order.';
      case OrderStatus.preparing:
        return 'Your food is being cooked.';
      case OrderStatus.pickedUp:
        return 'Your courier picked up the order.';
      case OrderStatus.delivered:
        return 'Enjoy your meal!';
    }
  }

  String _etaText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return '35-40 min';
      case OrderStatus.accepted:
        return '30-35 min';
      case OrderStatus.preparing:
        return '20-25 min';
      case OrderStatus.pickedUp:
        return '8-12 min';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);

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
            'Track Order',
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

    final progress = _progressFromStatus(order.status);
    final itemCount = order.items.fold<int>(0, (sum, item) {
      return sum + item.quantity;
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    AnimatedTrackingMap(
                      progress: progress,
                      status: order.status,
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Row(
                          children: [
                            _CircleButton(
                              icon: Icons.arrow_back,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Track Order',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _CircleButton(
                              icon: Icons.support_agent_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 22,
                      child: _EtaCard(
                        eta: _etaText(order.status),
                        statusTitle: _statusTitle(order.status),
                        statusSubtitle: _statusSubtitle(order.status),
                        progress: progress,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
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
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$itemCount item${itemCount > 1 ? 's' : ''} • ₹${order.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.lightText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.address.fullAddress,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.lightText,
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Delivery Progress',
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

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
                          children: [
                            TrackingStep(
                              icon: Icons.receipt_long_rounded,
                              title: 'Order placed',
                              subtitle: 'We have received your order.',
                              isActive: order.status.index >=
                                  OrderStatus.placed.index,
                              isLast: false,
                            ),
                            TrackingStep(
                              icon: Icons.storefront_rounded,
                              title: 'Order accepted',
                              subtitle: 'Restaurant confirmed your order.',
                              isActive: order.status.index >=
                                  OrderStatus.accepted.index,
                              isLast: false,
                            ),
                            TrackingStep(
                              icon: Icons.restaurant_rounded,
                              title: 'Food preparing',
                              subtitle: 'Your food is being prepared.',
                              isActive: order.status.index >=
                                  OrderStatus.preparing.index,
                              isLast: false,
                            ),
                            TrackingStep(
                              icon: Icons.delivery_dining_rounded,
                              title: 'Out for delivery',
                              subtitle: 'Courier is heading to your location.',
                              isActive: order.status.index >=
                                  OrderStatus.pickedUp.index,
                              isLast: false,
                            ),
                            TrackingStep(
                              icon: Icons.check_circle_rounded,
                              title: 'Delivered',
                              subtitle: 'Enjoy your meal!',
                              isActive: order.status.index >=
                                  OrderStatus.delivered.index,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Order Items',
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
                        child: Column(
                          children: order.items.map((cartItem) {
                            return OrderItemRow(cartItem: cartItem);
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (order.status != OrderStatus.delivered)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    orderNotifier.moveToNextStatus(order!.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Move to Next Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedTrackingMap extends StatefulWidget {
  final double progress;
  final OrderStatus status;

  const AnimatedTrackingMap({
    super.key,
    required this.progress,
    required this.status,
  });

  @override
  State<AnimatedTrackingMap> createState() => _AnimatedTrackingMapState();
}

class _AnimatedTrackingMapState extends State<AnimatedTrackingMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(
      begin: 0.92,
      end: 1.12,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Offset _pointOnRoute(Size size, double progress) {
    final start = Offset(size.width * 0.18, size.height * 0.70);
    final middleOne = Offset(size.width * 0.35, size.height * 0.40);
    final middleTwo = Offset(size.width * 0.62, size.height * 0.58);
    final end = Offset(size.width * 0.82, size.height * 0.28);

    if (progress <= 0.33) {
      final t = progress / 0.33;
      return Offset.lerp(start, middleOne, t)!;
    }

    if (progress <= 0.66) {
      final t = (progress - 0.33) / 0.33;
      return Offset.lerp(middleOne, middleTwo, t)!;
    }

    final t = (progress - 0.66) / 0.34;
    return Offset.lerp(middleTwo, end, t.clamp(0, 1))!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final courierPosition = _pointOnRoute(size, widget.progress);

        return Container(
          color: const Color(0xFF061019),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DarkMapPainter(
                    progress: widget.progress,
                  ),
                ),
              ),

              Positioned(
                left: size.width * 0.18 - 22,
                top: size.height * 0.70 - 22,
                child: const MapPin(
                  icon: Icons.storefront_rounded,
                  label: 'Restaurant',
                  color: Color(0xFFFFB020),
                ),
              ),

              Positioned(
                left: size.width * 0.82 - 22,
                top: size.height * 0.28 - 22,
                child: const MapPin(
                  icon: Icons.home_rounded,
                  label: 'You',
                  color: AppTheme.success,
                ),
              ),

              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: courierPosition.dx - 28,
                    top: courierPosition.dy - 28,
                    child: Transform.scale(
                      scale: pulseAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: const DeliveryMarker(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DarkMapPainter extends CustomPainter {
  final double progress;

  DarkMapPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF13232D)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final smallRoadPaint = Paint()
      ..color = const Color(0xFF0E1A22)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routeBasePaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routeProgressPaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = const Color(0xFF10212B)
      ..strokeWidth = 1;

    for (double x = -60; x < size.width + 60; x += 70) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 120, size.height),
        gridPaint,
      );
    }

    for (double y = 40; y < size.height; y += 80) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 30),
        gridPaint,
      );
    }

    final roadOne = Path()
      ..moveTo(-40, size.height * 0.25)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.12,
        size.width * 0.45,
        size.height * 0.42,
        size.width + 50,
        size.height * 0.22,
      );

    final roadTwo = Path()
      ..moveTo(-30, size.height * 0.78)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.55,
        size.width * 0.58,
        size.height * 0.82,
        size.width + 40,
        size.height * 0.55,
      );

    final roadThree = Path()
      ..moveTo(size.width * 0.12, size.height + 30)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.62,
        size.width * 0.70,
        size.height * 0.48,
        size.width * 0.90,
        -20,
      );

    canvas.drawPath(roadOne, smallRoadPaint);
    canvas.drawPath(roadTwo, roadPaint);
    canvas.drawPath(roadThree, smallRoadPaint);

    final routePath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.70)
      ..lineTo(size.width * 0.35, size.height * 0.40)
      ..lineTo(size.width * 0.62, size.height * 0.58)
      ..lineTo(size.width * 0.82, size.height * 0.28);

    canvas.drawPath(routePath, routeBasePaint);

    final routeMetric = routePath.computeMetrics().first;
    final progressPath = routeMetric.extractPath(
      0,
      routeMetric.length * progress.clamp(0, 1),
    );

    canvas.drawPath(progressPath, routeProgressPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF1C323D)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final x = (math.sin(i * 1.7) + 1) / 2 * size.width;
      final y = (math.cos(i * 1.2) + 1) / 2 * size.height;
      canvas.drawCircle(
        Offset(x, y),
        3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DarkMapPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MapPin extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const MapPin({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppTheme.borderColor,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class DeliveryMarker extends StatelessWidget {
  const DeliveryMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.45),
            blurRadius: 22,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.delivery_dining_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _EtaCard extends StatelessWidget {
  final String eta;
  final String statusTitle;
  final String statusSubtitle;
  final double progress;

  const _EtaCard({
    required this.eta,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: const BoxDecoration(
                  color: AppTheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_rounded,
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
                      statusTitle,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusSubtitle,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ETA',
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eta,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isLast;

  const TrackingStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isActive ? AppTheme.primary : AppTheme.secondary;
    final lineColor = isActive ? AppTheme.primary : AppTheme.borderColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : AppTheme.primary,
                  size: 22,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive ? AppTheme.darkText : AppTheme.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItemRow extends StatelessWidget {
  final CartItemModel cartItem;

  const OrderItemRow({
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '₹${cartItem.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.92),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.borderColor,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.darkText,
          size: 22,
        ),
      ),
    );
  }
}