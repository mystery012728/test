import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/local/local_preference.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../cart/bloc/wishlist/wishlist_bloc.dart';
import '../../order/bloc/order_bloc.dart';
import '../../order/models/order_model.dart';

class AnalyticsDashboardView extends StatefulWidget {
  const AnalyticsDashboardView({super.key});

  @override
  State<AnalyticsDashboardView> createState() => _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<AnalyticsDashboardView> {
  @override
  void initState() {
    super.initState();
    // Ensure fresh orders and wishlist data are loaded
    context.read<OrderBloc>().add(const LoadOrderHistoryEvent());
    context.read<WishlistBloc>().add(const LoadWishlistEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? const CustomBackButton()
            : null,
        title: Text(
          'Analytics & Insights',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, orderState) {
          return BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, wishlistState) {
              final orders = orderState is OrderHistoryLoaded
                  ? orderState.orders
                  : <OrderModel>[];

              final wishlistCount = wishlistState is WishlistLoaded
                  ? wishlistState.items.length
                  : LocalPreference.getWishlistProductIds().length;

              // Dynamic Calculations from Cloud Firestore Orders
              final double totalSpent = orders.fold<double>(
                0.0,
                (sum, order) => sum + order.totalAmount,
              );

              final int totalOrders = orders.length;

              // Calculate Day-of-Week spending (1 = Mon ... 7 = Sun)
              final Map<int, double> daySpending = {
                1: 0.0, // Mon
                2: 0.0, // Tue
                3: 0.0, // Wed
                4: 0.0, // Thu
                5: 0.0, // Fri
                6: 0.0, // Sat
                7: 0.0, // Sun
              };

              // Category spend distribution
              final Map<String, double> categorySpending = {};

              for (final order in orders) {
                final day = order.createdAt.weekday;
                daySpending[day] = (daySpending[day] ?? 0.0) + order.totalAmount;

                for (final item in order.items) {
                  final cat = item.category.isNotEmpty
                      ? item.category
                      : 'General';
                  final itemTotal = item.price * item.quantity;
                  categorySpending[cat] =
                      (categorySpending[cat] ?? 0.0) + itemTotal;
                }
              }

              // Top category calculation
              String topCategory = 'None';
              double topCategorySpend = 0.0;
              categorySpending.forEach((cat, spend) {
                if (spend > topCategorySpend) {
                  topCategorySpend = spend;
                  topCategory = cat;
                }
              });

              if (topCategory == 'None' && LocalPreference.favoriteCategories.isNotEmpty) {
                topCategory = LocalPreference.favoriteCategories.first;
              } else if (topCategory == 'None') {
                topCategory = 'Smartphones';
              }

              // Formatting Top category string
              final formattedTopCategory = topCategory
                  .split('-')
                  .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                  .join(' ');

              // Find peak spending day for chart height scaling
              double maxDaySpend = 0.0;
              daySpending.forEach((_, amount) {
                if (amount > maxDaySpend) maxDaySpend = amount;
              });
              if (maxDaySpend == 0.0) maxDaySpend = 1.0;

              final hasRealOrders = orders.isNotEmpty;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context
                      .read<OrderBloc>()
                      .add(const LoadOrderHistoryEvent(isRefresh: true));
                  context
                      .read<WishlistBloc>()
                      .add(const LoadWishlistEvent(isRefresh: true));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Live Sync Status Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shopping Overview',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Real-time metrics calculated from your orders',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSubtle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),

                      // Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _metricCard(
                              title: 'Total Spent',
                              value: hasRealOrders
                                  ? '\$${totalSpent.toStringAsFixed(2)}'
                                  : '\$0.00',
                              subtitle: hasRealOrders
                                  ? 'From $totalOrders placed order(s)'
                                  : 'Place order to track',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _metricCard(
                              title: 'Total Orders',
                              value: '$totalOrders Orders',
                              subtitle: hasRealOrders
                                  ? '${orders.where((o) => o.status.toLowerCase().contains("process")).length} in processing'
                                  : '0 pending',
                              icon: Icons.shopping_bag_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _metricCard(
                              title: 'Wishlist Items',
                              value: '$wishlistCount Saved',
                              subtitle: wishlistCount > 0
                                  ? 'Synced with Firestore'
                                  : 'No items saved yet',
                              icon: Icons.favorite_rounded,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _metricCard(
                              title: 'Top Category',
                              value: formattedTopCategory,
                              subtitle: hasRealOrders
                                  ? '${((topCategorySpend / (totalSpent > 0 ? totalSpent : 1)) * 100).toStringAsFixed(0)}% of purchases'
                                  : 'Based on your interests',
                              icon: Icons.category_rounded,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 22.h),

                      // Weekly Purchases Bar Chart (Dynamic Calculation)
                      Container(
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Weekly Order Activity',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  hasRealOrders
                                      ? 'Weekly: \$${totalSpent.toStringAsFixed(0)}'
                                      : 'No orders this week',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              height: 130.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _chartBar(
                                    day: 'Mon',
                                    amount: daySpending[1]!,
                                    heightFactor: (daySpending[1]! / maxDaySpend).clamp(0.08, 1.0),
                                  ),
                                  _chartBar(
                                    day: 'Tue',
                                    amount: daySpending[2]!,
                                    heightFactor: (daySpending[2]! / maxDaySpend).clamp(0.08, 1.0),
                                  ),
                                  _chartBar(
                                    day: 'Wed',
                                    amount: daySpending[3]!,
                                    heightFactor: (daySpending[3]! / maxDaySpend).clamp(0.08, 1.0),
                                  ),
                                  _chartBar(
                                    day: 'Thu',
                                    amount: daySpending[4]!,
                                    heightFactor: (daySpending[4]! / maxDaySpend).clamp(0.08, 1.0),
                                  ),
                                  _chartBar(
                                    day: 'Fri',
                                    amount: daySpending[5]!,
                                    heightFactor: (daySpending[5]! / maxDaySpend).clamp(0.08, 1.0),
                                    isHighlighted: daySpending[5]! > 0,
                                  ),
                                  _chartBar(
                                    day: 'Sat',
                                    amount: daySpending[6]!,
                                    heightFactor: (daySpending[6]! / maxDaySpend).clamp(0.08, 1.0),
                                  ),
                                  _chartBar(
                                    day: 'Sun',
                                    amount: daySpending[7]!,
                                    heightFactor: (daySpending[7]! / maxDaySpend).clamp(0.08, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 22.h),

                      // Category Breakdown Section
                      Container(
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Distribution',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            if (categorySpending.isNotEmpty) ...[
                              ...categorySpending.entries.map((entry) {
                                final pct = (entry.value / (totalSpent > 0 ? totalSpent : 1)).clamp(0.0, 1.0);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: _categoryProgress(
                                    name: entry.key[0].toUpperCase() + entry.key.substring(1),
                                    percentage: pct,
                                    spent: '\$${entry.value.toStringAsFixed(2)}',
                                    color: _getCategoryColor(entry.key),
                                  ),
                                );
                              }),
                            ] else ...[
                              _categoryProgress(
                                name: 'Smartphones & Tech',
                                percentage: 0.50,
                                spent: 'Preferred',
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 12.h),
                              _categoryProgress(
                                name: 'Fragrances & Beauty',
                                percentage: 0.30,
                                spent: 'Preferred',
                                color: Colors.purpleAccent,
                              ),
                              SizedBox(height: 12.h),
                              _categoryProgress(
                                name: 'Fashion & Shoes',
                                percentage: 0.20,
                                spent: 'Preferred',
                                color: Colors.orangeAccent,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'smartphones':
      case 'laptops':
        return AppColors.primary;
      case 'fragrances':
      case 'beauty':
        return Colors.purpleAccent;
      case 'groceries':
        return AppColors.success;
      case 'home-decoration':
      case 'furniture':
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtle,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _chartBar({
    required String day,
    required double amount,
    required double heightFactor,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amount > 0 ? '\$${amount.toInt()}' : '',
          style: TextStyle(
            fontSize: 10.sp,
            color: isHighlighted ? AppColors.primary : AppColors.textSubtle,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 22.w,
          height: (80 * heightFactor).clamp(6.0, 80.0).h,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primary
                : (amount > 0 ? AppColors.primary.withValues(alpha: 0.5) : AppColors.surface),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: isHighlighted ? AppColors.primaryDark : AppColors.border,
              width: 1,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          day,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.textDark : AppColors.textSubtle,
          ),
        ),
      ],
    );
  }

  Widget _categoryProgress({
    required String name,
    required double percentage,
    required String spent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              spent,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 7.h,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
