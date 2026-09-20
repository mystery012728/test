import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../models/interest_category_model.dart';

class InterestChipItem extends StatelessWidget {
  final InterestCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestChipItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16.sp,
              color: isSelected ? AppColors.white : AppColors.textDark,
            ),
            SizedBox(width: 8.w),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textDark,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.check_circle_rounded,
                size: 14.sp,
                color: AppColors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
