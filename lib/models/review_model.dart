import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] == null
          ? DateTime.now()
          : (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}