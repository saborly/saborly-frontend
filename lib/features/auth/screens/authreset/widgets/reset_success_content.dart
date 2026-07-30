import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class ResetSuccessContent extends StatelessWidget {
  const ResetSuccessContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
  AppStrings.get('passwordResetSuccess'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
  AppStrings.get('passwordResetSuccessDescription'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Security tip
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
  AppStrings.get('passwordSecurityTip'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
