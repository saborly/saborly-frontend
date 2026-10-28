import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'bottom_nav_item.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildNavItemsForDesktop.
class DesktopNavItems extends StatelessWidget {
  final bool isSmallScreen;
  final List<BottomNavItem> navItems;
  final int selectedIndex;
  final void Function(int index) onItemTapped;

  const DesktopNavItems({
    super.key,
    required this.isSmallScreen,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Below 1400px keep the labels compact so the branch pill, search, cart
    // and account all fit next to the five links.
    final tight = MediaQuery.of(context).size.width < 1400;
    final iconSize = tight
        ? 18.0
        : ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 18.0,
            tablet: 20.0,
            desktop: 22.0
          );
    final fontSize = tight
        ? 15.0
        : ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 14.0,
            tablet: 16.0,
            desktop: 18.0
          );
    final horizontalPadding = tight
        ? 2.0
        : ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 4.0,
            tablet: 8.0,
            desktop: 12.0
          );

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = selectedIndex == index;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: InkWell(
                onTap: () => onItemTapped(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: iconSize,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                      SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textDark,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
