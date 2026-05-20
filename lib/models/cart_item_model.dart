import 'food_item_model.dart';

class CartItemModel {
  final FoodItemModel foodItem;
  final int quantity;

  const CartItemModel({
    required this.foodItem,
    required this.quantity,
  });

  CartItemModel copyWith({
    FoodItemModel? foodItem,
    int? quantity,
  }) {
    return CartItemModel(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice {
    return foodItem.price * quantity;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'foodItemId': foodItem.id,
      'restaurantId': foodItem.restaurantId,
      'name': foodItem.name,
      'description': foodItem.description,
      'price': foodItem.price,
      'imageUrl': foodItem.imageUrl,
      'isVeg': foodItem.isVeg,
      'isAvailable': foodItem.isAvailable,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory CartItemModel.fromFirestore(Map<String, dynamic> data) {
    final foodItem = FoodItemModel(
      id: data['foodItemId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isVeg: data['isVeg'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
    );

    return CartItemModel(
      foodItem: foodItem,
      quantity: data['quantity'] ?? 1,
    );
  }
}