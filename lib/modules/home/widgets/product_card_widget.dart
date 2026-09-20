import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';
import '../../cart/bloc/wishlist/wishlist_bloc.dart';
import '../../product/models/product_model.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  final bool isHorizontal;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.isHorizontal = false,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product.id,
        );
      },
      child: Container(
        width: isHorizontal ? 160.w : null,
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
            // Image with CachedNetworkImage
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                      child: CachedNetworkImage(
                        imageUrl: product.thumbnail.isNotEmpty
                            ? product.thumbnail
                            : (product.images.isNotEmpty ? product.images.first : ''),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CustomSkeletonLoader(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: 14.r,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            size: 36.sp,
                            color: AppColors.textSubtle.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Wishlist Floating Heart Button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: BlocBuilder<WishlistBloc, WishlistState>(
                      builder: (context, state) {
                        final isLiked = onFavoriteTap != null
                            ? isFavorite
                            : state.wishlistIds.contains(product.id);

                        return GestureDetector(
                          onTap: () {
                            if (onFavoriteTap != null) {
                              onFavoriteTap!();
                            } else {
                              context
                                  .read<WishlistBloc>()
                                  .add(ToggleWishlistEvent(product));
                            }
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
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16.sp,
                              color: isLiked
                                  ? AppColors.error
                                  : AppColors.textSubtle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product Information
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSubtle,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14.sp, color: AppColors.rating),
                          SizedBox(width: 2.w),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
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
