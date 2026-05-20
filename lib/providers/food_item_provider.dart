import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_item_model.dart';
import 'auth_provider.dart';

final foodItemsProvider =
    FutureProvider.family<List<FoodItemModel>, String>((ref, restaurantId) async {
  final firestore = ref.watch(firestoreProvider);

  debugPrint('FETCHING FOOD ITEMS FOR RESTAURANT ID: $restaurantId');
  debugPrint('FIRESTORE PROJECT ID: ${firestore.app.options.projectId}');

  final snapshot = await firestore
      .collection('restaurants')
      .doc(restaurantId)
      .collection('foodItems')
      .get();

  debugPrint('FOOD ITEMS COUNT: ${snapshot.docs.length}');

  final foodItems = snapshot.docs.map((doc) {
    debugPrint('FOOD ITEM DOC ID: ${doc.id}');
    debugPrint('FOOD ITEM DATA: ${doc.data()}');

    return FoodItemModel.fromFirestore(
      restaurantId: restaurantId,
      doc: doc,
    );
  }).toList();

  foodItems.sort((a, b) => a.name.compareTo(b.name));

  return foodItems;
});