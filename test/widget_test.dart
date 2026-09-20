import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testprojectnew/core/routes/app_routes.dart';

void main() {
  test('AppRoutes configuration contains all primary screen routes', () {
    expect(AppRoutes.splash, equals('/'));
    expect(AppRoutes.login, equals('/login'));
    expect(AppRoutes.register, equals('/register'));
    expect(AppRoutes.onboarding, equals('/onboarding'));
    expect(AppRoutes.mainNav, equals('/main-nav'));
    expect(AppRoutes.home, equals('/home'));
    expect(AppRoutes.search, equals('/search'));
    expect(AppRoutes.cart, equals('/cart'));
    expect(AppRoutes.wishlist, equals('/wishlist'));
    expect(AppRoutes.checkout, equals('/checkout'));
    expect(AppRoutes.orderSuccess, equals('/order-success'));
    expect(AppRoutes.orderHistory, equals('/order-history'));
    expect(AppRoutes.profile, equals('/profile'));
    expect(AppRoutes.editProfile, equals('/edit-profile'));
    expect(AppRoutes.analytics, equals('/analytics'));

    // Verify all routes are mapped
    expect(AppRoutes.routes.containsKey(AppRoutes.splash), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.login), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.register), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.mainNav), isTrue);
  });

  testWidgets('AppRoutes dynamic generator handles route arguments', (tester) async {
    final productListRoute = AppRoutes.onGenerateRoute(
      const RouteSettings(name: AppRoutes.productList, arguments: 'smartphones'),
    );
    expect(productListRoute, isNotNull);

    final productDetailRoute = AppRoutes.onGenerateRoute(
      const RouteSettings(name: AppRoutes.productDetail, arguments: 101),
    );
    expect(productDetailRoute, isNotNull);
  });
}
