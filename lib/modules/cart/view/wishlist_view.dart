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
import '../../../core/widgets/custom_toast_bar.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/wishlist/wishlist_bloc.dart';
import '../models/wishlist_item_model.dart';
import '../widgets/cart_skeleton_loader.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<WishlistBloc>().add(const LoadWishlistEvent(isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WishlistBloc>().add(const LoadMoreWishlistEvent());
    }
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
          'My Wishlist',
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
            builder: (context, cartState) {
              final count = cartState.totalItemCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  backgroundColor: AppColors.error,
                  label: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.textDark,
                    size: 24.sp,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              if (state is WishlistLoading || state is WishlistInitial) {
                return const WishlistSkeletonLoader(itemCount: 6);
              }

              if (state is WishlistError) {
                return CommonErrorState(
                  message: state.message,
                  onRetry: () {
                    context
                        .read<WishlistBloc>()
                        .add(const LoadWishlistEvent(isRefresh: true));
                  },
                );
              }

              if (state is WishlistEmpty ||
                  (state is WishlistLoaded && state.items.isEmpty)) {
                return CommonEmptyState(
                  title: 'Your Wishlist is Empty',
                  subtitle:
                      'Explore our trending products and save your favorite items here for later!',
                  icon: Icons.favorite_border_rounded,
                  actionLabel: 'Explore Products',
                  onAction: () {
                    Navigator.pushNamed(context, AppRoutes.productList);
                  },
                );
              }

              if (state is WishlistLoaded) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context
                        .read<WishlistBloc>()
                        .add(const LoadWishlistEvent(isRefresh: true));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            '${state.items.length} Item(s) in Wishlist',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14.w,
                            mainAxisSpacing: 14.h,
                            childAspectRatio: 0.54,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = state.items[index];
                              return _buildWishlistCard(context, item);
                            },
                            childCount: state.items.length,
                          ),
                        ),
                      ),
                      if (state.isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    ],
                  ),
                );
              }

              return const WishlistSkeletonLoader(itemCount: 6);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, WishlistItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: item.productId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Delete heart badge
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(14.r)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(14.r)),
                      child: CachedNetworkImage(
                        imageUrl: item.thumbnail,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CustomSkeletonLoader(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: 14.r,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image_rounded,
                          size: 32.sp,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ),
                  ),

                  // Remove from Wishlist Trash / Heart Icon
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        context.read<WishlistBloc>().add(
                              RemoveWishlistItemEvent(item.productId),
                            );
                        CustomToastBar.showInfo(
                          context,
                          '${item.title} removed from Wishlist',
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 16.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details & Move to Cart Button
            Padding(
              padding: EdgeInsets.all(10.w),
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
                  SizedBox(height: 3.h),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
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
                  SizedBox(height: 8.h),

                  // Dynamic Add to Cart or Quantity Stepper
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      final qty = cartState.productQuantities[item.productId] ?? 0;

                      if (qty > 0) {
                        return Container(
                          width: double.infinity,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (qty <= 1) {
                                    context.read<CartBloc>().add(
                                          RemoveCartItemEvent(item.productId),
                                        );
                                  } else {
                                    context.read<CartBloc>().add(
                                          UpdateCartQuantityEvent(
                                            productId: item.productId,
                                            newQuantity: qty - 1,
                                          ),
                                        );
                                  }
                                },
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  child: Icon(
                                    qty <= 1
                                        ? Icons.delete_outline_rounded
                                        : Icons.remove_rounded,
                                    size: 15.sp,
                                    color: qty <= 1
                                        ? AppColors.error
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              Text(
                                '$qty in Cart',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.read<CartBloc>().add(
                                        UpdateCartQuantityEvent(
                                          productId: item.productId,
                                          newQuantity: qty + 1,
                                        ),
                                      );
                                },
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 15.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: 32.h,
                        child: ElevatedButton(
                          onPressed: () {
                            final product = item.toProductModel();
                            context.read<CartBloc>().add(
                                  AddToCartEvent(product, quantity: 1),
                                );
                            CustomToastBar.showSuccess(
                              context,
                              '${item.title} added to Cart!',
                              actionLabel: 'View Cart',
                              onAction: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.cart,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 13.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
