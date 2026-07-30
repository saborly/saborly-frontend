import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
  AppStrings.get('createAccount'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
  AppStrings.get('signUpToStart').replaceAll('{appName}', AppStrings.appName),
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
