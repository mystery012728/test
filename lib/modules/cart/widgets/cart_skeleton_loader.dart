import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';

// 1. Cart Items List Skeleton
class CartSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const CartSkeletonLoader({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Product Image Skeleton
              CustomSkeletonLoader(
                width: 76.w,
                height: 76.h,
                borderRadius: 12.r,
              ),
              SizedBox(width: 14.w),

              // Title, Category, Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSkeletonLoader(width: 140.w, height: 16.h),
                    SizedBox(height: 6.h),
                    CustomSkeletonLoader(width: 70.w, height: 12.h),
                    SizedBox(height: 10.h),
                    CustomSkeletonLoader(width: 60.w, height: 16.h),
                  ],
                ),
              ),

              // Stepper Skeleton
              CustomSkeletonLoader(
                width: 80.w,
                height: 32.h,
                borderRadius: 8.r,
              ),
            ],
          ),
        );
      },
    );
  }
}

// 2. Wishlist Grid Skeleton
class WishlistSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const WishlistSkeletonLoader({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 0.65,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomSkeletonLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14.r,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSkeletonLoader(width: 70.w, height: 10.h),
                    SizedBox(height: 6.h),
                    CustomSkeletonLoader(width: 120.w, height: 14.h),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomSkeletonLoader(width: 50.w, height: 14.h),
                        CustomSkeletonLoader(width: 30.w, height: 12.h),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
