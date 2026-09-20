import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';

class OrderListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const OrderListSkeletonLoader({super.key, this.itemCount = 4});

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
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomSkeletonLoader(width: 120.w, height: 16.h),
                  CustomSkeletonLoader(
                    width: 70.w,
                    height: 22.h,
                    borderRadius: 6.r,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomSkeletonLoader(width: 90.w, height: 12.h),
              SizedBox(height: 14.h),
              Row(
                children: List.generate(
                  3,
                  (idx) => Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: CustomSkeletonLoader(
                      width: 50.w,
                      height: 50.h,
                      borderRadius: 10.r,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              const Divider(color: AppColors.border),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomSkeletonLoader(width: 80.w, height: 14.h),
                  CustomSkeletonLoader(width: 70.w, height: 16.h),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
