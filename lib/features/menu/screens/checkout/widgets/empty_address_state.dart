import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class EmptyAddressState extends StatelessWidget {
  final bool isWeb;
  final VoidCallback onAddAddress;

  const EmptyAddressState({
    super.key,
    required this.isWeb,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 48.w : 32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isWeb ? 24.w : 20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade100,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_location_alt_rounded,
              size: isWeb ? 56.sp : 48.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: isWeb ? 24.h : 20.h),
          Text(
            AppStrings.get('noDeliveryAddress'),
            style: TextStyle(
              fontSize: isWeb ? 18.sp : 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.get('addDeliveryAddress'),
            style: TextStyle(
              fontSize: isWeb ? 14.sp : 13.sp,
              color: AppColors.textLight,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWeb ? 24.h : 20.h),
          ElevatedButton.icon(
            onPressed: onAddAddress,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              AppStrings.get('addAddress'),
              style: TextStyle(
                fontSize: isWeb ? 15.sp : 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 32.w : 24.w,
                vertical: isWeb ? 16.h : 14.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
