import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/food_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../models/review_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/food_item_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/app_network_image.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  Future<void> _handleAddToCart({
    required BuildContext context,
    required WidgetRef ref,
    required FoodItemModel foodItem,
  }) async {
    final cartItems = ref.read(cartProvider);

    final isDifferentRestaurant = cartItems.isNotEmpty &&
        cartItems.first.foodItem.restaurantId != foodItem.restaurantId;

    if (!isDifferentRestaurant) {
      ref.read(cartProvider.notifier).addItem(foodItem);
      return;
    }

    final shouldClearCart = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text(
            'Start a new cart?',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Your cart already has items from another restaurant. Clear it and add this item?',
            style: TextStyle(
              color: AppTheme.lightText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop(true);
              },
              child: const Text(
                'Clear & Add',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClearCart == true) {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(cartProvider.notifier).addItem(foodItem);
    }
  }

  int _getItemQuantity({
    required WidgetRef ref,
    required String foodItemId,
  }) {
    final cartItems = ref.watch(cartProvider);

    for (final cartItem in cartItems) {
      if (cartItem.foodItem.id == foodItemId) {
        return cartItem.quantity;
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodItemsState = ref.watch(foodItemsProvider(restaurant.id));
    final reviewsState = ref.watch(restaurantReviewsProvider(restaurant.id));
    final reviewStatsState =
        ref.watch(restaurantReviewStatsProvider(restaurant.id));
    final cartItems = ref.watch(cartProvider);

    final totalCartItems = cartItems.fold<int>(0, (sum, item) {
      return sum + item.quantity;
    });

    final cartTotal = ref.read(cartProvider.notifier).totalAmount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: totalCartItems == 0
          ? null
          : _CartBottomBar(
              itemCount: totalCartItems,
              total: cartTotal,
              onTap: () {
                context.push('/cart');
              },
            ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 320,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: restaurant.imageUrl,
                    fallbackIcon: Icons.restaurant,
                    height: 320,
                    width: double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.black.withOpacity(0.02),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 255),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(42),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reviewStatsState.when(
                        data: (stats) {
                          return _RestaurantInfoCard(
                            restaurant: restaurant,
                            averageRating: stats.averageRating,
                            totalReviews: stats.totalReviews,
                          );
                        },
                        loading: () {
                          return _RestaurantInfoCard(
                            restaurant: restaurant,
                            averageRating: 0,
                            totalReviews: 0,
                          );
                        },
                        error: (_, __) {
                          return _RestaurantInfoCard(
                            restaurant: restaurant,
                            averageRating: 0,
                            totalReviews: 0,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Featured items',
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Most ordered from this restaurant',
                        style: TextStyle(
                          color: AppTheme.lightText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      foodItemsState.when(
                        data: (foodItems) {
                          if (foodItems.isEmpty) {
                            return const _EmptyMenuItems();
                          }

                          return ListView.builder(
                            itemCount: foodItems.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final foodItem = foodItems[index];

                              final quantity = _getItemQuantity(
                                ref: ref,
                                foodItemId: foodItem.id,
                              );

                              return WoltFoodItemCard(
                                foodItem: foodItem,
                                quantity: quantity,
                                onAdd: () {
                                  _handleAddToCart(
                                    context: context,
                                    ref: ref,
                                    foodItem: foodItem,
                                  );
                                },
                                onIncrease: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addItem(foodItem);
                                },
                                onDecrease: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .decreaseQuantity(foodItem.id);
                                },
                              );
                            },
                          );
                        },
                        loading: () {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        error: (error, _) {
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppTheme.borderColor,
                              ),
                            ),
                            child: Text(
                              error.toString(),
                              style: const TextStyle(
                                color: AppTheme.danger,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Ratings & Reviews',
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      reviewsState.when(
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return const _EmptyReviews();
                          }

                          return Column(
                            children: reviews.map((review) {
                              return ReviewCard(review: review);
                            }).toList(),
                          );
                        },
                        loading: () {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        error: (error, _) {
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppTheme.borderColor,
                              ),
                            ),
                            child: Text(
                              error.toString(),
                              style: const TextStyle(
                                color: AppTheme.danger,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () {
                      context.pop();
                    },
                  ),
                  _CircleIconButton(
                    icon: Icons.favorite_border,
                    onTap: () {},
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

class _RestaurantInfoCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final double averageRating;
  final int totalReviews;

  const _RestaurantInfoCard({
    required this.restaurant,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = totalReviews == 0
        ? restaurant.rating
        : averageRating.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  restaurant.isOpen ? 'Open' : 'Closed',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            restaurant.category,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _MetaPill(
                icon: Icons.star_rounded,
                title: displayRating,
                subtitle: totalReviews == 0
                    ? 'Rating'
                    : '$totalReviews review${totalReviews > 1 ? 's' : ''}',
              ),
              const SizedBox(width: 10),
              _MetaPill(
                icon: Icons.schedule_rounded,
                title: restaurant.deliveryTime,
                subtitle: 'Delivery',
              ),
              const SizedBox(width: 10),
              _MetaPill(
                icon: Icons.delivery_dining_rounded,
                title: restaurant.deliveryFee,
                subtitle: 'Fee',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MetaPill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
              size: 20,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.lightText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WoltFoodItemCard extends StatelessWidget {
  final FoodItemModel foodItem;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const WoltFoodItemCard({
    super.key,
    required this.foodItem,
    required this.quantity,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final isInCart = quantity > 0;

    return Opacity(
      opacity: foodItem.isAvailable ? 1 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.borderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VegNonVegDot(isVeg: foodItem.isVeg),

                    const SizedBox(height: 8),

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
                      foodItem.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      '₹${foodItem.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 112,
              width: 104,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  AppNetworkImage(
                    imageUrl: foodItem.imageUrl,
                    fallbackIcon: Icons.fastfood,
                    height: 94,
                    width: 100,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  Positioned(
                    bottom: 0,
                    child: isInCart
                        ? QuantityControl(
                            quantity: quantity,
                            onIncrease: onIncrease,
                            onDecrease: onDecrease,
                          )
                        : AddButton(
                            isAvailable: foodItem.isAvailable,
                            onAdd: onAdd,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VegNonVegDot extends StatelessWidget {
  final bool isVeg;

  const _VegNonVegDot({
    required this.isVeg,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppTheme.success : AppTheme.danger;

    return Row(
      children: [
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          isVeg ? 'Vegetarian' : 'Non-veg',
          style: const TextStyle(
            color: AppTheme.lightText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class AddButton extends StatelessWidget {
  final bool isAvailable;
  final VoidCallback onAdd;

  const AddButton({
    super.key,
    required this.isAvailable,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onAdd : null,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isAvailable ? AppTheme.primary : AppTheme.borderColor,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isAvailable ? 'Add' : 'NA',
            style: TextStyle(
              color: isAvailable ? AppTheme.primary : AppTheme.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.primary,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrease,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.remove,
                size: 16,
                color: AppTheme.primary,
              ),
            ),
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: onIncrease,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.add,
                size: 16,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.secondary,
                child: Text(
                  review.userName.isEmpty
                      ? 'U'
                      : review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC542),
                    size: 20,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    review.rating.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            review.comment,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            color: AppTheme.primary,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to review this restaurant after ordering.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 21,
        backgroundColor: AppTheme.surface,
        child: Icon(
          icon,
          color: AppTheme.darkText,
          size: 21,
        ),
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onTap;

  const _CartBottomBar({
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'View order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMenuItems extends StatelessWidget {
  const _EmptyMenuItems();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            color: AppTheme.primary,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No menu items found',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'This restaurant has not added menu items yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}