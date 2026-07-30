import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/food_item.dart';
import '../../../../../shared/widgets/custom_button.dart';

class MobileBottomBar extends StatelessWidget {
  final FoodItem foodItem;
  final int quantity;
  final MealSize? selectedMealSize;
  final double totalPrice;
  final VoidCallback onAddToCart;

  const MobileBottomBar({
    super.key,
    required this.foodItem,
    required this.quantity,
    required this.selectedMealSize,
    required this.totalPrice,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [

                         if (foodItem.hasActiveOffer &&
        (selectedMealSize == null || (selectedMealSize?.additionalPrice ?? 0) <= 0))
      ...[
        Text(
          '${AppStrings.currency}${(quantity * foodItem.price).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textLight,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        SizedBox(width: 8.w),
      ],

    // Case 2: Offer active AND selected size has extra cost > 0
    if (foodItem.hasActiveOffer &&
        selectedMealSize != null &&
        selectedMealSize!.additionalPrice > 0)
      ...[
        Text(
          '${AppStrings.currency}${(quantity * selectedMealSize!.additionalPrice).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textLight,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        SizedBox(width: 8.w),
      ],
                        Text(
                          '${AppStrings.currency}${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: AppStrings.addToCart,
              onPressed: onAddToCart,
              height: 54.h,
            ),
          ],
        ),
      ),
    );
  }
}
