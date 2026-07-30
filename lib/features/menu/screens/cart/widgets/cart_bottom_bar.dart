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

class CartBottomBar extends StatelessWidget {
  final CartProvider cartProvider;
  final String Function() getSpecialInstructions;

  const CartBottomBar(
    this.cartProvider, {
    super.key,
    required this.getSpecialInstructions,
  });

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
        child: Column(
          children: [
            PriceRow(AppStrings.subtotal, cartProvider.subtotal),
            if (cartProvider.deliveryFee > 0)
              PriceRow(AppStrings.deliveryFee, cartProvider.deliveryFee),
            Divider(color: AppColors.divider),
            PriceRow(AppStrings.total, cartProvider.total, isTotal: true),

            SizedBox(height: 16.h),

            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CustomButton(
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
