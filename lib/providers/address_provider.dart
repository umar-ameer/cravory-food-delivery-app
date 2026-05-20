import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_model.dart';

class AddressNotifier extends AsyncNotifier<List<AddressModel>> {
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;

  @override
  Future<List<AddressModel>> build() async {
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;

    final userId = _userId;
    if (userId == null) {
      return [];
    }

    return _fetchAddresses();
  }

  String? get _userId {
    final user = _firebaseAuth.currentUser;
    final id = user?.uid;

    if (id == null || id.trim().isEmpty) {
      return null;
    }

    return id.trim();
  }

  CollectionReference<Map<String, dynamic>>? get _addressCollection {
    final userId = _userId;
    if (userId == null) {
      return null;
    }

    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  Future<List<AddressModel>> _fetchAddresses() async {
    final collection = _addressCollection;
    if (collection == null) {
      return [];
    }

    final snapshot = await collection.get();

    return snapshot.docs
        .map((doc) => AddressModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> loadAddresses() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _fetchAddresses());
  }

  Future<void> addAddress(AddressModel address) async {
    final collection = _addressCollection;
    if (collection == null) {
      throw Exception('User not logged in');
    }

    final previous = state.value ?? [];

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final docRef = await collection.add(address.toMap());
      final newAddress = address.copyWith(id: docRef.id);

      return [...previous, newAddress];
    });
  }

  Future<void> updateAddress(AddressModel address) async {
    final collection = _addressCollection;
    if (collection == null) {
      throw Exception('User not logged in');
    }

    final previous = state.value ?? [];

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await collection.doc(address.id).update(address.toMap());

      return previous.map((item) {
        return item.id == address.id ? address : item;
      }).toList();
    });
  }

  Future<void> deleteAddress(String addressId) async {
    final collection = _addressCollection;
    if (collection == null) {
      throw Exception('User not logged in');
    }

    final previous = state.value ?? [];

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await collection.doc(addressId).delete();

      return previous.where((item) => item.id != addressId).toList();
    });
  }

  Future<void> setDefaultAddress(String addressId) async {
    final collection = _addressCollection;
    if (collection == null) {
      throw Exception('User not logged in');
    }

    final previous = state.value ?? [];

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final batch = _firestore.batch();

      for (final address in previous) {
        final docRef = collection.doc(address.id);
        batch.update(docRef, {
          'isDefault': address.id == addressId,
        });
      }

      await batch.commit();

      return previous.map((address) {
        return address.copyWith(
          isDefault: address.id == addressId,
        );
      }).toList();
    });
  }
}

final addressProvider =
    AsyncNotifierProvider<AddressNotifier, List<AddressModel>>(
  AddressNotifier.new,
);