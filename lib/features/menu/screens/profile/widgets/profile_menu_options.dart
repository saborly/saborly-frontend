import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import '../../../../../core/routes/app_routes.dart';
import 'profile_dialogs.dart';

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

/// The list of menu options shown on the mobile profile screen
/// (order history, change password, FAQ, about, privacy, contact, etc).
class ProfileMenuOptions extends StatelessWidget {
  const ProfileMenuOptions({super.key});

  @override
  Widget build(BuildContext context) {
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
          ProfileDialogs.showAboutDialog(context);
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
}
