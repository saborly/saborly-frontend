import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class SignupFeatureList extends StatelessWidget {
  const SignupFeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      AppStrings.get('secureCheckout'),
      AppStrings.get('personalizedRecommendations'),
      AppStrings.get('exclusiveBenefits'),
      AppStrings.get('customerSupport'),
    ];

    return Column(
      children: features.map((feature) => Padding(
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
                feature,
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
