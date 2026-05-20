import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_network_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final subtotal = cartNotifier.totalAmount;
    const deliveryFee = 39.0;
    const platformFee = 9.0;
    final total = cartItems.isEmpty ? 0.0 : subtotal + deliveryFee + platformFee;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: cartNotifier.clearCart,
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const _EmptyCart()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListView.builder(
                  itemCount: cartItems.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];

                    return CartItemCard(
                      cartItem: cartItem,
                      onIncrease: () {
                        cartNotifier.increaseQuantity(cartItem.foodItem.id);
                      },
                      onDecrease: () {
                        cartNotifier.decreaseQuantity(cartItem.foodItem.id);
                      },
                      onRemove: () {
                        cartNotifier.removeItem(cartItem.foodItem.id);
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

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
                      _PriceRow(
                        title: 'Subtotal',
                        value: '₹${subtotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        title: 'Delivery fee',
                        value: '₹${deliveryFee.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        title: 'Platform fee',
                        value: '₹${platformFee.toStringAsFixed(0)}',
                      ),
                      const Divider(
                        height: 30,
                        color: AppTheme.borderColor,
                      ),
                      _PriceRow(
                        title: 'Total',
                        value: '₹${total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                ElevatedButton(
                  onPressed: () {
                    context.push('/checkout');
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
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final foodItem = cartItem.foodItem;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          AppNetworkImage(
            imageUrl: foodItem.imageUrl,
            fallbackIcon: Icons.fastfood,
            height: 76,
            width: 76,
            borderRadius: BorderRadius.circular(20),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${foodItem.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                GestureDetector(
                  onTap: onRemove,
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: onDecrease,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  cartItem.quantity.toString(),
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
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
            fontSize: isBold ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
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
                Icons.shopping_bag_outlined,
                size: 50,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some delicious food items to continue.',
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