import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';

import '../../../../../core/routes/app_routes.dart';

/// Shown on the profile screen when the user is not authenticated.
class ProfileLoginPrompt extends StatelessWidget {
  const ProfileLoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
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
}
