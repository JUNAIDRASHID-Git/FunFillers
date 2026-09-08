import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/checkout_screen.dart';
import '../../presentation/screens/main_layout_screen.dart';
import '../../presentation/screens/order_history_screen.dart';
import '../../presentation/screens/order_success_screen.dart';
import '../../presentation/screens/product_details_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/sign_in_screen.dart';
import '../../presentation/screens/sign_up_screen.dart';
import '../../presentation/screens/splash_onboarding_screen.dart';
import '../../presentation/screens/wishlist_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashOnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_details',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          final productEntity = state.extra as ProductEntity?;
          return ProductDetailsScreen(
            product: productEntity,
            productId: productId,
          );
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/order-success',
        name: 'order_success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OrderSuccessScreen(
            orderId: extra?['orderId'] ?? 'ORD-000000',
          );
        },
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
