import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/shared/models/order.dart';

class DeliveryTypeBanner extends StatelessWidget {
  final CheckoutProvider checkoutProvider;

  const DeliveryTypeBanner({super.key, required this.checkoutProvider});

  @override
  Widget build(BuildContext context) {
    final isPickup = checkoutProvider.deliveryType == DeliveryType.pickup;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPickup
              ? [
                  AppColors.success?.withOpacity(0.15) ?? Colors.green.withOpacity(0.15),
                  AppColors.success?.withOpacity(0.05) ?? Colors.green.withOpacity(0.05),
                ]
              : [
                  AppColors.primary?.withOpacity(0.15) ?? Colors.blue.withOpacity(0.15),
                  AppColors.primary?.withOpacity(0.05) ?? Colors.blue.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPickup
              ? AppColors.success?.withOpacity(0.3) ?? Colors.green.withOpacity(0.3)
              : AppColors.primary?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isPickup ? AppColors.success : AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isPickup ? Icons.store : Icons.delivery_dining,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPickup
                      ? AppStrings.get('pickupOrder') ?? 'Pickup Order'
                      : AppStrings.get('deliveryOrder') ?? 'Delivery Order',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isPickup
                      ? AppStrings.get('payAtShopDescription') ?? 'Pay at the shop counter'
                      : checkoutProvider.isDeliveryEnabled
                          ? AppStrings.get('choosePaymentDelivery') ?? 'Choose a payment method for delivery'
                          : AppStrings.get('deliveryDisabled') ?? 'Delivery is unavailable. Please return to checkout to select pickup.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textLight,
                  ),
                ),
                if (!checkoutProvider.isDeliveryEnabled && !isPickup) ...[
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      AppStrings.get('returnToCheckout') ?? 'Return to Checkout',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
