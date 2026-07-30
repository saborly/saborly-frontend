import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class ResetHeader extends StatelessWidget {
  final bool passwordReset;

  const ResetHeader({super.key, required this.passwordReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: passwordReset
              ? Colors.green.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            passwordReset ? Icons.check_circle : Icons.security,
            color: passwordReset ? Colors.green : AppColors.primary,
            size: 32.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
  passwordReset ? AppStrings.get('passwordUpdated') : AppStrings.get('resetPassword'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
           passwordReset
    ? AppStrings.get('passwordChanged')
    : AppStrings.get('createStrongPassword'),
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
