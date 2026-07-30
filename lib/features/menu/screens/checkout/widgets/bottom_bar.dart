import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/shared/models/order.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            final canProceed = checkoutProvider.isReadyForOrder &&
                checkoutProvider.canPlaceOrder; // ✅ NEW: Also check if restaurant is open

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ UPDATED: Show appropriate warning
                if (!checkoutProvider.isRestaurantOpen) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.red.shade700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            checkoutProvider.restaurantClosedMessage ??
                                'Restaurant is currently closed',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (checkoutProvider.deliveryType == DeliveryType.delivery &&
                    (!canProceed || !checkoutProvider.canDeliver)) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            checkoutProvider.selectedAddress == null
                                ? AppStrings.get('pleaseSelectDeliveryAddress')
                                : AppStrings.get('addressBeyondDeliveryRange'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                CustomButton(
                  text: AppStrings.placeOrder,
                  onPressed: canProceed ? () => context.push(AppRoutes.payment) : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
