import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import '../../../../core/routes/app_routes.dart';

/// Extracted from MainLayout._buildFloatingActionButton.
class CartFabWidget extends StatelessWidget {
  final bool isSmallScreen;
  final bool isTablet;

  const CartFabWidget({
    super.key,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: EdgeInsets.only(bottom: 80),
          child: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.cart),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart_rounded, size: 20.sp),
                if (cartProvider.isNotEmpty)
                  Positioned(
                    right: -10,
                    top: -8,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                      child: Text(
                        '${cartProvider.totalQuantity}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(
              '${AppStrings.get('currency')}${cartProvider.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}
