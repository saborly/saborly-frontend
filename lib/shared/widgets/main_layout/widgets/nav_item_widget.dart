import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'bottom_nav_item.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildNavItem.
class NavItemWidget extends StatelessWidget {
  final BottomNavItem item;
  final int index;
  final bool isSelected;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const NavItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
    required this.isSmallScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 22.0,
      tablet: 24.0,
      desktop: 24.0
    );
    final fontSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 10.5,
      desktop: 11.0
    );
    final badgeSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 15.0,
      desktop: 16.0
    );
    final badgeFontSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 7.5,
      tablet: 8.0,
      desktop: 8.0
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              item.isCart
                  ? Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textLight,
                              size: iconSize,
                            ),
                            if (cartProvider.isNotEmpty)
                              Positioned(
                                right: -8,
                                top: -6,
                                child: Container(
                                  padding: EdgeInsets.all(3),
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
                        );
                      },
                    )
                  : Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textLight,
                      size: iconSize,
                    ),
              SizedBox(height: 3),
              Flexible(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textLight,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
