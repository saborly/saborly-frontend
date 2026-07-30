import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/food_item.dart';
import '../../../../../shared/widgets/custom_button.dart';

class DesktopBottomBar extends StatelessWidget {
  final bool isDesktop;
  final FoodItem foodItem;
  final int quantity;
  final MealSize? selectedMealSize;
  final bool hasActiveOffer;
  final double totalPrice;
  final VoidCallback onAddToCart;

  const DesktopBottomBar({
    super.key,
    required this.isDesktop,
    required this.foodItem,
    required this.quantity,
    required this.selectedMealSize,
    required this.hasActiveOffer,
    required this.totalPrice,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48.w : 32.w,
          vertical: 24.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 680.w),
            child: Row(
              children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    AppStrings.get('totalAmount'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
             Row(
  children: [
  if (hasActiveOffer &&
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
 if (hasActiveOffer &&
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

    // Final Price
    Text(
      '${AppStrings.currency}${totalPrice.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -0.5,
      ),
    ),
  ],
),


],
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: CustomButton(
                text: AppStrings.addToCart,
                onPressed: onAddToCart,
                height: 56.h,
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
