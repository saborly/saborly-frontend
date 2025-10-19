// lib/layouts/main_layout.dart - Fixed Navigation Active State with RouteAware
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/shared/widgets/language_selector.dart';
import 'package:soely/shared/widgets/search_bar_widget.dart';
import '../../core/routes/app_routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _currentRoute = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentRoute();
  }

  void _updateCurrentRoute() {
    try {
      final router = GoRouter.of(context);
      // Get the full location which includes pushed routes
      final newRoute = router.routerDelegate.currentConfiguration.uri.path;
      
      // Also check matches to see if there are any pushed routes on top
      final matches = router.routerDelegate.currentConfiguration.matches;
      String actualRoute = newRoute;
      
      // If there are matches, get the last one (topmost route)
      if (matches.isNotEmpty) {
        final lastMatch = matches.last;
        if (lastMatch.matchedLocation.isNotEmpty) {
          actualRoute = lastMatch.matchedLocation;
        }
      }
      
      if (_currentRoute != actualRoute) {
        setState(() {
          _currentRoute = actualRoute;
        });
      }
    } catch (e) {
    }
  }

  double _getResponsiveValue(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }

  bool _isSearchActive = false;
  String _currentSearchQuery = '';
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // ✅ Check if current route is home
  bool _isHomeScreen() {
    return _currentRoute == AppRoutes.home || _currentRoute == '/' || _currentRoute.isEmpty;
  }

  // ✅ Get current selected index based on route
  int _getSelectedIndex(List<BottomNavItem> navItems) {
    for (int i = 0; i < navItems.length; i++) {
      if (_currentRoute == navItems[i].route) {
        return i;
      }
    }
    return -1; // No match found
  }

  List<BottomNavItem> _getDesktopNavItems() {
    return [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: AppStrings.get('home'),
        route: AppRoutes.home,
      ),
      BottomNavItem(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu,
        label: AppStrings.get('menu'),
        route: AppRoutes.menu,
      ),
      BottomNavItem(
        icon: Icons.local_offer_outlined,
        activeIcon: Icons.local_offer,
        label: AppStrings.get('offers'),
        route: AppRoutes.offer,
      ),
      BottomNavItem(
        icon: Icons.info_outline,
        activeIcon: Icons.info,
        label: AppStrings.get('aboutUs'),
        route: AppRoutes.about,
      ),
      BottomNavItem(
        icon: Icons.contact_page_outlined,
        activeIcon: Icons.contact_page,
        label: AppStrings.get('contactUs'),
        route: AppRoutes.contact,
      ),
    ];
  }

  List<BottomNavItem> _getMobileNavItems() {
    return [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: AppStrings.get('home'),
        route: AppRoutes.home,
      ),
      BottomNavItem(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu,
        label: AppStrings.get('menu'),
        route: AppRoutes.menu,
      ),
      BottomNavItem(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: AppStrings.get('cart'),
        route: AppRoutes.cart,
        isCart: true,
      ),
      BottomNavItem(
        icon: Icons.local_offer_outlined,
        activeIcon: Icons.local_offer,
        label: AppStrings.get('offers'),
        route: AppRoutes.offer,
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: AppStrings.get('profile'),
        route: AppRoutes.profile,
      ),
    ];
  }

  void _onItemTapped(int index, bool isSmallScreen) {
    final navItems = isSmallScreen ? _getMobileNavItems() : _getDesktopNavItems();
    if (index >= 0 && index < navItems.length) {
      context.go(navItems[index].route);
      // Force update route after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateCurrentRoute();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update route on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateCurrentRoute();
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isDesktop = constraints.maxWidth >= 1200;

        return Consumer<LanguageService>(
          builder: (context, languageService, _) {
            return Scaffold(
              appBar: (isDesktop || isTablet) ? _buildAppBar(isDesktop, isTablet, isSmallScreen) : null,
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1980 : double.infinity,
                  ),
                  child: SafeArea(
                    child: widget.child,
                  ),
                ),
              ),
              bottomNavigationBar: !isDesktop 
                  ? _buildBottomNavigation(isSmallScreen, isTablet, isDesktop) 
                  : null,
              floatingActionButton: isTablet && !isDesktop 
                  ? _buildFloatingActionButton(isSmallScreen, isTablet) 
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop, bool isTablet, bool isSmallScreen) {
    final toolbarHeight = _getResponsiveValue(
      context, 
      mobile: 60.0, 
      tablet: 64.0, 
      desktop: 72.0
    );
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
          horizontal: _getResponsiveValue(
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
              child: _buildLogo(isTablet),
            ),
            if (isDesktop)
              Flexible(
                flex: 5,
                child: _buildNavItemsForDesktop(isSmallScreen),
              ),
            Flexible(
              flex: isDesktop ? 3 : 4,
              child: _buildRightSection(isDesktop, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isTablet) {
    final logoWidth = _getResponsiveValue(
      context, 
      mobile: 100.0, 
      tablet: 120.0, 
      desktop: 140.0
    );
    final logoHeight = _getResponsiveValue(
      context, 
      mobile: 40.0, 
      tablet: 45.0, 
      desktop: 50.0
    );
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(
          context, 
          mobile: 4.0, 
          tablet: 6.0, 
          desktop: 10.0
        ),
      ),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.home),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: logoWidth,
          height: logoHeight,
          child: Image.asset(
            'assets/images/logo3.png',
            fit: BoxFit.contain,
            semanticLabel: AppStrings.get('appLogo'),
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemsForDesktop(bool isSmallScreen) {
    final iconSize = _getResponsiveValue(
      context, 
      mobile: 18.0, 
      tablet: 20.0, 
      desktop: 22.0
    );
    final fontSize = _getResponsiveValue(
      context, 
      mobile: 14.0, 
      tablet: 16.0, 
      desktop: 18.0
    );
    final horizontalPadding = _getResponsiveValue(
      context, 
      mobile: 4.0, 
      tablet: 8.0, 
      desktop: 12.0
    );
    
    final navItems = _getDesktopNavItems();
    final selectedIndex = _getSelectedIndex(navItems);
    
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
                onTap: () => _onItemTapped(index, false),
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

Widget _buildRightSection(bool isDesktop, bool isTablet) {
  final spacing = _getResponsiveValue(
    context, 
    mobile: 4.0, 
    tablet: 6.0, 
    desktop: 7.0
  );
  
  final showLanguageSelector = _isHomeScreen();
  
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      if (isDesktop) ...[
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 289),
            child: GestureDetector(
              onTap: () {
                // ✅ Navigate to search page when clicking search bar
                context.push(AppRoutes.search);
              },
              child: AbsorbPointer(
                child: SearchBarWidget(
                  onSearch: (query) {},
                  onSearchStarted: null,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
      ],
      if (showLanguageSelector) ...[
        LanguageSelector(
          showLabel: true,
          isCompact: true,
        ),
        SizedBox(width: spacing),
      ],
      _buildCartButton(isTablet),
      SizedBox(width: spacing),
      _buildAccountButton(isTablet),
    ],
  );
}

  Widget _buildCartButton(bool isTablet) {
    final horizontalPadding = _getResponsiveValue(
      context, 
      mobile: 10.0, 
      tablet: 12.0, 
      desktop: 14.0
    );
    final iconSize = _getResponsiveValue(
      context, 
      mobile: 18.0, 
      tablet: 20.0, 
      desktop: 22.0
    );
    final fontSize = _getResponsiveValue(
      context, 
      mobile: 13.0, 
      tablet: 14.0, 
      desktop: 15.0
    );
    final badgeSize = _getResponsiveValue(
      context, 
      mobile: 14.0, 
      tablet: 16.0, 
      desktop: 18.0
    );
    final badgeFontSize = _getResponsiveValue(
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

  Widget _buildAccountButton(bool isTablet) {
    final horizontalPadding = _getResponsiveValue(
      context, 
      mobile: 12.0, 
      tablet: 14.0, 
      desktop: 16.0
    );
    final iconSize = _getResponsiveValue(
      context, 
      mobile: 16.0, 
      tablet: 17.0, 
      desktop: 18.0
    );
    final fontSize = _getResponsiveValue(
      context, 
      mobile: 12.0, 
      tablet: 13.0, 
      desktop: 14.0
    );
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.profile),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, 
            vertical: 10
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary, 
                AppColors.primary.withOpacity(0.85)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_rounded, 
                color: Colors.white, 
                size: iconSize
              ),
              SizedBox(width: 6),
              Text(
                AppStrings.get('account'),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    bool isSmallScreen, 
    bool isTablet, 
    bool isDesktop
  ) {
    final navItems = isSmallScreen ? _getMobileNavItems() : _getDesktopNavItems();
    final selectedIndex = _getSelectedIndex(navItems);
    
    final navHeight = _getResponsiveValue(
      context, 
      mobile: 62.0, 
      tablet: 66.0, 
      desktop: 70.0
    );
    final horizontalPadding = _getResponsiveValue(
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
                child: _buildNavItem(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                  isSmallScreen: isSmallScreen,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required int index,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    final iconSize = _getResponsiveValue(
      context, 
      mobile: 22.0, 
      tablet: 24.0, 
      desktop: 24.0
    );
    final fontSize = _getResponsiveValue(
      context, 
      mobile: 10.0, 
      tablet: 10.5, 
      desktop: 11.0
    );
    final badgeSize = _getResponsiveValue(
      context, 
      mobile: 14.0, 
      tablet: 15.0, 
      desktop: 16.0
    );
    final badgeFontSize = _getResponsiveValue(
      context, 
      mobile: 7.5, 
      tablet: 8.0, 
      desktop: 8.0
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index, isSmallScreen),
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

  Widget _buildFloatingActionButton(bool isSmallScreen, bool isTablet) {
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

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isCart;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isCart = false,
  });
}