import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class OrderHistoryLoadingState extends StatelessWidget {
  const OrderHistoryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            AppStrings.get('loadingYourOrders'),
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please wait a moment...',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
