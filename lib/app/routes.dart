import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/splash_screen.dart';

import '../features/main/main_shell_screen.dart';

import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/checkout/order_success_screen.dart';

import '../features/orders/order_details_screen.dart';
import '../features/orders/order_tracking_screen.dart';

import '../features/profile/add_address_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/favourite_restaurants_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/switch_role_screen.dart';

import '../features/restaurant/restaurant_detail_screen.dart';
import '../features/reviews/add_review_screen.dart';
import '../features/notifications/notifications_screen.dart';

import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_orders_screen.dart';
import '../features/admin/admin_order_details_screen.dart';
import '../features/admin/add_restaurant_screen.dart';
import '../features/admin/add_food_item_screen.dart';

import '../features/delivery/delivery_dashboard_screen.dart';
import '../features/delivery/delivery_orders_screen.dart';
import '../features/delivery/delivery_order_details_screen.dart';

import '../models/restaurant_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) {
          return const SignupScreen();
        },
      ),

      GoRoute(
        path: '/',
        builder: (context, state) {
          return const MainShellScreen();
        },
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),

      GoRoute(
        path: '/switch-role',
        builder: (context, state) {
          return const SwitchRoleScreen();
        },
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          return const NotificationsScreen();
        },
      ),

      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) {
          final restaurant = state.extra as RestaurantModel;

          return RestaurantDetailScreen(
            restaurant: restaurant,
          );
        },
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) {
          return const CartScreen();
        },
      ),

      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          return const CheckoutScreen();
        },
      ),

      GoRoute(
        path: '/order-success/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;

          return OrderSuccessScreen(
            orderId: orderId,
          );
        },
      ),

      GoRoute(
        path: '/order-details/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;

          return OrderDetailsScreen(
            orderId: orderId,
          );
        },
      ),

      GoRoute(
        path: '/track-order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;

          return OrderTrackingScreen(
            orderId: orderId,
          );
        },
      ),

      GoRoute(
        path: '/add-review/:restaurantId',
        builder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId']!;

          return AddReviewScreen(
            restaurantId: restaurantId,
          );
        },
      ),

      GoRoute(
        path: '/add-address',
        builder: (context, state) {
          return const AddAddressScreen();
        },
      ),

      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          return const EditProfileScreen();
        },
      ),

      GoRoute(
        path: '/favourites',
        builder: (context, state) {
          return const FavouriteRestaurantsScreen();
        },
      ),

      // Admin routes
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) {
          return const AdminDashboardScreen();
        },
      ),

      GoRoute(
        path: '/admin-orders',
        builder: (context, state) {
          return const AdminOrdersScreen();
        },
      ),

      GoRoute(
        path: '/admin-order-details',
        builder: (context, state) {
          final orderPath = state.extra as String;

          return AdminOrderDetailsScreen(
            orderPath: orderPath,
          );
        },
      ),

      GoRoute(
        path: '/admin-add-restaurant',
        builder: (context, state) {
          return const AddRestaurantScreen();
        },
      ),

      GoRoute(
        path: '/admin-add-food-item',
        builder: (context, state) {
          return const AddFoodItemScreen();
        },
      ),

      // Delivery routes
      GoRoute(
        path: '/delivery-dashboard',
        builder: (context, state) {
          return const DeliveryDashboardScreen();
        },
      ),

      GoRoute(
        path: '/delivery-orders',
        builder: (context, state) {
          return const DeliveryOrdersScreen();
        },
      ),

      GoRoute(
        path: '/delivery-order-details',
        builder: (context, state) {
          final orderPath = state.extra as String;

          return DeliveryOrderDetailsScreen(
            orderPath: orderPath,
          );
        },
      ),
    ],
  );
});