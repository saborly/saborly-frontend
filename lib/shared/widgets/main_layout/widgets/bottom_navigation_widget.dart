import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';
import 'nav_item_widget.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildBottomNavigation.
class BottomNavigationWidget extends StatelessWidget {
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final List<BottomNavItem> navItems;
  final int selectedIndex;
  final void Function(int index, bool isSmallScreen) onItemTapped;

  const BottomNavigationWidget({
    super.key,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final navHeight = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 62.0,
      tablet: 66.0,
      desktop: 70.0
    );
    final horizontalPadding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 16.0,
      desktop: 24.0
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: navHeight,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = selectedIndex == index;
              return Expanded(
                child: NavItemWidget(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                  isSmallScreen: isSmallScreen,
                  onTap: () => onItemTapped(index, isSmallScreen),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
