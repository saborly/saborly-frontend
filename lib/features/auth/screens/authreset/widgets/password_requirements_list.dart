import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class PasswordRequirementsList extends StatelessWidget {
  const PasswordRequirementsList({super.key});

  @override
  Widget build(BuildContext context) {
    final requirements = [
      AppStrings.get('passwordMinLength8'),
      AppStrings.get('passwordUpperLower'),
      AppStrings.get('passwordNumber'),
      AppStrings.get('passwordSpecialChar'),
    ];

    return Column(
      children: requirements.map((requirement) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.check,
                color: AppColors.primary,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                requirement,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
