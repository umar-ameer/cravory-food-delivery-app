import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String category;
  final String rating;
  final String deliveryTime;
  final String deliveryFee;
  final String imageUrl;
  final bool isOpen;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.imageUrl,
    required this.isOpen,
  });

  factory RestaurantModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      rating: data['rating']?.toString() ?? '0.0',
      deliveryTime: data['deliveryTime'] ?? '',
      deliveryFee: data['deliveryFee'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isOpen: data['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}