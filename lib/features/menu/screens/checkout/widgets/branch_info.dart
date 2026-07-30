import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';

class BranchInfo extends StatelessWidget {
  const BranchInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Consumer<CheckoutProvider>(
      builder: (context, provider, child) {
        final branch = provider.selectedBranch;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('pickupLocation'),
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isWeb ? 14 : 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(isWeb ? 14 : 12.r),
                    ),
                    child: Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: isWeb ? 26 : 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 24 : 20.h),
              if (branch != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: isWeb ? 22 : 20.sp,
                      ),
                    ),
                    SizedBox(width: isWeb ? 14 : 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: TextStyle(
                              fontSize: isWeb ? 17 : 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: isWeb ? 8 : 6.h),
                          Text(
                            branch.address,
                            style: TextStyle(
                              fontSize: isWeb ? 15 : 14.sp,
                              color: AppColors.textMedium,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isWeb ? 20 : 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Icon(
                        Icons.phone,
                        color: AppColors.textLight,
                        size: isWeb ? 20 : 18.sp,
                      ),
                    ),
                    SizedBox(width: isWeb ? 14 : 12.w),
                    Text(
                      branch.phone,
                      style: TextStyle(
                        fontSize: isWeb ? 15 : 14.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
