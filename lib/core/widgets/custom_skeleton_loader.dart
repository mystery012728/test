import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

// Generic Base Shimmer Skeleton Loader
class CustomSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;
  final ShapeBorder? shapeBorder;

  const CustomSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shapeBorder,
  });

  const CustomSkeletonLoader.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEBEBF4),
      highlightColor: const Color(0xFFF7F7FD),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: const Color(0xFFEBEBF4),
          shape: shapeBorder ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
              ),
        ),
      ),
    );
  }
}
