import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/restaurant_model.dart';
import '../../providers/favourite_provider.dart';
import '../../widgets/app_network_image.dart';

class FavouriteRestaurantsScreen extends ConsumerWidget {
  const FavouriteRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouriteState = ref.watch(favouriteProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Favourite Restaurants',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: favouriteState.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return const _EmptyFavourites();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              return FavouriteRestaurantCard(
                restaurant: restaurant,
                onTap: () {
                  context.push(
                    '/restaurant/${restaurant.id}',
                    extra: restaurant,
                  );
                },
                onRemove: () {
                  ref
                      .read(favouriteProvider.notifier)
                      .toggleFavourite(restaurant);
                },
              );
            },
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, _) {
          return Center(
            child: Text(
              error.toString(),
              style: const TextStyle(
                color: AppTheme.danger,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavouriteRestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavouriteRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
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
              imageUrl: restaurant.imageUrl,
              fallbackIcon: Icons.restaurant,
              height: 84,
              width: 84,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.category,
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${restaurant.rating} • ${restaurant.deliveryTime}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.favorite,
                color: AppTheme.danger,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No favourite restaurants yet',
        style: TextStyle(
          color: AppTheme.lightText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}