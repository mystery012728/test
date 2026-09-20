import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';

// 1. Grid skeleton loader for ProductListView & SearchView
class ProductListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ProductListSkeletonLoader({super.key, this.itemCount = 6});

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
              // Product Image Skeleton
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
                    CustomSkeletonLoader(width: 60.w, height: 10.h),
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

// 2. Full detail screen skeleton loader
class ProductDetailSkeletonLoader extends StatelessWidget {
  const ProductDetailSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Big Image Box
          CustomSkeletonLoader(
            width: double.infinity,
            height: 280.h,
            borderRadius: 20.r,
          ),
          SizedBox(height: 14.h),

          // Thumbnails
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                child: CustomSkeletonLoader(
                  width: 54.w,
                  height: 54.h,
                  borderRadius: 10.r,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Brand badge & rating skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSkeletonLoader(width: 80.w, height: 22.h),
              CustomSkeletonLoader(width: 60.w, height: 22.h),
            ],
          ),
          SizedBox(height: 12.h),

          // Title
          CustomSkeletonLoader(width: 240.w, height: 24.h),
          SizedBox(height: 8.h),
          CustomSkeletonLoader(width: 160.w, height: 20.h),
          SizedBox(height: 16.h),

          // Price row
          Row(
            children: [
              CustomSkeletonLoader(width: 90.w, height: 28.h),
              SizedBox(width: 10.w),
              CustomSkeletonLoader(width: 60.w, height: 18.h),
            ],
          ),
          SizedBox(height: 24.h),

          // Description heading & paragraphs
          CustomSkeletonLoader(width: 110.w, height: 18.h),
          SizedBox(height: 10.h),
          CustomSkeletonLoader(width: double.infinity, height: 14.h),
          SizedBox(height: 6.h),
          CustomSkeletonLoader(width: double.infinity, height: 14.h),
          SizedBox(height: 6.h),
          CustomSkeletonLoader(width: 200.w, height: 14.h),
          SizedBox(height: 24.h),

          // Specs grid skeleton
          CustomSkeletonLoader(
            width: double.infinity,
            height: 110.h,
            borderRadius: 14.r,
          ),
          SizedBox(height: 24.h),

          // Reviews header skeleton
          CustomSkeletonLoader(width: 130.w, height: 18.h),
          SizedBox(height: 12.h),
          CustomSkeletonLoader(
            width: double.infinity,
            height: 80.h,
            borderRadius: 14.r,
          ),
        ],
      ),
    );
  }
}
