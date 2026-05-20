import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurant_model.dart';
import 'auth_provider.dart';

class RestaurantNotifier extends AsyncNotifier<List<RestaurantModel>> {
  late final FirebaseFirestore _firestore;

  @override
  Future<List<RestaurantModel>> build() async {
    _firestore = ref.watch(firestoreProvider);

    return loadRestaurants();
  }

  Future<List<RestaurantModel>> loadRestaurants() async {
    state = const AsyncValue.loading();

    try {
      debugPrint('FETCHING RESTAURANTS FROM PROJECT...');
      debugPrint('FIRESTORE APP NAME: ${_firestore.app.name}');
      debugPrint('FIRESTORE PROJECT ID: ${_firestore.app.options.projectId}');

      final snapshot = await _firestore.collection('restaurants').get();

      debugPrint('RESTAURANTS COUNT: ${snapshot.docs.length}');

      final restaurants = snapshot.docs.map((doc) {
        debugPrint('RESTAURANT DOC ID: ${doc.id}');
        debugPrint('RESTAURANT DATA: ${doc.data()}');

        return RestaurantModel.fromFirestore(doc);
      }).toList();

      restaurants.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(restaurants);

      return restaurants;
    } catch (error, stackTrace) {
      debugPrint('RESTAURANT FETCH ERROR: $error');

      state = AsyncValue.error(error, stackTrace);

      return [];
    }
  }
}

final restaurantProvider =
    AsyncNotifierProvider<RestaurantNotifier, List<RestaurantModel>>(
  RestaurantNotifier.new,
);