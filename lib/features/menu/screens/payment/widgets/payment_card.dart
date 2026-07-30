import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import 'package:Saborly/shared/models/order.dart';
import 'section_header.dart';
import 'cod_type_card.dart';
import 'payment_method_card.dart';

class PaymentCard extends StatelessWidget {
  final PaymentProvider provider;
  final CheckoutProvider checkoutProvider;
  final bool isWeb;

  const PaymentCard({
    super.key,
    required this.provider,
    required this.checkoutProvider,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = checkoutProvider.deliveryType == DeliveryType.pickup;

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
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: isPickup
                  ? AppStrings.get('shopPayment')
                  : AppStrings.get('deliveryPayment'),
              color: isPickup ? AppColors.success : AppColors.primary,
            ),
            SizedBox(height: 20.h),
            if (isPickup)
              PaymentMethodCard(
                name: AppStrings.get('payAtShop'),
                icon: Icons.store_outlined,
                color: AppColors.success ?? Colors.green,
                method: PaymentMethod.shop,
                provider: provider,
                isAvailable: true,
                description: AppStrings.get('payAtShopDescription'),
              )
            else ...[
              // COD Payment Type Selection for Delivery
              SectionHeader(
                  title: AppStrings.get('choosePaymentType'),
                  color: AppColors.primary),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: CodTypeCard(
                      name: AppStrings.get('cash'),
                      icon: Icons.payments_outlined,
                      type: CodPaymentType.cash,
                      provider: provider,
                      description: AppStrings.get('payWithCash'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CodTypeCard(
                      name: AppStrings.get('card'),
                      icon: Icons.credit_card,
                      type: CodPaymentType.card,
                      provider: provider,
                      description: AppStrings.get('payWithCard'),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 32.h),
            Divider(
              color: AppColors.border?.withOpacity(0.3) ??
                  Colors.grey.withOpacity(0.2),
              height: 1,
            ),
            SizedBox(height: 32.h),
            SectionHeader(
                title: AppStrings.get('otherOptionsComingSoon'),
                color: AppColors.textLight),
            SizedBox(height: 20.h),
            PaymentMethodCard(
              name: AppStrings.get('paypal'),
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF0070BA),
              method: PaymentMethod.paypal,
              provider: provider,
              isAvailable: false,
              description: AppStrings.get('paypalDescription'),
            ),
            SizedBox(height: 16.h),
            PaymentMethodCard(
              name: AppStrings.get('stripe'),
              icon: Icons.credit_card_outlined,
              color: const Color(0xFF635BFF),
              method: PaymentMethod.stripe,
              provider: provider,
              isAvailable: false,
              description: AppStrings.get('stripeDescription'),
            ),
            SizedBox(height: 16.h),
            PaymentMethodCard(
              name: AppStrings.get('card'),
              icon: Icons.credit_card,
              color: const Color(0xFF1A1F71),
              method: PaymentMethod.card,
              provider: provider,
              isAvailable: false,
              description: AppStrings.get('cardDescription'),
            ),
          ],
        ),
      ),
    );
  }
}
