import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';
import 'auth_provider.dart';

class SeedDataService {
  final FirebaseFirestore _firestore;

  SeedDataService(this._firestore);

  Future<void> seedRestaurantsAndFoodItems() async {
    final restaurantsSnapshot =
        await _firestore.collection('restaurants').limit(1).get();

    if (restaurantsSnapshot.docs.isNotEmpty) {
      return;
    }

    final restaurants = _restaurantsWithFoodItems();

    for (final entry in restaurants.entries) {
      final restaurant = entry.key;
      final foodItems = entry.value;

      final restaurantDoc =
          await _firestore.collection('restaurants').add(restaurant.toFirestore());

      for (final foodItem in foodItems) {
        final itemWithRestaurantId = FoodItemModel(
          id: foodItem.id,
          restaurantId: restaurantDoc.id,
          name: foodItem.name,
          description: foodItem.description,
          price: foodItem.price,
          imageUrl: foodItem.imageUrl,
          isVeg: foodItem.isVeg,
          isAvailable: foodItem.isAvailable,
        );

        await restaurantDoc
            .collection('foodItems')
            .add(itemWithRestaurantId.toFirestore());
      }
    }
  }

  Map<RestaurantModel, List<FoodItemModel>> _restaurantsWithFoodItems() {
    return {
      const RestaurantModel(
        id: '',
        name: 'Urban Pizza Co.',
        category: 'Pizza • Italian • Fast Food',
        rating: '4.7',
        deliveryTime: '25-35 min',
        deliveryFee: '₹39 delivery',
        imageUrl: '',
        isOpen: true,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Margherita Pizza',
          description: 'Classic cheese pizza with tomato sauce and basil.',
          price: 249,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Farmhouse Pizza',
          description: 'Loaded with capsicum, onion, tomato, corn and cheese.',
          price: 329,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Pepperoni Pizza',
          description: 'Cheesy pizza topped with spicy pepperoni slices.',
          price: 399,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
      ],

      const RestaurantModel(
        id: '',
        name: 'Burger House',
        category: 'Burgers • Fries • Shakes',
        rating: '4.5',
        deliveryTime: '20-30 min',
        deliveryFee: '₹29 delivery',
        imageUrl: '',
        isOpen: true,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Classic Chicken Burger',
          description: 'Juicy chicken patty with cheese and fresh veggies.',
          price: 199,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Cheese Burger',
          description: 'Crispy veg patty, cheese slice and special sauce.',
          price: 149,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Loaded Fries',
          description: 'Crispy fries loaded with cheese and herbs.',
          price: 129,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
      ],

      const RestaurantModel(
        id: '',
        name: 'Tandoori Junction',
        category: 'North Indian • Tandoor',
        rating: '4.6',
        deliveryTime: '30-40 min',
        deliveryFee: '₹49 delivery',
        imageUrl: '',
        isOpen: true,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Paneer Tikka',
          description: 'Soft paneer cubes grilled with spicy tandoori marinade.',
          price: 259,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Chicken Tikka',
          description: 'Tender chicken pieces cooked in a clay oven.',
          price: 329,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Butter Naan',
          description: 'Soft Indian bread brushed with butter.',
          price: 49,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
      ],

      const RestaurantModel(
        id: '',
        name: 'The Biryani Pot',
        category: 'Biryani • Mughlai',
        rating: '4.8',
        deliveryTime: '35-45 min',
        deliveryFee: '₹59 delivery',
        imageUrl: '',
        isOpen: true,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Hyderabadi Chicken Biryani',
          description: 'Aromatic basmati rice cooked with spicy chicken masala.',
          price: 299,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Veg Dum Biryani',
          description: 'Slow-cooked biryani with vegetables and rich spices.',
          price: 229,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Chicken Kebab',
          description: 'Smoky kebabs served with mint chutney.',
          price: 249,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
      ],

      const RestaurantModel(
        id: '',
        name: 'Green Bowl Cafe',
        category: 'Healthy • Salads • Bowls',
        rating: '4.4',
        deliveryTime: '15-25 min',
        deliveryFee: 'Free delivery',
        imageUrl: '',
        isOpen: true,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Greek Salad Bowl',
          description: 'Fresh veggies, olives, feta cheese and house dressing.',
          price: 179,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Protein Power Bowl',
          description: 'Healthy bowl with paneer, rice and vegetables.',
          price: 229,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Chicken Caesar Wrap',
          description: 'Grilled chicken, lettuce, caesar sauce and soft wrap.',
          price: 249,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
      ],

      const RestaurantModel(
        id: '',
        name: 'Sweet Cravings',
        category: 'Desserts • Cakes • Ice Cream',
        rating: '4.3',
        deliveryTime: '20-30 min',
        deliveryFee: '₹25 delivery',
        imageUrl: '',
        isOpen: true,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Chocolate Brownie',
          description: 'Rich chocolate brownie with a soft fudgy center.',
          price: 129,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Red Velvet Pastry',
          description: 'Soft red velvet pastry with cream cheese frosting.',
          price: 149,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Vanilla Ice Cream Cup',
          description: 'Classic vanilla ice cream served chilled.',
          price: 99,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
      ],

      const RestaurantModel(
        id: '',
        name: 'Sushi Street',
        category: 'Sushi • Asian',
        rating: '4.2',
        deliveryTime: '30-45 min',
        deliveryFee: '₹69 delivery',
        imageUrl: '',
        isOpen: false,
      ): const [
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Veg Sushi Roll',
          description: 'Fresh sushi roll with vegetables and sushi rice.',
          price: 299,
          imageUrl: '',
          isVeg: true,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Chicken Teriyaki Bowl',
          description: 'Rice bowl with chicken teriyaki and vegetables.',
          price: 349,
          imageUrl: '',
          isVeg: false,
          isAvailable: true,
        ),
        FoodItemModel(
          id: '',
          restaurantId: '',
          name: 'Miso Soup',
          description: 'Warm Japanese soup with tofu and spring onion.',
          price: 159,
          imageUrl: '',
          isVeg: true,
          isAvailable: false,
        ),
      ],
    };
  }
}

final seedDataServiceProvider = Provider<SeedDataService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SeedDataService(firestore);
});