import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/shared/models/order.dart';

class DeliveryToggle extends StatelessWidget {
  final bool isWeb;

  const DeliveryToggle(this.isWeb, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        final isDelivery = checkoutProvider.deliveryType == DeliveryType.delivery;
        final isDeliveryDisabled = !checkoutProvider.isDeliveryEnabled;

        return Container(
          padding: isWeb
              ? const EdgeInsets.all(6)
              : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: isWeb
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      AppStrings.get('takeaway') ?? 'Takeaway',
                      !isDelivery,
                      isWeb,
                      onTap: () {
                        checkoutProvider.setDeliveryType(DeliveryType.pickup);
                      },
                    ),
                  ),
                  SizedBox(width: isWeb ? 8 : 12.w),
                  Expanded(
                    child: Tooltip(
                      message: isDeliveryDisabled
                          ? AppStrings.get('deliveryNotAvailableNow') ??
                              'Delivery is temporarily unavailable'
                          : '',
                      waitDuration: const Duration(milliseconds: 100),
                      preferBelow: true,
                      textStyle: TextStyle(
                        fontSize: isWeb ? 14 : 12.sp,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildToggleButton(
                        AppStrings.get('delivery') ?? 'Delivery',
                        isDelivery,
                        isWeb,
                        onTap: isDeliveryDisabled
                            ? null
                            : () {
                                checkoutProvider.setDeliveryType(DeliveryType.delivery);
                                checkoutProvider.updateDeliveryFee(
                                    Provider.of<CartProvider>(context, listen: false).subtotal);
                              },
                        isDisabled: isDeliveryDisabled,
                      ),
                    ),
                  ),
                ],
              ),
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
                              'Delivery is temporarily unavailable',
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

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    bool isWeb, {
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final color = isDisabled ? Colors.grey.shade400 : AppColors.primary;

    return Semantics(
      label: isDisabled
          ? '$text (${AppStrings.get('deliveryNotAvailableNow') ?? 'Delivery is temporarily unavailable'})'
          : text,
      enabled: !isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: MouseRegion(
          cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isDisabled ? null : onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                vertical: isWeb ? 18 : 12.h,
                horizontal: isWeb ? 16 : 12.w,
              ),
              decoration: BoxDecoration(
                gradient: isSelected && !isDisabled
                    ? LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected && !isDisabled
                    ? null
                    : (isWeb ? Colors.grey.shade50 : Colors.white),
                borderRadius: BorderRadius.circular(isWeb ? 12 : 8.r),
                border: Border.all(
                  color: isSelected && !isDisabled ? color : Colors.grey.shade200,
                  width: isWeb ? 0 : 1,
                ),
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
                    text == AppStrings.get('delivery') ? Icons.delivery_dining : Icons.shopping_bag,
                    color: isSelected && !isDisabled ? Colors.white : color,
                    size: isWeb ? 22 : 20.sp,
                  ),
                  SizedBox(width: isWeb ? 10 : 8.w),
                  Text(
                    text,
                    textAlign: TextAlign.center,
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
                      size: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
