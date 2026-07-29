import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/features/auth/screens/authforgot.dart';
import 'package:Saborly/features/auth/screens/authreset.dart';
import 'package:Saborly/features/auth/screens/changeword.dart';
import 'package:Saborly/features/home/screens/branch_selection_screen.dart';
import 'package:Saborly/features/home/screens/SplashScreen.dart';
import 'package:Saborly/features/menu/screens/AboutUsScreen.dart';
import 'package:Saborly/features/menu/screens/cart_screen.dart';
import 'package:Saborly/features/auth/screens/eemailVerificationScreen.dart';
import 'package:Saborly/features/menu/screens/notifications_screen.dart';
import 'package:Saborly/features/menu/screens/offersScreen.dart';
import 'package:Saborly/features/menu/screens/order_history.dart';
import 'package:Saborly/features/menu/screens/order_status.dart';
import 'package:Saborly/features/menu/screens/ourfaq.dart';
import 'package:Saborly/features/menu/screens/ourprivacy.dart';
import 'package:Saborly/features/menu/screens/payment_scree.dart';
import 'package:Saborly/features/menu/screens/profile_screen.dart';
import 'package:Saborly/features/menu/screens/search_results_page.dart';
import 'package:Saborly/features/menu/screens/theContactScreen.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/menu/screens/checkout_screen.dart';
import '../../features/menu/screens/menu_screen.dart';
import '../../features/menu/screens/food_detail_screen.dart';

import '../../shared/widgets/main_layout.dart';
import '../../shared/models/food_item.dart';

class AppRoutes {
  static const String splash = '/';
  static const String branchSelect = '/branch-select';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String orders = '/orders';
  static const String privacy = '/privacy';
static const String faq = '/faq';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String offer = '/offer';
  static const String notifications = '/notifications'; // ✅ ADD THIS

  static const String orderStatus = '/order-status/:orderId';
  static const String emailVerification = '/email-verification';
 static const String about = '/about';
  static const String contact = '/contact';
  static const String search = '/search'; // ✅ NEW: Add search route

  static const String foodDetail = '/food-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String profile = '/profile';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    // Web → branch selection landing page  |  Mobile → splash screen
    initialLocation: splash,
    observers: [HomeScreen.routeObserver],

    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;

      // Routes that require authentication
      final protectedRoutes = [checkout, payment, orderStatus, profile];
      final isProtectedRoute = protectedRoutes.contains(state.matchedLocation);

      if (isProtectedRoute && !isLoggedIn) {
        return login;
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: menu,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final categoryId = extra?['category'] as String?;
              return MenuScreen(categoryId: categoryId);
            },
          ),
          GoRoute(
            path: about,
            name: 'about',
            builder: (context, state) => const AboutUsScreen(),
          ),
          GoRoute(
            path: contact,
            name: 'contact',
            builder: (context, state) => const ContactScreen(),
          ),
          GoRoute(
            path: offer,
            name: 'offer',
            builder: (context, state) => const OffersScreen(),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
           GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
        GoRoute(
        path: orders,
        name: 'orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
          GoRoute(
            path: notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
      GoRoute(
        path: resetPassword,
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: foodDetail,
        name: 'food-detail',
        builder: (context, state) {
          final foodItem = state.extra as FoodItem;
          return FoodDetailScreen(foodItem: foodItem);
        },
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
  path: privacy,
  name: 'privacy',
  builder: (context, state) => const PrivacyPolicyScreen(),
),
GoRoute(
  path: faq,
  name: 'faq',
  builder: (context, state) => const FAQScreen(),
),
      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: payment,
        name: 'payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
        ],
      ),
     
      // Root route: branch selection on web, splash on mobile
      GoRoute(
        path: splash,
        builder: (context, state) => kIsWeb
            ? const BranchSelectionScreen()
            : const SplashScreen(),
      ),
      GoRoute(
        path: branchSelect,
        builder: (context, state) => const BranchSelectionScreen(),
      ),
      GoRoute(
        path: emailVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OTPVerificationScreen(email: email);
        },
      ),
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) {
            final initialQuery = state.extra as String?;
            return SearchResultsPage(initialQuery: initialQuery);
          },
        ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: orderStatus,
        name: 'order-status',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderStatusScreen(orderId: orderId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}
