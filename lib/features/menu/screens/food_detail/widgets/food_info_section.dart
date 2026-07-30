import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/food_item.dart';

class FoodInfoSection extends StatelessWidget {
  final FoodItem foodItem;
  final bool isLargeScreen;
  final bool hasActiveOffer;
  final double effectivePrice;

  const FoodInfoSection({
    super.key,
    required this.foodItem,
    required this.isLargeScreen,
    required this.hasActiveOffer,
    required this.effectivePrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 0 : 20.w,
        vertical: isLargeScreen ? 0 : 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: foodItem.isVeg
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  foodItem.isVeg
                      ? Icons.eco_rounded
                      : Icons.restaurant_rounded,
                  color: foodItem.isVeg
                      ? Colors.green[700]
                      : Colors.red[700],
                  size: isLargeScreen ? 18.sp : 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 36.sp : 28.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (foodItem.rating > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber[700],
                              size: isLargeScreen ? 18.sp : 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${foodItem.rating}',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 15.sp : 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${foodItem.reviewCount})',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 14.sp : 12.sp,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20.h : 16.h),
          Text(
            foodItem.description,
            style: TextStyle(
              fontSize: isLargeScreen ? 17.sp : 15.sp,
              color: AppColors.textMedium,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: isLargeScreen ? 24.h : 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.get('total'),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 15.sp : 13.sp,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasActiveOffer) ...[
                      Text(
                        '${AppStrings.get('currency')}${foodItem.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18.sp : 16.sp,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    Text(
                      '${AppStrings.get('currency')}${effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 28.sp : 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
