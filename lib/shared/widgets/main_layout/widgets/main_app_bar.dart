import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';
import 'logo_widget.dart';
import 'desktop_nav_items.dart';
import 'right_section.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildAppBar.
class MainAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isDesktop;
  final bool isTablet;
  final bool isSmallScreen;
  final double toolbarHeight;
  final List<BottomNavItem> desktopNavItems;
  final int desktopSelectedIndex;
  final void Function(int index) onDesktopItemTapped;
  final bool showLanguageSelector;

  const MainAppBarWidget({
    super.key,
    required this.isDesktop,
    required this.isTablet,
    required this.isSmallScreen,
    required this.toolbarHeight,
    required this.desktopNavItems,
    required this.desktopSelectedIndex,
    required this.onDesktopItemTapped,
    required this.showLanguageSelector,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Container(
        width: screenWidth,
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1700 : screenWidth
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 8.0,
            tablet: 12.0,
            desktop: 16.0
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: isDesktop ? 2 : 3,
              child: LogoWidget(isTablet: isTablet),
            ),
            if (isDesktop)
              Flexible(
                flex: 5,
                child: DesktopNavItems(
                  isSmallScreen: isSmallScreen,
                  navItems: desktopNavItems,
                  selectedIndex: desktopSelectedIndex,
                  onItemTapped: onDesktopItemTapped,
                ),
              ),
            Flexible(
              flex: isDesktop ? 3 : 4,
              child: RightSectionWidget(
                isDesktop: isDesktop,
                isTablet: isTablet,
                showLanguageSelector: showLanguageSelector,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
