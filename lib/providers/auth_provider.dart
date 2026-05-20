import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseFirestore _firestore;

  @override
  Future<UserModel?> build() async {
    _firebaseAuth = ref.watch(firebaseAuthProvider);
    _firestore = ref.watch(firestoreProvider);

    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return _fetchUserProfile(firebaseUser.uid);
  }

  Future<UserModel?> _fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final fallbackUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Cravory User',
        email: firebaseUser.email ?? '',
        phoneNumber: '',
        role: 'customer',
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(fallbackUser.toFirestore());

      return fallbackUser;
    }

    final userProfile = UserModel.fromFirestore(doc);

    final data = doc.data() as Map<String, dynamic>? ?? {};

    if (!data.containsKey('role') || userProfile.role.isEmpty) {
      await _firestore.collection('users').doc(uid).update({
        'role': 'customer',
      });

      return userProfile.copyWith(role: 'customer');
    }

    return userProfile;
  }

  Future<void> loadCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final userProfile = await _fetchUserProfile(firebaseUser.uid);
      state = AsyncValue.data(userProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        state = AsyncValue.error('Login failed', StackTrace.current);
        return;
      }

      final userProfile = await _fetchUserProfile(firebaseUser.uid);

      state = AsyncValue.data(userProfile);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncValue.error(
        error.message ?? 'Login failed',
        stackTrace,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        'Something went wrong',
        stackTrace,
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        state = AsyncValue.error('Signup failed', StackTrace.current);
        return;
      }

      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();

      final userProfile = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        role: 'customer',
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userProfile.toFirestore());

      state = AsyncValue.data(userProfile);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncValue.error(
        error.message ?? 'Signup failed',
        stackTrace,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        'Something went wrong',
        stackTrace,
      );
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String phoneNumber,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await firebaseUser.updateDisplayName(name);

      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'name': name,
        'phoneNumber': phoneNumber,
      });

      final updatedUser = await _fetchUserProfile(firebaseUser.uid);

      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUserRole(String role) async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    if (role != 'customer' && role != 'admin' && role != 'delivery') {
      state = AsyncValue.error('Invalid role selected', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'role': role,
      });

      final updatedUser = await _fetchUserProfile(firebaseUser.uid);

      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );

      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final userProfile = await _fetchUserProfile(currentUser.uid);
      state = AsyncValue.data(userProfile);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncValue.error(
        error.message ?? 'Failed to send reset email',
        stackTrace,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        'Something went wrong',
        stackTrace,
      );
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    state = const AsyncValue.data(null);
  }

  bool get isAdmin {
    return state.value?.role == 'admin';
  }

  bool get isDeliveryPartner {
    return state.value?.role == 'delivery';
  }

  bool get isCustomer {
    return state.value?.role == 'customer';
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);