import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import 'package:Saborly/shared/models/order.dart';

class PaymentSummaryCard extends StatelessWidget {
  final PaymentProvider provider;
  final CheckoutProvider checkoutProvider;

  const PaymentSummaryCard({
    super.key,
    required this.provider,
    required this.checkoutProvider,
  });

  String _getPaymentMethodName(PaymentMethod? method) {
    if (method == null) return 'None Selected';
    switch (method) {
      case PaymentMethod.shop:
        return 'Shop Payment';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.card:
        return 'Card';
      default:
        return 'None Selected';
    }
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = provider.selectedPaymentMethod;
    final isPickup = checkoutProvider.deliveryType == DeliveryType.pickup;
    final codType = provider.codPaymentType;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('paymentSummary'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 24.h),

          _buildSummaryRow(
            AppStrings.get('orderType'),
            isPickup ? AppStrings.get('pickup') : AppStrings.get('delivery'),
          ),

          SizedBox(height: 12.h),

          _buildSummaryRow(
            AppStrings.get('paymentMethod'),
            _getPaymentMethodName(selectedMethod),
            isHighlighted: true,
          ),

          // Show COD payment type if applicable
          if (selectedMethod == PaymentMethod.cashOnDelivery &&
              codType != null) ...[
            SizedBox(height: 12.h),
            _buildSummaryRow(
              AppStrings.get('paymentType'),
              codType == CodPaymentType.cash
                  ? AppStrings.get('cash')
                  : AppStrings.get('card'),
              isHighlighted: true,
            ),
          ],
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (isPickup ? AppColors.success : AppColors.primary)
                      ?.withOpacity(0.05) ??
                  Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isPickup ? AppColors.success : AppColors.primary)
                        ?.withOpacity(0.2) ??
                    Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20.sp,
                  color: isPickup ? AppColors.success : AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isPickup
                        ? AppStrings.get('payAtShopCounter')
                        : codType == CodPaymentType.cash
                            ? AppStrings.get('payWithCashOnDelivery')
                            : AppStrings.get('payWithCardOnDelivery'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isPickup ? AppColors.success : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
