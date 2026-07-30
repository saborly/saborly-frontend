import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';

class RestaurantClosedBanner extends StatelessWidget {
  const RestaurantClosedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        if (checkoutProvider.isRestaurantOpen) return SizedBox.shrink();

        final isWeb = kIsWeb;

        return Container(
          margin: isWeb
              ? EdgeInsets.only(bottom: 24)
              : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          padding: EdgeInsets.all(isWeb ? 24.w : 20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade50,
                Colors.red.shade100.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
            border: Border.all(color: Colors.red.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: isWeb ? 28.sp : 24.sp,
                    ),
                  ),
                  SizedBox(width: isWeb ? 16.w : 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.restaurantClosed,
                          style: TextStyle(
                            fontSize: isWeb ? 20.sp : 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          checkoutProvider.restaurantClosedMessage ??
                              AppStrings.restaurantClosedDescription,
                          style: TextStyle(
                            fontSize: isWeb ? 14.sp : 13.sp,
                            color: Colors.red.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(isWeb ? 16.w : 14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.red.shade700,
                          size: isWeb ? 18.sp : 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Our Hours',
                          style: TextStyle(
                            fontSize: isWeb ? 15.sp : 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ..._buildHoursList(isWeb),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildHoursList(bool isWeb) {
    final days = [
      {'day': 'Monday - Thursday', 'hours': '12:00 PM - 11:00 PM'},
      {'day': 'Friday - Saturday', 'hours': '12:00 PM - 12:00 AM'},
      {'day': 'Sunday', 'hours': '12:00 PM - 11:00 PM'},
    ];

    return days.map((item) => Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item['day']!,
            style: TextStyle(
              fontSize: isWeb ? 13.sp : 12.sp,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            item['hours']!,
            style: TextStyle(
              fontSize: isWeb ? 13.sp : 12.sp,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )).toList();
  }
}
