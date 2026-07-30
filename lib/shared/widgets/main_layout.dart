// lib/layouts/main_layout.dart - Fixed Navigation Active State with RouteAware
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import '../../core/routes/app_routes.dart';
import 'main_layout/widgets/bottom_nav_item.dart';
import 'main_layout/widgets/responsive_helper.dart';
import 'main_layout/widgets/main_app_bar.dart';
import 'main_layout/widgets/bottom_navigation_widget.dart';
import 'main_layout/widgets/cart_fab_widget.dart';

export 'main_layout/widgets/bottom_nav_item.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _currentRoute = '';
  bool _hasInitializedBranchData = false;
  GoRouterDelegate? _routerDelegate;
  VoidCallback? _routerListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachRouterListener();
    _updateCurrentRoute();

    if (!_hasInitializedBranchData) {
      _hasInitializedBranchData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final checkoutProvider = context.read<CheckoutProvider>();
        if (checkoutProvider.branches.isEmpty) {
          checkoutProvider.loadBranches();
        }
      });
    }
  }

  void _attachRouterListener() {
    // In web release builds, scheduling route sync in every build can
    // produce an exception loop. Instead, listen to router changes once.
    final router = GoRouter.of(context);
    final delegate = router.routerDelegate;
    if (_routerDelegate == delegate) return;

    // Detach old listener (if any)
    if (_routerDelegate != null && _routerListener != null) {
      _routerDelegate!.removeListener(_routerListener!);
    }

    _routerDelegate = delegate;
    _routerListener = () {
      if (!mounted) return;
      _updateCurrentRoute();
    };
    _routerDelegate!.addListener(_routerListener!);
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
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  bool _isSearchActive = false;
  String _currentSearchQuery = '';
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // ✅ Check if current route is home
  bool _isHomeScreen() {
    return _currentRoute == AppRoutes.home || _currentRoute == '/' || _currentRoute.isEmpty;
  }

  bool _routeStartsWith(String prefix) {
    if (_currentRoute.isEmpty) return false;
    return _currentRoute == prefix || _currentRoute.startsWith('$prefix/');
  }

  bool _shouldHideChrome() {
    // Screens that should NOT show app chrome (bottom nav / app bar)
    // because they are full-screen flows or should not be tab-navigable.
    final hiddenExact = <String>{
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
      AppRoutes.emailVerification,
      AppRoutes.foodDetail,
      AppRoutes.cart,
      AppRoutes.checkout,
      AppRoutes.payment,
      AppRoutes.notifications,
      AppRoutes.search,
      AppRoutes.privacy,
      AppRoutes.faq,
    };

    if (hiddenExact.contains(_currentRoute)) return true;

    // Parameterized routes
    if (_routeStartsWith('/order-status')) return true;

    return false;
  }

  bool _shouldShowBottomNav(bool isDesktop) {
    if (isDesktop) return false;
    return !_shouldHideChrome();
  }

  bool _shouldShowAppBar(bool isDesktop, bool isTablet) {
    if (!(isDesktop || isTablet)) return false;
    return !_shouldHideChrome();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isDesktop = constraints.maxWidth >= 1200;

        return Consumer<LanguageService>(
          builder: (context, languageService, _) {
            final showBottomNav = _shouldShowBottomNav(isDesktop);
            final showAppBar = _shouldShowAppBar(isDesktop, isTablet);
            return Scaffold(
              appBar: showAppBar ? _buildAppBar(isDesktop, isTablet, isSmallScreen) : null,
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
              bottomNavigationBar: showBottomNav
                  ? _buildBottomNavigation(isSmallScreen, isTablet, isDesktop)
                  : null,
              floatingActionButton: (isTablet && !isDesktop && showBottomNav)
                  ? _buildFloatingActionButton(isSmallScreen, isTablet)
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    if (_routerDelegate != null && _routerListener != null) {
      _routerDelegate!.removeListener(_routerListener!);
    }
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop, bool isTablet, bool isSmallScreen) {
    final toolbarHeight = _getResponsiveValue(
      context,
      mobile: 60.0,
      tablet: 64.0,
      desktop: 72.0
    );

    final desktopNavItems = _getDesktopNavItems();
    final desktopSelectedIndex = _getSelectedIndex(desktopNavItems);

    return MainAppBarWidget(
      isDesktop: isDesktop,
      isTablet: isTablet,
      isSmallScreen: isSmallScreen,
      toolbarHeight: toolbarHeight,
      desktopNavItems: desktopNavItems,
      desktopSelectedIndex: desktopSelectedIndex,
      onDesktopItemTapped: (index) => _onItemTapped(index, false),
      showLanguageSelector: _isHomeScreen(),
    );
  }

  Widget _buildBottomNavigation(
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop
  ) {
    final navItems = isSmallScreen ? _getMobileNavItems() : _getDesktopNavItems();
    final selectedIndex = _getSelectedIndex(navItems);

    return BottomNavigationWidget(
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      navItems: navItems,
      selectedIndex: selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }

  Widget _buildFloatingActionButton(bool isSmallScreen, bool isTablet) {
    return CartFabWidget(
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
    );
  }
}
