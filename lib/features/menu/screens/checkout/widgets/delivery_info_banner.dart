import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';

class DeliveryInfoBanner extends StatelessWidget {
  final CheckoutProvider checkoutProvider;
  final CartProvider cartProvider;
  final bool isWeb;

  const DeliveryInfoBanner({
    super.key,
    required this.checkoutProvider,
    required this.cartProvider,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final canDeliver = checkoutProvider.canDeliver;
    final primaryColor = canDeliver ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(isWeb ? 20.w : 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.08),
            primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 10.w : 8.w),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(isWeb ? 10.r : 8.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  canDeliver ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: Colors.white,
                  size: isWeb ? 22.sp : 20.sp,
                ),
              ),
              SizedBox(width: isWeb ? 16.w : 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canDeliver
                          ? '${AppStrings.get('deliveryAvailable')}'
                          : '${AppStrings.get('deliveryNotAvailable')}',
                      style: TextStyle(
                        fontSize: isWeb ? 16.sp : 15.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor.shade800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      canDeliver
                          ? '${AppStrings.get('distance')}: ${checkoutProvider.getDeliveryDistanceText()}'
                          : '${AppStrings.get('addressBeyondRange')} ${CheckoutProvider.maxDeliveryDistance}${AppStrings.get('km')}${AppStrings.get('delivery')}${AppStrings.get('range')}',
                      style: TextStyle(
                        fontSize: isWeb ? 14.sp : 13.sp,
                        color: primaryColor.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canDeliver) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(isWeb ? 16.w : 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_rounded,
                            color: primaryColor.shade700,
                            size: isWeb ? 20.sp : 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            AppStrings.get('deliveryFee'),
                            style: TextStyle(
                              fontSize: isWeb ? 14.sp : 13.sp,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        checkoutProvider.getDeliveryFeeText() ??
                            AppStrings.get('calculating'),
                        style: TextStyle(
                          fontSize: isWeb ? 16.sp : 15.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor.shade800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  if (cartProvider.subtotal < 20 &&
                      checkoutProvider.deliveryDistance! <= 3) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(isWeb ? 10.r : 8.r),
                        border: Border.all(
                          color: Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.celebration_rounded,
                            color: Colors.orange.shade700,
                            size: isWeb ? 18.sp : 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${AppStrings.get('add')} €${(20 - cartProvider.subtotal).toStringAsFixed(2)} ${AppStrings.get('addMoreForFree')}}!',
                              style: TextStyle(
                                fontSize: isWeb ? 13.sp : 12.sp,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
