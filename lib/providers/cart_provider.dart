import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';

class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() {
    return [];
  }

  double get totalAmount {
    return state.fold<double>(0, (total, item) {
      return total + item.totalPrice;
    });
  }

  void addItem(FoodItemModel foodItem) {
    final existingIndex = state.indexWhere((cartItem) {
      return cartItem.foodItem.id == foodItem.id;
    });

    if (existingIndex == -1) {
      state = [
        ...state,
        CartItemModel(
          foodItem: foodItem,
          quantity: 1,
        ),
      ];
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == existingIndex)
          state[i].copyWith(
            quantity: state[i].quantity + 1,
          )
        else
          state[i],
    ];
  }

  void increaseQuantity(String foodItemId) {
    state = [
      for (final item in state)
        if (item.foodItem.id == foodItemId)
          item.copyWith(
            quantity: item.quantity + 1,
          )
        else
          item,
    ];
  }

  void decreaseQuantity(String foodItemId) {
    final updatedItems = <CartItemModel>[];

    for (final item in state) {
      if (item.foodItem.id == foodItemId) {
        if (item.quantity > 1) {
          updatedItems.add(
            item.copyWith(
              quantity: item.quantity - 1,
            ),
          );
        }

        // If quantity is 1, we do not add it back.
        // This removes the item from cart and ADD button will show again.
      } else {
        updatedItems.add(item);
      }
    }

    state = updatedItems;
  }

  void removeItem(String foodItemId) {
    state = state.where((item) {
      return item.foodItem.id != foodItemId;
    }).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,
);