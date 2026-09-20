import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/common_error_state.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';
import '../../../core/widgets/custom_toast_bar.dart';
import '../../cart/bloc/cart/cart_bloc.dart';
import '../../cart/bloc/wishlist/wishlist_bloc.dart';
import '../bloc/product_detail/product_detail_bloc.dart';
import '../models/product_model.dart';
import '../widgets/product_skeleton_loader.dart';

class ProductDetailView extends StatefulWidget {
  final int productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _selectedImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<ProductDetailBloc>().add(FetchProductDetailEvent(widget.productId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, wishState) {
              final isLiked = wishState.wishlistIds.contains(widget.productId);
              return IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? AppColors.error : AppColors.textDark,
                  size: 24.sp,
                ),
                onPressed: () {
                  final prodState = context.read<ProductDetailBloc>().state;
                  if (prodState is ProductDetailLoaded) {
                    context.read<WishlistBloc>().add(ToggleWishlistEvent(prodState.product));
                  }
                },
              );
            },
          ),
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
          child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
            builder: (context, state) {
              if (state is ProductDetailLoading) {
                return const ProductDetailSkeletonLoader();
              }

              if (state is ProductDetailError) {
                return CommonErrorState(
                  message: state.message,
                  onRetry: () {
                    context.read<ProductDetailBloc>().add(
                          FetchProductDetailEvent(widget.productId),
                        );
                  },
                );
              }

              if (state is ProductDetailLoaded) {
                final product = state.product;
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Image Carousel & Thumbnails
                            _buildImageGallery(product),
                            SizedBox(height: 20.h),

                            // 2. Brand, SKU & Availability Badges
                            _buildBadgesRow(product),
                            SizedBox(height: 12.h),

                            // 3. Product Title
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // 4. Rating & Reviews Count
                            _buildRatingSection(product),
                            SizedBox(height: 16.h),

                            // 5. Price & Discount Display
                            _buildPriceSection(product),
                            SizedBox(height: 20.h),

                            const Divider(color: AppColors.border),
                            SizedBox(height: 12.h),

                            // 6. Description
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSubtle,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // 7. Specifications & Dimensions Grid
                            _buildSpecificationsSection(product),
                            SizedBox(height: 20.h),

                            // 8. Shipping, Warranty & Return Policy
                            _buildPolicySection(product),
                            SizedBox(height: 20.h),

                            // 9. Customer Reviews
                            _buildCustomerReviews(product),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),

                    // 10. Sticky Bottom Bar (Add to Cart CTA)
                    _buildBottomActionBar(product),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // --- 1. Gallery Section ---
  Widget _buildImageGallery(ProductModel product) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];

    return Column(
      children: [
        Container(
          height: 260.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (idx) {
                setState(() => _selectedImageIndex = idx);
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CustomSkeletonLoader(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 20.r,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image_rounded,
                    size: 60.sp,
                    color: AppColors.textSubtle,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Thumbnails row
        if (images.length > 1)
          SizedBox(
            height: 56.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: images.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedImageIndex == idx;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedImageIndex = idx);
                    _pageController.animateToPage(
                      idx,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: images[idx],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CustomSkeletonLoader(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 8.r,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // --- 2. Badges Row ---
  Widget _buildBadgesRow(ProductModel product) {
    return Row(
      children: [
        if (product.brand.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              product.brand,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: product.stock > 0
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            product.stock > 0 ? '${product.availabilityStatus} (${product.stock})' : 'Out of Stock',
            style: TextStyle(
              color: product.stock > 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ),
        const Spacer(),
        if (product.sku.isNotEmpty)
          Text(
            'SKU: ${product.sku}',
            style: TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  // --- 3. Rating Section ---
  Widget _buildRatingSection(ProductModel product) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.white, size: 14.sp),
              SizedBox(width: 3.w),
              Text(
                product.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          '(${product.reviews.length} customer reviews)',
          style: TextStyle(
            color: AppColors.textSubtle,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- 4. Price Section ---
  Widget _buildPriceSection(ProductModel product) {
    final hasDiscount = product.discountPercentage > 0;
    final originalPrice = hasDiscount
        ? (product.price / (1 - (product.discountPercentage / 100)))
        : product.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (hasDiscount) ...[
          SizedBox(width: 10.w),
          Text(
            '\$${originalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSubtle,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSubtle,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- 5. Specifications Grid ---
  Widget _buildSpecificationsSection(ProductModel product) {
    final d = product.dimensions;
    final hasDims = d.width > 0 || d.height > 0 || d.depth > 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details & Specifications',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSpecRow('Category', product.category),
          if (product.brand.isNotEmpty) _buildSpecRow('Brand', product.brand),
          if (product.sku.isNotEmpty) _buildSpecRow('SKU', product.sku),
          if (hasDims)
            _buildSpecRow(
              'Dimensions',
              '${d.width} x ${d.height} x ${d.depth} cm',
            ),
          _buildSpecRow('Min Order Qty', '${product.minimumOrderQuantity} item(s)'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
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
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Policy Section ---
  Widget _buildPolicySection(ProductModel product) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (product.shippingInformation.isNotEmpty)
            _buildPolicyTile(
              Icons.local_shipping_outlined,
              'Shipping Information',
              product.shippingInformation,
            ),
          if (product.warrantyInformation.isNotEmpty) ...[
            Divider(color: AppColors.border, height: 16.h),
            _buildPolicyTile(
              Icons.verified_user_outlined,
              'Warranty Policy',
              product.warrantyInformation,
            ),
          ],
          if (product.returnPolicy.isNotEmpty) ...[
            Divider(color: AppColors.border, height: 16.h),
            _buildPolicyTile(
              Icons.assignment_return_outlined,
              'Return Policy',
              product.returnPolicy,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPolicyTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 7. Customer Reviews Section ---
  Widget _buildCustomerReviews(ProductModel product) {
    if (product.reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews (${product.reviews.length})',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star_rounded, color: const Color(0xFFFF9800), size: 16.sp),
                SizedBox(width: 2.w),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...product.reviews.map((rev) => _buildReviewCard(rev)),
      ],
    );
  }

  Widget _buildReviewCard(ProductReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerName,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (idx) => Icon(
                    idx < review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFFF9800),
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. Bottom Action Bar ---
  Widget _buildBottomActionBar(ProductModel product) {
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
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            final inCartCount = cartState.getQuantity(product.id);

            return Row(
              children: [
                // Total Price Summary
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      inCartCount > 0
                          ? 'Total ($inCartCount in cart)'
                          : 'Unit Price',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSubtle,
                      ),
                    ),
                    Text(
                      '\$${((inCartCount > 0 ? inCartCount : 1) * product.price).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),

                // Cart Action: Stepper if already in cart, else "Add to Cart"
                Expanded(
                  child: inCartCount > 0
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  inCartCount == 1
                                      ? Icons.delete_outline_rounded
                                      : Icons.remove_rounded,
                                  color: inCartCount == 1
                                      ? AppColors.error
                                      : AppColors.textDark,
                                  size: 20.sp,
                                ),
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        UpdateCartQuantityEvent(
                                          productId: product.id,
                                          newQuantity: inCartCount - 1,
                                        ),
                                      );
                                },
                              ),
                              Text(
                                '$inCartCount in Cart',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_rounded,
                                    color: AppColors.primary, size: 20.sp),
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        AddToCartEvent(product, quantity: 1),
                                      );
                                },
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            context.read<CartBloc>().add(
                                  AddToCartEvent(product, quantity: 1),
                                );
                            CustomToastBar.showSuccess(
                              context,
                              '${product.title} added to cart!',
                              actionLabel: 'View Cart',
                              onAction: () {
                                Navigator.pushNamed(context, AppRoutes.cart);
                              },
                            );
                          },
                          icon: Icon(Icons.shopping_bag_outlined,
                              size: 18.sp, color: AppColors.white),
                          label: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
