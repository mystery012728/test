import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/common_error_state.dart';
import '../../../core/widgets/custom_skeleton_loader.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/promo_banner_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20.w,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (prev, curr) => curr is HomeLoaded,
          builder: (context, state) {
            final userName = state is HomeLoaded ? state.userName : 'Shopper';
            return Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: AppColors.textDark, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName 👋',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Welcome to Laza Store',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_rounded, color: AppColors.textDark, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Tablet-responsive container
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeDataEvent());
                // Wait briefly for smooth pull animation
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bloc Consumer / Builder for Data Sections
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeLoading || state is HomeInitial) {
                          return _buildSkeletonState();
                        } else if (state is HomeError) {
                          return _buildErrorState(context, state.message);
                        } else if (state is HomeLoaded) {
                          return _buildLoadedState(context, state);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 1. Shimmer Loading State using custom_skeleton_loader
  Widget _buildSkeletonState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BannerSkeletonLoader(),
        SizedBox(height: 26.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSkeletonLoader(width: 160.w, height: 18.h, borderRadius: 6.r),
            CustomSkeletonLoader(width: 80.w, height: 14.h, borderRadius: 4.r),
          ],
        ),
        SizedBox(height: 14.h),
        const HorizontalProductListSkeletonLoader(itemCount: 3),
        SizedBox(height: 26.h),
        CustomSkeletonLoader(width: 140.w, height: 18.h, borderRadius: 6.r),
        SizedBox(height: 14.h),
        const ProductGridSkeletonLoader(itemCount: 4),
      ],
    );
  }

  // 2. Real Loaded Data State from DummyJSON API
  Widget _buildLoadedState(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promo Banner
        const PromoBannerWidget(),
        SizedBox(height: 26.h),

        // Section: Personalized "Recommended for you" based on user's interests
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended for You 🔥',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Personalized Horizontal Scrollable List with CachedNetworkImage
        if (state.personalizedProducts.isNotEmpty)
          SizedBox(
            height: 220.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: state.personalizedProducts.length,
              separatorBuilder: (context, index) => SizedBox(width: 14.w),
              itemBuilder: (context, index) {
                final product = state.personalizedProducts[index];
                return ProductCardWidget(
                  product: product,
                  isHorizontal: true,
                );
              },
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Select favorite categories in Onboarding to get personalized picks.',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 13.sp),
              ),
            ),
          ),
        SizedBox(height: 26.h),

        // Section: Popular Products Grid (Real API Data)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Products',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.productList);
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // 2-Column Grid with CachedNetworkImage
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.popularProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
          ),
          itemBuilder: (context, index) {
            final product = state.popularProducts[index];
            return ProductCardWidget(product: product);
          },
        ),
      ],
    );
  }

  // 3. Error State with Retry CTA
  Widget _buildErrorState(BuildContext context, String message) {
    return CommonErrorState(
      message: message,
      onRetry: () {
        context.read<HomeBloc>().add(const LoadHomeDataEvent());
      },
    );
  }
}
