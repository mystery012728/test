import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/local/local_preference.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repo/auth_repository.dart';
import '../../onboarding/view/onboarding_view.dart';
import '../../order/bloc/order_bloc.dart';
import '../../order/view/order_history_view.dart';
import '../bloc/profile_bloc.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        // actions: [
        //   BlocBuilder<ProfileBloc, ProfileState>(
        //     builder: (context, state) {
        //       final user = state.user;
        //       return IconButton(
        //         tooltip: 'Edit Profile',
        //         icon: const Icon(Icons.edit_outlined, color: AppColors.textDark),
        //         onPressed: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (_) => EditProfileView(user: user),
        //             ),
        //           );
        //         },
        //       );
        //     },
        //   ),
        //   SizedBox(width: 6.w),
        // ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading && state.user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final user = state.user ??
              UserModel(
                uid: 'user',
                email: LocalPreference.userEmail ?? 'user@laza.com',
                name: 'Valued Customer',
                favoriteCategories: LocalPreference.favoriteCategories,
              );

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context
                  .read<ProfileBloc>()
                  .add(const LoadProfileEvent(isRefresh: true));
              context.read<OrderBloc>().add(const LoadOrderHistoryEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(context, user),
                  SizedBox(height: 16.h),

                  // Personal Information Summary Card
                  _buildPersonalInfoCard(context, user),
                  SizedBox(height: 16.h),

                  // Interests & Preferred Categories
                  _buildInterestsCard(context, user),
                  SizedBox(height: 16.h),

                  // Classic & Modern Menu Section
                  _buildMenuSection(context),
                  SizedBox(height: 20.h),

                  // Logout Card
                  _buildLogoutTile(context),
                  SizedBox(height: 36.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    final initials = user.name.trim().isNotEmpty
        ? user.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Profile Avatar with tap-to-edit
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileView(user: user),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 66.r,
                  height: 66.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: user.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.profileImage,
                            width: 66.r,
                            height: 66.r,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.primaryLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 11.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),

          // Name and Email under Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Valued Customer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email.isNotEmpty ? user.email : 'user@laza.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Tap to edit arrow
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileView(user: user),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.sp,
                color: AppColors.textSubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
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
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone.isNotEmpty ? user.phone : 'Not provided',
          ),
          const Divider(color: AppColors.divider, height: 18),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date of Birth',
            value:
                user.dateOfBirth.isNotEmpty ? user.dateOfBirth : 'Not provided',
          ),
          const Divider(color: AppColors.divider, height: 18),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Gender',
            value: user.gender.isNotEmpty ? user.gender : 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.textSubtle),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSubtle,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsCard(BuildContext context, UserModel user) {
    final categories = user.favoriteCategories.isNotEmpty
        ? user.favoriteCategories
        : LocalPreference.favoriteCategories;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
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
              Text(
                'Preferred Categories',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnboardingView(
                        initialSelectedCategories: categories,
                        isFromProfile: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (categories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No categories selected yet. Tap Update to select your favorites!',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSubtle,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: categories.map((cat) {
                  final display = cat
                      .replaceAll('-', ' ')
                      .split(' ')
                      .map((w) => w.isNotEmpty
                          ? '${w[0].toUpperCase()}${w.substring(1)}'
                          : '')
                      .join(' ');
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          display,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Order History
          _menuTile(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            subtitle: 'View your purchase history',
            badge: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final count =
                    state is OrderHistoryLoaded ? state.orders.length : 0;
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryView()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20.sp),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          ?badge,
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.sp,
          color: AppColors.textSubtle,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.sp,
        color: AppColors.textSubtle,
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.logout_rounded, color: AppColors.error, size: 20.sp),
      ),
      title: Text(
        'Log Out',
        style: TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
      subtitle: Text(
        'Safely exit your session',
        style: TextStyle(
          color: AppColors.textSubtle,
          fontSize: 11.sp,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.sp,
        color: AppColors.error,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Log Out',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to log out from your Laza account?',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSubtle),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await LocalPreference.clear();
                  await AuthRepository().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
        );
      },
    ),
  );
}
}
