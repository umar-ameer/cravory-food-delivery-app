import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurant_model.dart';
import 'auth_provider.dart';

class FavouriteNotifier extends AsyncNotifier<List<RestaurantModel>> {
  late final FirebaseFirestore _firestore;

  String? get _userId {
    return ref.read(firebaseAuthProvider).currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>>? get _favouritesCollection {
    final userId = _userId;

    if (userId == null) {
      return null;
    }

    return _firestore.collection('users').doc(userId).collection('favourites');
  }

  @override
  Future<List<RestaurantModel>> build() async {
    _firestore = ref.watch(firestoreProvider);
    return loadFavourites();
  }

  Future<List<RestaurantModel>> loadFavourites() async {
    final collection = _favouritesCollection;

    if (collection == null) {
      state = const AsyncValue.data([]);
      return [];
    }

    state = const AsyncValue.loading();

    try {
      final snapshot = await collection.get();

      final favourites = snapshot.docs.map((doc) {
        return RestaurantModel.fromFirestore(doc);
      }).toList();

      favourites.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(favourites);
      return favourites;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  bool isFavourite(String restaurantId) {
    final favourites = state.value ?? [];

    return favourites.any((restaurant) {
      return restaurant.id == restaurantId;
    });
  }

  Future<void> toggleFavourite(RestaurantModel restaurant) async {
    final collection = _favouritesCollection;

    if (collection == null) {
      return;
    }

    final currentFavourites = state.value ?? [];
    final alreadyFavourite = currentFavourites.any((item) {
      return item.id == restaurant.id;
    });

    try {
      if (alreadyFavourite) {
        await collection.doc(restaurant.id).delete();

        final updatedFavourites = currentFavourites.where((item) {
          return item.id != restaurant.id;
        }).toList();

        state = AsyncValue.data(updatedFavourites);
      } else {
        await collection.doc(restaurant.id).set({
          ...restaurant.toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        state = AsyncValue.data([
          restaurant,
          ...currentFavourites,
        ]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final favouriteProvider =
    AsyncNotifierProvider<FavouriteNotifier, List<RestaurantModel>>(
  FavouriteNotifier.new,
);