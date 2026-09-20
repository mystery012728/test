import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/splash/splash_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Trigger CheckLoginEvent to check LocalPreference & session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashBloc>().add(const CheckLoginEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToHome) {
          Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
        } else if (state is SplashNavigateToLogin) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E1436),
                Color(0xFF110B22),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon with ambient glow
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 36,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 120.w,
                      height: 120.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'LAZA STORE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Personalized E-Commerce',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.75),
                    fontSize: 14.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 48.h),
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
