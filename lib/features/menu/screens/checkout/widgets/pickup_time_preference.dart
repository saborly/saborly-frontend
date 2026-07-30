import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class PickupTimePreference extends StatelessWidget {
  const PickupTimePreference({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Container(
      margin: isWeb ? null : EdgeInsets.all(16.w),
      padding: EdgeInsets.all(isWeb ? 28 : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
        border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
            blurRadius: isWeb ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: isWeb ? 22 : 20.sp,
                ),
              ),
              SizedBox(width: isWeb ? 14 : 8.w),
              Text(
                AppStrings.get('pickupTime'),
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 24 : 20.h),
          _buildTimeOption(AppStrings.today, true),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String text, bool isSelected) {
    final isWeb = kIsWeb;
    return GestureDetector(
      onTap: () {
        // TODO: Select time
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 16 : 14.h,
          horizontal: isWeb ? 20 : 16.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 14 : 12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isWeb ? 2 : 1.5,
          ),
          boxShadow: isWeb && isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: isWeb ? 10 : 8.w),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: isWeb ? 20 : 18.sp,
                ),
              ),
            Text(
              text,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMedium,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
