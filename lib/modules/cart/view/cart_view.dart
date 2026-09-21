import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/common_empty_state.dart';
import '../../../core/widgets/common_error_state.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';
import '../bloc/cart/cart_bloc.dart';
import '../models/cart_item_model.dart';
import '../widgets/cart_skeleton_loader.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const LoadCartEvent());
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
          'Shopping Cart',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoading || state is CartInitial) {
                return const CartSkeletonLoader(itemCount: 4);
              }

              if (state is CartError) {
                return CommonErrorState(
                  message: state.message,
                  onRetry: () {
                    context
                        .read<CartBloc>()
                        .add(const LoadCartEvent(isRefresh: true));
                  },
                );
              }

              if (state is CartEmpty ||
                  (state is CartLoaded && state.items.isEmpty)) {
                return CommonEmptyState(
                  title: 'Your Cart is Empty',
                  subtitle:
                      'Looks like you haven\'t added anything yet. Explore our curated collections!',
                  icon: Icons.remove_shopping_cart_outlined,
                  actionLabel: 'Start Shopping',
                  onAction: () {
                    Navigator.pushNamed(context, AppRoutes.productList);
                  },
                );
              }

              if (state is CartLoaded) {
                return Column(
                  children: [
                    // Cart items list with Pull to Refresh
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          context
                              .read<CartBloc>()
                              .add(const LoadCartEvent(isRefresh: true));
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.items.length + 1,
                          itemBuilder: (context, index) {
                            if (index < state.items.length) {
                              final item = state.items[index];
                              return _buildCartItemCard(context, item);
                            }
                            // Order Summary at bottom of list
                            return _buildOrderSummary(state);
                          },
                        ),
                      ),
                    ),

                    // Sticky Bottom Checkout Bar
                    _buildCheckoutBar(context, state),
                  ],
                );
              }

              return const CartSkeletonLoader(itemCount: 4);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail Image
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: item.productId,
              );
            },
            child: Container(
              width: 76.w,
              height: 76.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: item.thumbnail,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CustomSkeletonLoader(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 12.r,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image_rounded,
                    size: 28.sp,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Title & Unit Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.brand.isNotEmpty)
                  Text(
                    item.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSubtle,
                      letterSpacing: 0.5,
                    ),
                  ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: item.productId,
                    );
                  },
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Stepper (+ / -) & Remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.close_rounded,
                    size: 18.sp, color: AppColors.textSubtle),
                onPressed: () {
                  context
                      .read<CartBloc>()
                      .add(RemoveCartItemEvent(item.productId));
                },
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<CartBloc>().add(
                              UpdateCartQuantityEvent(
                                productId: item.productId,
                                newQuantity: item.quantity - 1,
                              ),
                            );
                      },
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(8.r)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        child: Icon(Icons.remove_rounded,
                            size: 16.sp, color: AppColors.textDark),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<CartBloc>().add(
                              UpdateCartQuantityEvent(
                                productId: item.productId,
                                newQuantity: item.quantity + 1,
                              ),
                            );
                      },
                      borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(8.r)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        child: Icon(Icons.add_rounded,
                            size: 16.sp, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartLoaded state) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow(
              'Subtotal (${state.totalItemCount} items)', '\$${state.subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 6.h),
          _buildSummaryRow(
            'Shipping Fee',
            state.shippingFee == 0.0
                ? 'FREE'
                : '\$${state.shippingFee.toStringAsFixed(2)}',
            isGreen: state.shippingFee == 0.0,
          ),
          SizedBox(height: 6.h),
          _buildSummaryRow(
              'Estimated Tax (8%)', '\$${state.tax.toStringAsFixed(2)}'),
          Divider(color: AppColors.border, height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '\$${state.grandTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSubtle,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isGreen ? AppColors.success : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartLoaded state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSubtle,
                  ),
                ),
                Text(
                  '\$${state.grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.checkout);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.arrow_forward_rounded,
                        size: 16.sp, color: AppColors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Cart?'),
          content: const Text(
              'Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(const ClearCartEvent());
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}
