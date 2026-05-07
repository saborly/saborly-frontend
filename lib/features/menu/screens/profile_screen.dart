import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/shared/widgets/ooter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? _lastPressedAt;
    return PopScope(
      canPop: kIsWeb,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || kIsWeb) return;

        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.get('pressBackAgain'),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.textDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: kIsWeb ? null : _buildAppBar(),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isAuthenticated) {
              return _buildLoginPrompt(context);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 768;

                if (isWeb) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildWebLayout(context, authProvider, constraints),
                      ),
                      SliverToBoxAdapter(
                        child: FoodKingFooter(), // Full-width footer
                      ),
                    ],
                  );
                } else {
                  return _buildMobileLayout(context, authProvider);
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Web layout
  Widget _buildWebLayout(BuildContext context, AuthProvider authProvider, BoxConstraints constraints) {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('accountManagement'),
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            AppStrings.get('manageYourAccount'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 350,
                      child: Column(
                        children: [
                          _buildProfileCard(context, authProvider),
                          SizedBox(height: 24.h),
                          // _buildStatsCard(authProvider),
                          SizedBox(height: 24.h),
                          _buildQuickLinksCard(context),
                        ],
                      ),
                    ),
                    SizedBox(width: 32.w),
                    Expanded(
                      child: Column(
                        children: [
                          _buildAccountSettingsCard(context),
                          SizedBox(height: 24.h),
                          _buildPreferencesCard(context),
                          SizedBox(height: 24.h),
                          _buildSecurityCard(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinksCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('quickActions'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          _buildQuickLink(AppStrings.get('orderHistory'), Icons.history, () {
            context.push(AppRoutes.orders);
          }),
          _buildQuickLink(AppStrings.get('faq'), Icons.help_outline, () {
            context.go(AppRoutes.faq); // Link to FAQ
          }),
          _buildQuickLink(AppStrings.get('privacy'), Icons.privacy_tip_outlined, () {
            context.go(AppRoutes.privacy); // Link to Privacy
          }),
          // _buildQuickLink(AppStrings.get('downloadData'), Icons.download, () {}),
          Divider(height: 24.h, color: Colors.grey[200]),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                children: [
                  _buildQuickLink(
                    AppStrings.get('deleteAccount'),
                    Icons.delete_outline,
                    () => _showDeleteAccountDialog(context, authProvider),
                    isDestructive: true,
                  ),
                  _buildQuickLink(
                    AppStrings.get('signOut'),
                    Icons.logout,
                    () => _showSignOutDialog(context, authProvider),
                    isDestructive: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('preferences'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 20.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 3.5,
            children: [
              _buildSettingCard(AppStrings.get('notifications'), Icons.notifications_outlined, () {
                  context.go(AppRoutes.notifications); 
              }),
              _buildSettingCard(AppStrings.get('privacy'), Icons.privacy_tip_outlined, () {
                context.go(AppRoutes.privacy); // Already linked to Privacy
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('securityAndSupport'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 20.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 3.5,
            children: [
              _buildSettingCard(AppStrings.get('changePassword'), Icons.lock_outline, () {
                context.push('/change-password');
              }),
              _buildSettingCard(AppStrings.get('faq'), Icons.help_outline, () {
                context.go(AppRoutes.faq); // Link to FAQ
              }),
              _buildSettingCard(AppStrings.get('about'), Icons.info_outline, () {
                context.go(AppRoutes.about);
              }),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return _buildSettingCard(
                    AppStrings.deleteAccount,
                    Icons.delete_outline,
                    () => _showDeleteAccountDialog(context, authProvider),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    final menuItems = [
      ProfileMenuItem(
        icon: Icons.receipt_long,
        title: AppStrings.get('orderHistory'),
        subtitle: AppStrings.get('viewPastOrders'),
        onTap: () {
          context.go(AppRoutes.orders);
        },
      ),
      ProfileMenuItem(
        icon: Icons.lock,
        title: AppStrings.get('changePassword'),
        subtitle: AppStrings.get('updatePassword'),
        onTap: () {
          context.go('/change-password');
        },
      ),
      ProfileMenuItem(
        icon: Icons.help_outline,
        title: AppStrings.get('faq'),
        subtitle: AppStrings.get('frequentlyAskedQuestions'),
        onTap: () {
          context.go(AppRoutes.faq); // Link to FAQ
        },
      ),
   ProfileMenuItem(
        icon: Icons.info,
        title: AppStrings.get('about'),
        subtitle: AppStrings.get('learnAboutUs'),
        onTap: () {
          _showAboutDialog(context);
        },
      ),
      ProfileMenuItem(
        icon: Icons.privacy_tip_outlined,
        title: AppStrings.get('privacy'),
        subtitle: AppStrings.get('privacyPolicy'),
        onTap: () {
          context.go(AppRoutes.privacy); // Link to Privacy
        },
      ),
      ProfileMenuItem(
        icon: Icons.info,
        title: AppStrings.get('contactUs'),
        subtitle: AppStrings.get('contactUs'),
        onTap: () {
          context.go(AppRoutes.contact); // Link to Privacy
        },
      ),
      ProfileMenuItem(
        icon: Icons.store_mall_directory_outlined,
        title: 'Change Branch',
        subtitle: 'Switch to a different branch',
        onTap: () {
          context.go(AppRoutes.branchSelect);
        },
      ),
      ProfileMenuItem(
        icon: Icons.notifications,
        title: AppStrings.get('notifications'),
        subtitle: AppStrings.get('notificationPreferences'),
        onTap: () {
                            context.go(AppRoutes.notifications); 

        },
      ),
    ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              _buildMenuItem(item),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.divider,
                  indent: 56.w,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Other methods remain unchanged (omitted for brevity)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        AppStrings.profile,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            user.fullName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            user.phone,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showEditProfileDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.get('editProfile'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('activityOverview'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(AppStrings.get('orders'), '12', Icons.receipt_long),
              ),
              Expanded(
                child: _buildStatItem(AppStrings.get('reviews'), '8', Icons.star),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(AppStrings.get('favorites'), '24', Icons.favorite),
              ),
              Expanded(
                child: _buildStatItem(AppStrings.get('points'), '150', Icons.loyalty),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLink(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isDestructive ? AppColors.error : AppColors.textMedium,
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 12.sp,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('accountSettings'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 20.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 3.5,
            children: [
              _buildSettingCard(AppStrings.get('personalInformation'), Icons.person_outline, () {
                _showEditProfileDialog(context);
              }),
              _buildSettingCard(AppStrings.get('orderHistory'), Icons.receipt_long_outlined, () {
                context.push('/orders');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          _buildProfileHeader(context, authProvider),
          SizedBox(height: 24.h),
          _buildMenuOptions(context),
          SizedBox(height: 24.h),
          _buildAppInfo(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80.sp,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.loginToContinue,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.get('signInPrompt'),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: AppStrings.signIn,
            onPressed: () => context.push(AppRoutes.login),
            width: 200.w,
          ),
          SizedBox(height: 12.h),
          CustomButton(
            text: AppStrings.signUp,
            isOutlined: true,
            onPressed: () => context.push(AppRoutes.signup),
            width: 200.w,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showEditProfileDialog(context);
            },
            icon: Icon(
              Icons.edit,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(ProfileMenuItem item) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          item.icon,
          color: AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textLight,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textLight,
        size: 16.sp,
      ),
      onTap: item.onTap,
    );
  }

  Widget _buildAppInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.get('appVersion'),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 16.h),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                children: [
                  CustomButton(
                    text: AppStrings.deleteAccount,
                    isOutlined: true,
                    textColor: AppColors.error,
                    onPressed: () => _showDeleteAccountDialog(context, authProvider),
                  ),
                  SizedBox(height: 12.h),
                  CustomButton(
                    text: AppStrings.signOut,
                    isOutlined: true,
                    textColor: AppColors.error,
                    onPressed: () => _showSignOutDialog(context, authProvider),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                AppStrings.get('aboutApp').replaceAll('{appName}', AppStrings.get('appName')),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('appVersion'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppStrings.get('appDescription').replaceAll('{appName}', AppStrings.get('appName')),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textMedium,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppStrings.get('copyright').replaceAll('{appName}', AppStrings.get('appName')),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppStrings.get('companyAddress'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.get('close'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            AppStrings.get('editProfile'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.firstName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.lastName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: AppStrings.phoneNumber,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                ),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final success = await provider.updateProfile(
                            firstNameController.text.trim(),
                            lastNameController.text.trim(),
                            phoneController.text.trim(),
                          );

                          if (success) {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppStrings.profileUpdatedSuccessfully),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  margin: EdgeInsets.all(16.w),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppStrings.failedToUpdateProfile),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  margin: EdgeInsets.all(16.w),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppStrings.get('save'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            AppStrings.signOut,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            AppStrings.get('areYouSureSignOut'),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.home);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 24.w,
                ),
              ),
              child: Text(
                AppStrings.signOut,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.deleteAccount,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppStrings.areYouSureDeleteAccount,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                ),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final success = await provider.deleteAccount();
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            if (success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppStrings.accountDeletedSuccessfully),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    margin: EdgeInsets.all(16.w),
                                  ),
                                );
                                context.go(AppRoutes.home);
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppStrings.failedToDeleteAccount),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    margin: EdgeInsets.all(16.w),
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 24.w,
                    ),
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppStrings.deleteAccount,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}