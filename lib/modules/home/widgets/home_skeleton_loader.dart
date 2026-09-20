import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';

// 1. Promotional Banner Skeleton
class BannerSkeletonLoader extends StatelessWidget {
  const BannerSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E2F8),
      highlightColor: const Color(0xFFF2F0FC),
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E2F8),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

// 2. Single Product Card Skeleton
class ProductCardSkeleton extends StatelessWidget {
  final bool isHorizontal;

  const ProductCardSkeleton({
    super.key,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isHorizontal ? 160.w : null,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder box
          Expanded(
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFECEEF5),
              highlightColor: const Color(0xFFF7F8FC),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEF5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSkeletonLoader(width: 50.w, height: 10.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                CustomSkeletonLoader(width: 110.w, height: 12.h, borderRadius: 4.r),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSkeletonLoader(width: 45.w, height: 14.h, borderRadius: 4.r),
                    CustomSkeletonLoader(width: 30.w, height: 12.h, borderRadius: 4.r),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Recommended / Personalized Horizontal Skeleton List
class HorizontalProductListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const HorizontalProductListSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(width: 14.w),
        itemBuilder: (context, index) => const ProductCardSkeleton(isHorizontal: true),
      ),
    );
  }
}

// 4. Popular Products Grid Skeleton
class ProductGridSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeletonLoader({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
      ),
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}
