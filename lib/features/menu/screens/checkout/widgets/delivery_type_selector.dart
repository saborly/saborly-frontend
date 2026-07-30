import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/shared/models/order.dart';



class DeliveryTypeSelector extends StatelessWidget {
  const DeliveryTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Consumer2<CheckoutProvider, CartProvider>(
      builder: (context, checkoutProvider, cartProvider, child) {
        final isDelivery = checkoutProvider.deliveryType == DeliveryType.delivery;
        final isDeliveryDisabled = !checkoutProvider.isDeliveryEnabled;

        return Container(
          margin: isWeb ? null : EdgeInsets.all(16.w),
          padding: isWeb ? const EdgeInsets.all(6) : EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 16 : 14.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: isWeb ? 16 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      AppStrings.get('pickup') ?? 'Pickup',
                      Icons.shopping_bag,
                      !isDelivery,
                      isWeb,
                      () {
                        checkoutProvider.setDeliveryType(DeliveryType.pickup);
                      },
                      isDisabled: false,
                    ),
                  ),
                  SizedBox(width: isWeb ? 8 : 4.w),
                  Expanded(
                    child: Tooltip(
                      message: isDeliveryDisabled
                          ? checkoutProvider.deliveryDisabledMessage ??
                              AppStrings.get('deliveryNotAvailableNow') ??
                              'Delivery is temporarily unavailable'
                          : '',
                      child: _buildTypeButton(
                        AppStrings.get('delivery') ?? 'Delivery',
                        Icons.delivery_dining,
                        isDelivery,
                        isWeb,
                        // ✅ CRITICAL: Pass null when disabled to make it unclickable
                        isDeliveryDisabled
                            ? null
                            : () {
                                checkoutProvider.setDeliveryType(DeliveryType.delivery);
                                checkoutProvider.updateDeliveryFee(cartProvider.subtotal);
                              },
                        isDisabled: isDeliveryDisabled,
                      ),
                    ),
                  ),
                ],
              ),
              // ✅ Show warning banner when delivery is disabled
              if (isDeliveryDisabled) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          checkoutProvider.deliveryDisabledMessage ??
                              AppStrings.get('deliveryNotAvailableNow') ??
                              'Delivery service is temporarily unavailable. Only pickup orders are accepted.',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(
    String text,
    IconData icon,
    bool isSelected,
    bool isWeb,
    VoidCallback? onTap, {
    bool isDisabled = false,
  }) {
    final color = isDisabled ? Colors.grey.shade400 : AppColors.primary;

    return Semantics(
      label: isDisabled
          ? '$text (${AppStrings.get('deliveryDisabled') ?? 'Delivery is temporarily unavailable'})'
          : text,
      enabled: !isDisabled,
      button: true,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          // ✅ CRITICAL: onTap is null when disabled, making it unclickable
          onTap: isDisabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              vertical: isWeb ? 18 : 14.h,
              horizontal: isWeb ? 16 : 12.w,
            ),
            decoration: BoxDecoration(
              gradient: isSelected && !isDisabled
                  ? LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected && !isDisabled
                  ? null
                  : (isDisabled ? Colors.grey.shade100 : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(isWeb ? 12 : 10.r),
              border: isDisabled
                  ? Border.all(color: Colors.grey.shade300, width: 1.5)
                  : null,
              boxShadow: isSelected && !isDisabled
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected && !isDisabled ? Colors.white : color,
                  size: isWeb ? 22 : 20.sp,
                ),
                SizedBox(width: isWeb ? 10 : 8.w),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected && !isDisabled ? Colors.white : color,
                    letterSpacing: 0.3,
                  ),
                ),
                if (isDisabled) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.lock_outline,
                    size: 16.sp,
                    color: Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
