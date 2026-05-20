import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/dummy_data.dart';
import '../../models/category_model.dart';
import '../../models/restaurant_model.dart';
import '../../providers/favourite_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/app_network_image.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();

  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(restaurantProvider.notifier).loadRestaurants();
      ref.read(favouriteProvider.notifier).loadFavourites();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<RestaurantModel> getFilteredRestaurants(
    List<RestaurantModel> restaurants,
  ) {
    return restaurants.where((restaurant) {
      final query = searchQuery.toLowerCase();
      final category = selectedCategory.toLowerCase();

      final matchesSearch =
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.category.toLowerCase().contains(query);

      final matchesCategory = selectedCategory == 'All' ||
          restaurant.category.toLowerCase().contains(category);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void clearSearchAndFilter() {
    setState(() {
      searchController.clear();
      searchQuery = '';
      selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantState = ref.watch(restaurantProvider);
    final favouriteState = ref.watch(favouriteProvider);
    final favouriteRestaurants = favouriteState.value ?? [];

    final categories = [
      const CategoryModel(
        id: 'all',
        title: 'All',
        icon: '✨',
      ),
      ...dummyCategories,
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(restaurantProvider.notifier).loadRestaurants();
            await ref.read(favouriteProvider.notifier).loadFavourites();
          },
          child: restaurantState.when(
            data: (restaurants) {
              final filteredRestaurants = getFilteredRestaurants(restaurants);
              final popularRestaurants = restaurants.take(5).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
                children: [
                  const _TopLocationBar(),

                  const SizedBox(height: 24),

                  const Text(
                    'What would you like\nto eat today?',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 31,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _SearchBar(
                    controller: searchController,
                    searchQuery: searchQuery,
                    selectedCategory: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim();
                      });
                    },
                    onClear: clearSearchAndFilter,
                  ),

                  const SizedBox(height: 20),

                  _CategoryChips(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onSelected: (category) {
                      setState(() {
                        selectedCategory = category.title;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const _WoltDarkPromoBanner(),

                  const SizedBox(height: 28),

                  if (searchQuery.isEmpty && selectedCategory == 'All') ...[
                    _SectionTitle(
                      title: 'Popular near you',
                      actionText: 'See all',
                      onActionTap: () {},
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 255,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = popularRestaurants[index];

                          final isFavourite = favouriteRestaurants.any((item) {
                            return item.id == restaurant.id;
                          });

                          return _FeaturedRestaurantCard(
                            restaurant: restaurant,
                            isFavourite: isFavourite,
                            onFavouriteTap: () {
                              ref
                                  .read(favouriteProvider.notifier)
                                  .toggleFavourite(restaurant);
                            },
                            onTap: () {
                              context.push(
                                '/restaurant/${restaurant.id}',
                                extra: restaurant,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],

                  _SectionTitle(
                    title: selectedCategory == 'All'
                        ? 'All restaurants'
                        : '$selectedCategory restaurants',
                    actionText:
                        searchQuery.isNotEmpty || selectedCategory != 'All'
                            ? 'Clear'
                            : null,
                    onActionTap:
                        searchQuery.isNotEmpty || selectedCategory != 'All'
                            ? clearSearchAndFilter
                            : null,
                  ),

                  const SizedBox(height: 14),

                  if (filteredRestaurants.isEmpty)
                    const _EmptyRestaurantResult()
                  else
                    ListView.builder(
                      itemCount: filteredRestaurants.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final restaurant = filteredRestaurants[index];

                        final isFavourite = favouriteRestaurants.any((item) {
                          return item.id == restaurant.id;
                        });

                        return _RestaurantListTile(
                          restaurant: restaurant,
                          isFavourite: isFavourite,
                          onFavouriteTap: () {
                            ref
                                .read(favouriteProvider.notifier)
                                .toggleFavourite(restaurant);
                          },
                          onTap: () {
                            context.push(
                              '/restaurant/${restaurant.id}',
                              extra: restaurant,
                            );
                          },
                        );
                      },
                    ),
                ],
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            error: (error, _) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopLocationBar extends StatelessWidget {
  const _TopLocationBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: AppTheme.primary,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivering to',
                style: TextStyle(
                  color: AppTheme.lightText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Current location',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            context.push('/profile');
          },
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final String selectedCategory;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppTheme.darkText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search restaurants or dishes',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: searchQuery.isEmpty && selectedCategory == 'All'
            ? const Icon(Icons.tune_rounded)
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategory;
  final ValueChanged<CategoryModel> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category.title;

          return GestureDetector(
            onTap: () {
              onSelected(category);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Text(category.icon),
                  const SizedBox(width: 7),
                  Text(
                    category.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkText,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WoltDarkPromoBanner extends StatelessWidget {
  const _WoltDarkPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00AEEF),
            Color(0xFF026A91),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free delivery\nfor today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Order from top restaurants near you.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionTitle({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeaturedRestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final bool isFavourite;
  final VoidCallback onFavouriteTap;
  final VoidCallback onTap;

  const _FeaturedRestaurantCard({
    required this.restaurant,
    required this.isFavourite,
    required this.onFavouriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: restaurant.isOpen ? 1 : 0.55,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 245,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: restaurant.imageUrl,
                    fallbackIcon: Icons.restaurant_rounded,
                    height: 145,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavouriteTap,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black.withOpacity(0.55),
                        child: Icon(
                          isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border_rounded,
                          color: isFavourite ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        restaurant.isOpen ? 'Open now' : 'Closed',
                        style: TextStyle(
                          color: restaurant.isOpen
                              ? AppTheme.primary
                              : AppTheme.lightText,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      restaurant.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RestaurantMetaRow(restaurant: restaurant),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantListTile extends StatelessWidget {
  final RestaurantModel restaurant;
  final bool isFavourite;
  final VoidCallback onFavouriteTap;
  final VoidCallback onTap;

  const _RestaurantListTile({
    required this.restaurant,
    required this.isFavourite,
    required this.onFavouriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: restaurant.isOpen ? 1 : 0.55,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(10),
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
                fallbackIcon: Icons.restaurant_rounded,
                height: 94,
                width: 94,
                borderRadius: BorderRadius.circular(22),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      restaurant.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RestaurantMetaRow(restaurant: restaurant),
                    const SizedBox(height: 8),
                    Text(
                      restaurant.deliveryFee,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: onFavouriteTap,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                    color: isFavourite ? Colors.redAccent : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantMetaRow extends StatelessWidget {
  final RestaurantModel restaurant;

  const _RestaurantMetaRow({
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          size: 17,
          color: Color(0xFFFFC542),
        ),
        const SizedBox(width: 3),
        Text(
          restaurant.rating,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.schedule_rounded,
          size: 15,
          color: AppTheme.lightText,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            restaurant.deliveryTime,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyRestaurantResult extends StatelessWidget {
  const _EmptyRestaurantResult();

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
            Icons.search_off_rounded,
            color: AppTheme.primary,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No restaurants found',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try a different search or category.',
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