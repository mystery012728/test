import 'package:flutter/material.dart';

class InterestCategoryModel {
  final String slug;
  final String name;
  final IconData icon;

  const InterestCategoryModel({
    required this.slug,
    required this.name,
    required this.icon,
  });

  // Default available categories matching DummyJSON API categories
  static List<InterestCategoryModel> get defaultCategories => const [
        InterestCategoryModel(slug: 'smartphones', name: 'Smartphones', icon: Icons.phone_android_rounded),
        InterestCategoryModel(slug: 'laptops', name: 'Laptops', icon: Icons.laptop_mac_rounded),
        InterestCategoryModel(slug: 'fragrances', name: 'Fragrances', icon: Icons.local_florist_rounded),
        InterestCategoryModel(slug: 'beauty', name: 'Beauty', icon: Icons.brush_rounded),
        InterestCategoryModel(slug: 'groceries', name: 'Groceries', icon: Icons.shopping_basket_rounded),
        InterestCategoryModel(slug: 'home-decoration', name: 'Home Decor', icon: Icons.home_rounded),
        InterestCategoryModel(slug: 'furniture', name: 'Furniture', icon: Icons.chair_rounded),
        InterestCategoryModel(slug: 'mens-shirts', name: 'Men Shirts', icon: Icons.checkroom_rounded),
        InterestCategoryModel(slug: 'mens-shoes', name: 'Men Shoes', icon: Icons.roller_skating_rounded),
        InterestCategoryModel(slug: 'mens-watches', name: 'Men Watches', icon: Icons.watch_rounded),
        InterestCategoryModel(slug: 'womens-dresses', name: 'Women Dresses', icon: Icons.dry_cleaning_rounded),
        InterestCategoryModel(slug: 'womens-shoes', name: 'Women Shoes', icon: Icons.hiking_rounded),
        InterestCategoryModel(slug: 'womens-watches', name: 'Women Watches', icon: Icons.access_time_rounded),
        InterestCategoryModel(slug: 'womens-bags', name: 'Women Bags', icon: Icons.shopping_bag_rounded),
        InterestCategoryModel(slug: 'sunglasses', name: 'Sunglasses', icon: Icons.visibility_rounded),
        InterestCategoryModel(slug: 'motorcycle', name: 'Motorcycle', icon: Icons.two_wheeler_rounded),
        InterestCategoryModel(slug: 'sports-accessories', name: 'Sports', icon: Icons.fitness_center_rounded),
      ];
}
