import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_toast_bar.dart';
import '../../home/bloc/home_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/interest_chip_item.dart';

class OnboardingView extends StatefulWidget {
  final List<String>? initialSelectedCategories;
  final bool isFromProfile;

  const OnboardingView({
    super.key,
    this.initialSelectedCategories,
    this.isFromProfile = false,
  });

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(
          LoadInterestsEvent(
            initialSelectedCategories: widget.initialSelectedCategories,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = widget.isFromProfile || Navigator.canPop(context);

    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingFailure) {
          CustomToastBar.showError(context, state.error);
        } else if (state is OnboardingLoaded && state.errorMessage != null) {
          CustomToastBar.showWarning(context, state.errorMessage!);
        } else if (state is OnboardingSuccess) {
          // Refresh ProfileBloc and HomeBloc so updated interests reflect immediately
          context
              .read<ProfileBloc>()
              .add(const LoadProfileEvent(isRefresh: true));
          context.read<HomeBloc>().add(const RefreshHomeDataEvent());

          CustomToastBar.showSuccess(
            context,
            'Preferred categories updated and synced with cloud!',
          );

          if (canGoBack) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
          }
        }
      },
      builder: (context, state) {
        final isSaving = state is OnboardingSaving;
        final loadedState = state is OnboardingLoaded ? state : null;
        final selectedCount = loadedState?.selectedSlugs.length ?? 0;
        final isValid = loadedState?.isValid ?? false;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
            leading: canGoBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () {
                        if (canGoBack) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.mainNav);
                        }
                      },
                child: Text(
                  canGoBack ? 'Cancel' : 'Skip',
                  style:
                      TextStyle(color: AppColors.textSubtle, fontSize: 14.sp),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        'Personalize Your\nShopping Feed',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Select 3 to 5 categories to customize your personalized product recommendations.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSubtle,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selectedCount >= 3 && selectedCount <= 5
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Selected: $selectedCount of 5 (Min 3 required)',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: state is OnboardingLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Wrap(
                                  spacing: 10.w,
                                  runSpacing: 12.h,
                                  children: (loadedState?.categories ?? [])
                                      .map((cat) {
                                    final isSelected = loadedState
                                            ?.selectedSlugs
                                            .contains(cat.slug) ??
                                        false;
                                    return InterestChipItem(
                                      category: cat,
                                      isSelected: isSelected,
                                      onTap: () {
                                        context.read<OnboardingBloc>().add(
                                              ToggleInterestEvent(cat.slug),
                                            );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      SizedBox(height: 16.h),
                      CustomButton(
                        text: canGoBack ? 'Save Preferences' : 'Save & Continue',
                        isLoading: isSaving,
                        onPressed: isValid && !isSaving
                            ? () {
                                context
                                    .read<OnboardingBloc>()
                                    .add(const SaveInterestsEvent());
                              }
                            : null,
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
