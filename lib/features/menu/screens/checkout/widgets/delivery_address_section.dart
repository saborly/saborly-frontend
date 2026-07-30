import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';

import 'address_card.dart';
import 'delivery_info_banner.dart';
import 'empty_address_state.dart';

class DeliveryAddressSection extends StatelessWidget {
  final VoidCallback onShowAddressSelectionDialog;

  const DeliveryAddressSection({
    super.key,
    required this.onShowAddressSelectionDialog,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Consumer2<CheckoutProvider, CartProvider>(
      builder: (context, checkoutProvider, cartProvider, child) {
        return Container(
          margin: isWeb ? null : EdgeInsets.all(16.w),
          padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 20.r : 16.r),
            border: isWeb
                ? Border.all(color: Colors.grey.shade100, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isWeb ? 0.03 : 0.04),
                blurRadius: isWeb ? 24 : 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: isWeb ? 24.sp : 22.sp,
                    ),
                  ),
                  SizedBox(width: isWeb ? 16.w : 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.delivery,
                          style: TextStyle(
                            fontSize: isWeb ? 20.sp : 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        if (checkoutProvider.selectedAddress == null)
                          Text(
                            AppStrings.get('chooseDeliveryAddress'),
                            style: TextStyle(
                              fontSize: isWeb ? 14.sp : 13.sp,
                              color: AppColors.textLight,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 24.h : 20.h),

              if (checkoutProvider.selectedAddress != null) ...[
                // Selected Address Card
                AddressCard(address: checkoutProvider.selectedAddress!, isWeb: isWeb),
                SizedBox(height: isWeb ? 20.h : 16.h),

                // Delivery Info Banner
                if (checkoutProvider.deliveryDistance != null)
                  DeliveryInfoBanner(
                    checkoutProvider: checkoutProvider,
                    cartProvider: cartProvider,
                    isWeb: isWeb,
                  ),

                SizedBox(height: isWeb ? 16.h : 12.h),

                // Change Address Button
                TextButton.icon(
                  onPressed: onShowAddressSelectionDialog,
                  icon: Icon(
                    Icons.edit_location_alt_rounded,
                    size: isWeb ? 20.sp : 18.sp,
                  ),
                  label: Text(
                    AppStrings.get('changeAddress'),
                    style: TextStyle(
                      fontSize: isWeb ? 15.sp : 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 16.w : 12.w,
                      vertical: isWeb ? 12.h : 10.h,
                    ),
                  ),
                ),
              ] else
                EmptyAddressState(
                  isWeb: isWeb,
                  onAddAddress: onShowAddressSelectionDialog,
                ),
            ],
          ),
        );
      },
    );
  }
}
