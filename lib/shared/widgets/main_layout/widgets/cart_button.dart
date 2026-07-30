import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import '../../../../core/routes/app_routes.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildCartButton.
class CartButtonWidget extends StatelessWidget {
  final bool isTablet;

  const CartButtonWidget({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 12.0,
      desktop: 14.0
    );
    final iconSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0
    );
    final fontSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 13.0,
      tablet: 14.0,
      desktop: 15.0
    );
    final badgeSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0
    );
    final badgeFontSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 8.5,
      desktop: 9.0
    );

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go(AppRoutes.cart),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_cart_rounded,
                        color: AppColors.primary,
                        size: iconSize
                      ),
                      if (cartProvider.isNotEmpty)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            constraints: BoxConstraints(
                              minWidth: badgeSize,
                              minHeight: badgeSize
                            ),
                            child: Text(
                              '${cartProvider.totalQuantity}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: badgeFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${AppStrings.get('currency')}${cartProvider.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
