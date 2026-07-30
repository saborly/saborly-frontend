import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/features/providers/cart_provider.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../shared/widgets/custom_button.dart';
import 'login_required_dialog.dart';
import 'price_row.dart';

class OrderSummaryCard extends StatelessWidget {
  final CartProvider cartProvider;
  final bool isWeb;
  final String Function() getSpecialInstructions;

  const OrderSummaryCard(
    this.cartProvider,
    this.isWeb, {
    super.key,
    required this.getSpecialInstructions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: isWeb ? 24 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
  AppStrings.get('orderSummary'),
            style: TextStyle(
              fontSize: isWeb ? 24 : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: isWeb ? 28 : 20.h),

          PriceRow(AppStrings.subtotal, cartProvider.subtotal),
          if (cartProvider.deliveryFee > 0)
            PriceRow(AppStrings.deliveryFee, cartProvider.deliveryFee),

          Padding(
            padding: EdgeInsets.symmetric(vertical: isWeb ? 20 : 12.h),
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),

          PriceRow(AppStrings.total, cartProvider.total, isTotal: true),

          SizedBox(height: isWeb ? 32 : 24),

          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: isWeb ? 56 : 48,
                child: CustomButton(
                  text: AppStrings.proceedToCheckout,
                  onPressed: () {
                    if (!authProvider.isAuthenticated) {
                      showLoginRequiredDialog(context);
                    } else {
                      context.push(AppRoutes.checkout, extra: {
                        'specialInstructions': getSpecialInstructions(),
                      });
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
