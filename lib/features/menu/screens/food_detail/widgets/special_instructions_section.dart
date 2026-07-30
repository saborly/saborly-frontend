import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class SpecialInstructionsSection extends StatelessWidget {
  final bool isLargeScreen;
  final TextEditingController controller;

  const SpecialInstructionsSection({
    super.key,
    required this.isLargeScreen,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.specialInstructions,
            style: TextStyle(
              fontSize: isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              style: TextStyle(
                fontSize: isLargeScreen ? 16.sp : 14.sp,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText:    AppStrings.get('specialInstructions'),
                hintStyle: TextStyle(
                  fontSize: isLargeScreen ? 16.sp : 14.sp,
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
