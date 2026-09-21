import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

/// Reusable iOS-styled back button for consistent navigation across the app.
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color ?? AppColors.textDark,
        size: size ?? 20.sp,
      ),
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      splashRadius: 22.r,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
