import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';

import 'profile_dialogs.dart';

/// App name/version footer card with delete-account and sign-out actions,
/// shown at the bottom of the mobile profile screen.
class ProfileAppInfo extends StatelessWidget {
  const ProfileAppInfo({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => ProfileDialogs.showDeleteAccountDialog(context, authProvider),
                  ),
                  SizedBox(height: 12.h),
                  CustomButton(
                    text: AppStrings.signOut,
                    isOutlined: true,
                    textColor: AppColors.error,
                    onPressed: () => ProfileDialogs.showSignOutDialog(context, authProvider),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
