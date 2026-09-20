import 'package:flutter/material.dart';
import '../../modules/analytics/view/analytics_dashboard_view.dart';
import '../../modules/auth/view/forgot_password_view.dart';
import '../../modules/auth/view/login_view.dart';
import '../../modules/auth/view/register_view.dart';
import '../../modules/auth/view/splash_view.dart';
import '../../modules/cart/view/cart_view.dart';
import '../../modules/cart/view/wishlist_view.dart';
import '../../modules/home/view/home_view.dart';
import '../../modules/home/view/main_nav_view.dart';
import '../../modules/onboarding/view/onboarding_view.dart';
import '../../modules/order/view/checkout_view.dart';
import '../../modules/order/view/order_history_view.dart';
import '../../modules/order/view/order_success_view.dart';
import '../../modules/product/view/product_detail_view.dart';
import '../../modules/product/view/product_list_view.dart';
import '../../modules/product/view/search_view.dart';
import '../../modules/profile/view/edit_profile_view.dart';
import '../../modules/profile/view/profile_view.dart';

class AppRoutes {
  // Route Name Constants
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String mainNav = '/main-nav';
  static const String home = '/home';
  static const String productList = '/product-list';
  static const String productDetail = '/product-detail';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orderHistory = '/order-history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String analytics = '/analytics';

  // Static Named Routes Map
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashView(),
        login: (context) => const LoginView(),
        register: (context) => const RegisterView(),
        forgotPassword: (context) => const ForgotPasswordView(),
        onboarding: (context) => const OnboardingView(),
        mainNav: (context) => const MainNavView(),
        home: (context) => const HomeView(),
        search: (context) => const SearchView(),
        cart: (context) => const CartView(),
        wishlist: (context) => const WishlistView(),
        checkout: (context) => const CheckoutView(),
        orderSuccess: (context) => const OrderSuccessView(),
        orderHistory: (context) => const OrderHistoryView(),
        profile: (context) => const ProfileView(),
        editProfile: (context) => const EditProfileView(),
        analytics: (context) => const AnalyticsDashboardView(),
      };

  // Dynamic Route Generator for Routes with Arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productList:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProductListView(category: category),
          settings: settings,
        );

      case productDetail:
        final productId = settings.arguments as int? ?? 1;
        return MaterialPageRoute(
          builder: (_) => ProductDetailView(productId: productId),
          settings: settings,
        );

      default:
        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
