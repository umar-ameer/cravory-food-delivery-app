import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_model.dart';
import 'auth_provider.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return ReviewService(
    firestore: firestore,
    ref: ref,
  );
});

final restaurantReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, restaurantId) async {
  final service = ref.watch(reviewServiceProvider);

  return service.getReviewsByRestaurantId(restaurantId);
});

class ReviewStats {
  final double averageRating;
  final int totalReviews;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
  });
}

final restaurantReviewStatsProvider =
    FutureProvider.family<ReviewStats, String>((ref, restaurantId) async {
  final reviews = await ref.watch(
    restaurantReviewsProvider(restaurantId).future,
  );

  if (reviews.isEmpty) {
    return const ReviewStats(
      averageRating: 0,
      totalReviews: 0,
    );
  }

  final totalRating = reviews.fold<double>(0, (sum, review) {
    return sum + review.rating;
  });

  return ReviewStats(
    averageRating: totalRating / reviews.length,
    totalReviews: reviews.length,
  );
});

class ReviewService {
  final FirebaseFirestore firestore;
  final Ref ref;

  ReviewService({
    required this.firestore,
    required this.ref,
  });

  Future<void> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
  }) async {
    final user = ref.read(authProvider).value;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final reviewRef = firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .doc();

    final review = ReviewModel(
      id: reviewRef.id,
      restaurantId: restaurantId,
      userId: user.id,
      userName: user.name.isNotEmpty ? user.name : 'User',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await reviewRef.set(review.toFirestore());
  }

  Future<List<ReviewModel>> getReviewsByRestaurantId(
    String restaurantId,
  ) async {
    final snapshot = await firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ReviewModel.fromFirestore(doc);
    }).toList();
  }
}