import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/address_model.dart';
import '../../models/cart_item_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  AddressModel? selectedAddress;
  String selectedPaymentMethod = 'Cash on Delivery';

  final couponController = TextEditingController();

  String appliedCoupon = '';
  double discountAmount = 0.0;
  bool isFreeDeliveryApplied = false;

  final List<String> paymentMethods = const [
    'Cash on Delivery',
    'UPI',
    'Credit / Debit Card',
    'Wallet',
  ];

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  IconData _paymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'UPI':
        return Icons.qr_code_2;
      case 'Credit / Debit Card':
        return Icons.credit_card;
      case 'Wallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  void _applyCoupon({
    required double subtotal,
    required double deliveryFee,
  }) {
    final coupon = couponController.text.trim().toUpperCase();

    if (coupon.isEmpty) {
      _showMessage('Please enter a coupon code', isError: true);
      return;
    }

    setState(() {
      appliedCoupon = '';
      discountAmount = 0.0;
      isFreeDeliveryApplied = false;
    });

    if (coupon == 'CRAVORY50') {
      setState(() {
        appliedCoupon = coupon;
        discountAmount = subtotal >= 50 ? 50 : subtotal;
      });

      _showMessage('Coupon applied: ₹50 off');
      return;
    }

    if (coupon == 'FREEDELIVERY') {
      setState(() {
        appliedCoupon = coupon;
        isFreeDeliveryApplied = true;
        discountAmount = deliveryFee;
      });

      _showMessage('Coupon applied: Free delivery');
      return;
    }

    if (coupon == 'FIRSTORDER') {
      setState(() {
        appliedCoupon = coupon;
        discountAmount = subtotal * 0.20;
      });

      _showMessage('Coupon applied: 20% off');
      return;
    }

    _showMessage('Invalid coupon code', isError: true);
  }

  void _removeCoupon() {
    setState(() {
      appliedCoupon = '';
      discountAmount = 0.0;
      isFreeDeliveryApplied = false;
      couponController.clear();
    });

    _showMessage('Coupon removed');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : AppTheme.primary,
      ),
    );
  }

  Future<void> _placeOrder({
    required BuildContext context,
    required List<CartItemModel> cartItems,
    required CartNotifier cartNotifier,
    required OrderNotifier orderNotifier,
    required double subtotal,
    required double deliveryFee,
    required double platformFee,
    required double total,
  }) async {
    if (selectedAddress == null) {
      _showMessage('Please select a delivery address', isError: true);
      return;
    }

    final order = await orderNotifier.placeOrder(
      items: cartItems,
      address: selectedAddress!,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      platformFee: platformFee,
      totalAmount: total,
      paymentMethod: selectedPaymentMethod,
    );

    if (!context.mounted) return;

    if (order == null) {
      _showMessage('Failed to place order. Please try again.', isError: true);
      return;
    }

    cartNotifier.clearCart();

    context.go('/order-success/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final orderNotifier = ref.read(orderProvider.notifier);
    final addressState = ref.watch(addressProvider);

    final subtotal = cartNotifier.totalAmount;
    const originalDeliveryFee = 39.0;
    const platformFee = 9.0;

    final deliveryFee = isFreeDeliveryApplied ? 0.0 : originalDeliveryFee;
    final totalBeforeDiscount = cartItems.isEmpty
        ? 0.0
        : subtotal + originalDeliveryFee + platformFee;

    final total = cartItems.isEmpty
        ? 0.0
        : (subtotal + deliveryFee + platformFee - discountAmount)
            .clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
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
                child: ElevatedButton(
                  onPressed: () {
                    _placeOrder(
                      context: context,
                      cartItems: cartItems,
                      cartNotifier: cartNotifier,
                      orderNotifier: orderNotifier,
                      subtotal: subtotal,
                      deliveryFee: deliveryFee,
                      platformFee: platformFee,
                      total: total,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Place Order • ₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
      body: cartItems.isEmpty
          ? const _EmptyCheckout()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionTitle(title: 'Delivery Address'),

                const SizedBox(height: 14),

                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/add-address');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                addressState.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return const Text(
                        'No saved addresses found.',
                        style: TextStyle(
                          color: AppTheme.lightText,
                        ),
                      );
                    }

                    selectedAddress ??= addresses.firstWhere(
                      (address) => address.isDefault,
                      orElse: () => addresses.first,
                    );

                    return Column(
                      children: addresses.map((address) {
                        final isSelected = selectedAddress?.id == address.id;

                        return AddressCard(
                          address: address,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedAddress = address;
                            });
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
                    children: cartItems.map((cartItem) {
                      return CheckoutItemRow(cartItem: cartItem);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 26),

                const _SectionTitle(title: 'Apply Coupon'),

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (appliedCoupon.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.local_offer_rounded,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$appliedCoupon applied',
                                style: const TextStyle(
                                  color: AppTheme.darkText,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _removeCoupon,
                              child: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: AppTheme.danger,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        TextField(
                          controller: couponController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter coupon code',
                            prefixIcon: Icon(Icons.local_offer_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            _applyCoupon(
                              subtotal: subtotal,
                              deliveryFee: originalDeliveryFee,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Apply Coupon',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Try: CRAVORY50, FREEDELIVERY, FIRSTORDER',
                          style: TextStyle(
                            color: AppTheme.lightText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const _SectionTitle(title: 'Payment Method'),

                const SizedBox(height: 14),

                Column(
                  children: paymentMethods.map((method) {
                    final isSelected = selectedPaymentMethod == method;

                    return PaymentMethodCard(
                      title: method,
                      icon: _paymentIcon(method),
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedPaymentMethod = method;
                        });
                      },
                    );
                  }).toList(),
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
                        value: '₹${subtotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        title: 'Delivery fee',
                        value: isFreeDeliveryApplied
                            ? 'Free'
                            : '₹${originalDeliveryFee.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        title: 'Platform fee',
                        value: '₹${platformFee.toStringAsFixed(0)}',
                      ),
                      if (appliedCoupon.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _PriceRow(
                          title: 'Discount',
                          value: '-₹${discountAmount.toStringAsFixed(0)}',
                          isDiscount: true,
                        ),
                      ],
                      const Divider(
                        height: 30,
                        color: AppTheme.borderColor,
                      ),
                      _PriceRow(
                        title: 'Total',
                        value: '₹${total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                      if (appliedCoupon.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'You saved ₹${(totalBeforeDiscount - total).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 110),
              ],
            ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderColor,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
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
                  Text(
                    address.title,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontWeight: FontWeight.w900,
                    ),
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
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primary : AppTheme.lightText,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderColor,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primary : AppTheme.lightText,
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutItemRow extends StatelessWidget {
  final CartItemModel cartItem;

  const CheckoutItemRow({
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

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final bool isDiscount;

  const _PriceRow({
    required this.title,
    required this.value,
    this.isBold = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDiscount
        ? AppTheme.success
        : isBold
            ? AppTheme.darkText
            : AppTheme.lightText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 17 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
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
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Your cart is empty.',
        style: TextStyle(
          color: AppTheme.lightText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}