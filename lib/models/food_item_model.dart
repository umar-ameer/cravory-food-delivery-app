import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isVeg;
  final bool isAvailable;

  const FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isVeg,
    required this.isAvailable,
  });

  factory FoodItemModel.fromFirestore({
    required String restaurantId,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? {};

    return FoodItemModel(
      id: doc.id,
      restaurantId: restaurantId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isVeg: data['isVeg'] ?? true,
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}