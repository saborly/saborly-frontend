import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class SignupFormHeader extends StatelessWidget {
  final bool isLargeScreen;

  const SignupFormHeader({super.key, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
  AppStrings.get('createAccount'),
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
  AppStrings.get('fillInDetails'),
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
