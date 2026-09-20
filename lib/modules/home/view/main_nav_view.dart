import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../analytics/view/analytics_dashboard_view.dart';
import '../../cart/bloc/cart/cart_bloc.dart';
import '../../cart/view/cart_view.dart';
import '../../cart/view/wishlist_view.dart';
import '../../profile/view/profile_view.dart';
import 'home_view.dart';

class MainNavView extends StatefulWidget {
  const MainNavView({super.key});

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    WishlistView(),
    CartView(),
    AnalyticsDashboardView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            final count = cartState.totalItemCount;
            return NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) {
                setState(() {
                  _currentIndex = idx;
                });
              },
              backgroundColor: AppColors.white,
              indicatorColor: AppColors.primaryLight,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: AppColors.primary),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon:
                      Icon(Icons.favorite_rounded, color: AppColors.primary),
                  label: 'Wishlist',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: AppColors.primary),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon:
                      Icon(Icons.insights_rounded, color: AppColors.primary),
                  label: 'Analytics',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
