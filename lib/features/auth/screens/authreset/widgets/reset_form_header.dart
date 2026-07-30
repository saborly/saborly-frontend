import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class ResetFormHeader extends StatelessWidget {
  final bool passwordReset;
  final bool isLargeScreen;

  const ResetFormHeader({
    super.key,
    required this.passwordReset,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: passwordReset
              ? Colors.green.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            passwordReset ? Icons.check_circle : Icons.security,
            color: passwordReset ? Colors.green : AppColors.primary,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
  passwordReset ? AppStrings.get('passwordUpdated') : AppStrings.get('resetPassword'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isLargeScreen ? 32.sp : 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
         passwordReset
    ? AppStrings.get('passwordChanged')
    : AppStrings.get('createStrongPassword'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
