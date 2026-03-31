import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/core/utils/responsive_utils.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/features/providers/notification_provider.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/shared/widgets/food_category_card.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';
import 'package:Saborly/shared/widgets/language_selector.dart';
import 'package:Saborly/shared/widgets/offersSection.dart';
import 'package:Saborly/shared/widgets/ooter.dart';
import 'package:Saborly/shared/widgets/promotional_banner.dart';
import 'package:Saborly/shared/widgets/search_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/widgets/download_app_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum ItemType {
  featured,
  popular,
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  DateTime? _lastPressedAt;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchResultsKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  String _lastProcessedLanguage = '';
  bool _hasShownModal = false;
  bool _hasLoadedRouteData = false;

  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    final initialLanguage = context.read<LanguageService>().currentLanguage;
    _lastProcessedLanguage = initialLanguage;
    
    // ✅ Load data immediately without waiting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _clearSearchSilently();
        _refreshHomeData();
      }
    });
  }

  Future<void> _refreshHomeData({bool force = false}) async {
    if (!mounted) return;
    if (_hasLoadedRouteData && !force) return;

    _hasLoadedRouteData = true;

    final dataFuture = Future.wait([
      context.read<HomeProvider>().loadHomeData(),
      context.read<OffersProvider>().loadOffers(),
    ]);

    dataFuture.then((_) {
      if (mounted) setState(() {});
    });

    if (ResponsiveUtils.isWeb(context) && !_hasShownModal) {
      _checkAndShowModal();
    }
  }

  // ✅ Show modal with minimal delay, independent of data loading
  Future<void> _checkAndShowModal() async {
    if (!mounted || _hasShownModal) return;

    final prefs = await SharedPreferences.getInstance();
    final lastDismissed = prefs.getInt('download_modal_dismissed') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Show if dismissed more than 2 hours ago
    if (now - lastDismissed > 7200000) {
      _hasShownModal = true;
      
      // Minimal delay - just enough for first frame
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        await showDownloadAppModal(context);
        await prefs.setInt('download_modal_dismissed', now);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
    
    final currentLanguage = context.read<LanguageService>().currentLanguage;
    
    if (_lastProcessedLanguage != currentLanguage) {
      _lastProcessedLanguage = currentLanguage;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HomeProvider>().setLanguage(currentLanguage);
          context.read<OffersProvider>().setLanguage(currentLanguage);
        }
      });
    }
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    _clearSearchSilently();
    _refreshHomeData(force: true);
  }

  @override
  void didPush() {
    if (!mounted) return;
    _clearSearchSilently();
    _refreshHomeData(force: true);
  }

  @override
  void didPushNext() {
    if (mounted) _clearSearchSilently();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearchSilently() {
    _searchController.clear();
    context.read<HomeProvider>().exitSearchMode();
  }

  void _handleSearch(String query) {
    final provider = context.read<HomeProvider>();
    
    if (query.trim().isEmpty) {
      provider.exitSearchMode();
    } else {
      provider.performSearch(query.trim());
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _scrollToSearchResults();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<HomeProvider>().exitSearchMode();
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToSearchResults() {
    if (_searchResultsKey.currentContext != null) {
      Scrollable.ensureVisible(
        _searchResultsKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  double _getMaxContentWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1400;
    if (screenWidth >= 1200) return 1200;
    return screenWidth * 0.95;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isTalet = ResponsiveUtils.isTablet(context);

    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            
            final now = DateTime.now();
            final maxDuration = const Duration(seconds: 2);
            final isWarning = _lastPressedAt == null ||
                now.difference(_lastPressedAt!) > maxDuration;

            if (isWarning) {
              _lastPressedAt = now;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.pressBackAgain,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.textDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  margin: EdgeInsets.all(16.r),
                ),
              );
              return;
            }
            
            SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: isWeb ? const Color(0xFFFAFAFA) : Colors.white,
            appBar: isWeb || isTalet ? null : _buildMobileAppBar(),
            body: Consumer2<HomeProvider, OffersProvider>(
              builder: (context, homeProvider, offersProvider, child) {
                if (homeProvider.isLoading && 
                    !homeProvider.isInSearchMode && 
                    homeProvider.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
          
                return RefreshIndicator(
                  onRefresh: () async {
                    _clearSearch();
                    await Future.wait([
                      homeProvider.loadHomeData(),
                      offersProvider.loadOffers(),
                    ]);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 600;
                      final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
                      final isDesktop = constraints.maxWidth >= 1200;
                      final screenWidth = constraints.maxWidth;
          
                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Full-width hero banner (SupperClub style) ──
                            // Placed OUTSIDE the constrained/padded column so
                            // it spans the entire screen width edge-to-edge.
                            if (!homeProvider.isInSearchMode)
                              const DynamicPromotionalBanner(),

                            // ── Constrained content area ───────────────────
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: _getMaxContentWidth(screenWidth),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _getHorizontalPadding(isSmallScreen, isTablet, isDesktop),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top spacing: generous after banner on web,
                                      // compact on mobile
                                      SizedBox(height: isWeb ? 44.h : 20.h),

                                      // Mobile search bar (below banner)
                                      if (!isWeb) ...[
                                        SearchBarWidget(
                                          controller: _searchController,
                                          onSearch: _handleSearch,
                                        ),
                                        SizedBox(height: 16.h),
                                        if (homeProvider.isInSearchMode)
                                          _buildSearchStatusBanner(homeProvider),
                                      ],

                                      if (homeProvider.isInSearchMode) ...[
                                        SizedBox(height: 24.h),
                                        _buildSearchResults(
                                          homeProvider,
                                          isSmallScreen,
                                          isTablet,
                                          isDesktop,
                                        ),
                                      ] else ...[
                                        _buildSectionHeader(
                                          AppStrings.get('ourMenu'),
                                          isWeb: isWeb,
                                          onViewAll: () {
                                            _clearSearchSilently();
                                            context.go(AppRoutes.menu);
                                          },
                                        ),
                                        SizedBox(height: isWeb ? 24.h : 16.h),
                                        _buildCategoriesSlider(homeProvider, context, isWeb),
                                        SizedBox(height: isWeb ? 48.h : 24.h),

                                        _buildSectionHeader(
                                          AppStrings.get('featuredItems'),
                                          isWeb: isWeb,
                                          onViewAll: () => _navigateToFeaturedPage(context, homeProvider),
                                        ),
                                        SizedBox(height: isWeb ? 24.h : 16.h),
                                        _buildFeaturedItems(homeProvider, isSmallScreen, isTablet, isDesktop),
                                        SizedBox(height: isWeb ? 48.h : 24.h),

                                        if (offersProvider.itemsWithOffers.isNotEmpty ||
                                            offersProvider.allOffers.isNotEmpty) ...[
                                          const OffersSection(),
                                          SizedBox(height: isWeb ? 48.h : 24.h),
                                        ],

                                        _buildSectionHeader(
                                          AppStrings.get('mostPopularItems'),
                                          isWeb: isWeb,
                                          onViewAll: () => _navigateToPopularPage(context, homeProvider),
                                        ),
                                        SizedBox(height: isWeb ? 24.h : 16.h),
                                        _buildPopularItems(homeProvider, isSmallScreen, isTablet, isDesktop),
                                      ],

                                      SizedBox(height: isWeb ? 64.h : 32.h),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (isWeb && !homeProvider.isInSearchMode)
                              Container(
                                width: double.infinity,
                                child: FoodKingFooter(),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchStatusBanner(HomeProvider provider) {
    final totalResults = provider.searchResults.length;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Searching for "${provider.lastSearchQuery}"',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  provider.isSearchLoading 
                      ? 'Loading...'
                      : '$totalResults ${totalResults == 1 ? 'result' : 'results'} found',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearSearch,
            icon: Icon(Icons.close, color: AppColors.textDark, size: 20.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    HomeProvider provider,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    if (provider.isSearchLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (provider.searchResults.isEmpty) {
      return _buildNoResultsView();
    }

    int crossAxisCount = isSmallScreen ? 2 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 0.75 : (isTablet ? 0.8 : 0.75);

    return Column(
      key: _searchResultsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isSmallScreen ? 8.w : (isTablet ? 16.w : 20.w),
            mainAxisSpacing: isSmallScreen ? 8.h : (isTablet ? 16.h : 20.h),
            childAspectRatio: childAspectRatio,
          ),
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            final item = provider.searchResults[index];
            return FoodItemCard(
              key: ValueKey('search_${item.id}'),
              foodItem: item,
              onTap: () {
                _clearSearchSilently();
                context.push(AppRoutes.foodDetail, extra: item);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80.sp, color: AppColors.textLight),
            SizedBox(height: 24.h),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textMedium),
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: Icon(Icons.clear_all, size: 20.sp),
              label: Text('Clear Search', style: TextStyle(fontSize: 16.sp)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeaturedPage(BuildContext context, HomeProvider provider) {
    _clearSearchSilently();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsGridPage(
          itemType: ItemType.featured,
          titleKey: 'featuredItems',
          emptyIcon: Icons.star_border,
          emptyTitleKey: 'noFeaturedItems',
        ),
      ),
    );
  }

  void _navigateToPopularPage(BuildContext context, HomeProvider provider) {
    _clearSearchSilently();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsGridPage(
          itemType: ItemType.popular,
          titleKey: 'popularItems',
          emptyIcon: Icons.trending_up,
          emptyTitleKey: 'noPopularItems',
        ),
      ),
    );
  }

  double _getHorizontalPadding(bool isSmallScreen, bool isTablet, bool isDesktop) {
    if (isSmallScreen) return 16.w;
    if (isTablet) return 40.w;
    return 60.w;
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 78.h,
      automaticallyImplyLeading: false,
      title: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, _) {
          final locationText = _getLocationLabel(checkoutProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(context),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () => context.go(AppRoutes.checkout),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: LanguageSelector(showLabel: false, isCompact: true),
        ),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final unreadCount = notificationProvider.unreadCount;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    _clearSearchSilently();
                    context.push(AppRoutes.notifications);
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textDark,
                    size: 24.sp,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints:
                          BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getLocationLabel(CheckoutProvider checkoutProvider) {
    final selectedAddress = checkoutProvider.selectedAddress;
    if (selectedAddress != null) {
      final label = selectedAddress.type?.trim();
      final address = selectedAddress.address?.trim();

      if (label != null && label.isNotEmpty && address != null && address.isNotEmpty) {
        return '$label • $address';
      }
      if (address != null && address.isNotEmpty) {
        return address;
      }
      if (label != null && label.isNotEmpty) {
        return label;
      }
    }

    final selectedBranch = checkoutProvider.selectedBranch;
    if (selectedBranch != null) {
      return '${AppStrings.pickupLocation}: ${selectedBranch.name}';
    }

    return '${AppStrings.pickupLocation}: Saborly Barcelona';
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _clearSearch();
        context.go(AppRoutes.home);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        child: Hero(
          tag: 'app_logo',
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 140.w),
            child: AspectRatio(
              aspectRatio: 3,
              child: Image.asset(
                'assets/images/logo3.png',
                fit: BoxFit.contain,
                semanticLabel: AppStrings.get('appLogo'),
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error_outline,
                  size: 24.sp,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll, bool isWeb = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isWeb ? 32.sp : 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              if (isWeb) ...[
                SizedBox(height: 8.h),
                Container(
                  width: 60.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 20.w : 12.w,
                  vertical: isWeb ? 12.h : 8.h,
                ),
                decoration: BoxDecoration(
                  color: isWeb ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: isWeb ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ) : null,
                  boxShadow: isWeb ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ] : null,
                ),
                child: Row(
                  children: [
                    Text(
                      AppStrings.viewAll,
                      style: TextStyle(
                        fontSize: isWeb ? 16.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward,
                      size: isWeb ? 18.sp : 16.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesSlider(HomeProvider provider, BuildContext context, bool isWeb) {
    if (provider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: isWeb ? 140.h : 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          return Padding(
            padding: EdgeInsets.only(right: isWeb ? 16.w : 12.w),
            child: FoodCategoryCard(
              category: category,
              onTap: () {
                _clearSearchSilently();
                context.push(AppRoutes.menu, extra: {'category': category.id});
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedItems(
    HomeProvider provider,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    if (provider.featuredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int crossAxisCount = isSmallScreen ? 2 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 0.75 : (isTablet ? 0.8 : 0.75);
    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.featuredItems.length > maxItems ? maxItems : provider.featuredItems.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8.w : (isTablet ? 16.w : 20.w),
        mainAxisSpacing: isSmallScreen ? 8.h : (isTablet ? 16.h : 20.h),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = provider.featuredItems[index];
        return FoodItemCard(
          key: ValueKey('featured_${item.id}'),
          foodItem: item,
          onTap: () {
            _clearSearchSilently();
            context.push(AppRoutes.foodDetail, extra: item);
          },
        );
      },
    );
  }

  Widget _buildPopularItems(
    HomeProvider provider,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    if (provider.popularItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.popularItems.length > maxItems ? maxItems : provider.popularItems.length;
    int crossAxisCount = isSmallScreen ? 2 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 0.75 : (isTablet ? 0.8 : 0.75);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8.w : (isTablet ? 16.w : 20.w),
        mainAxisSpacing: isSmallScreen ? 8.h : (isTablet ? 16.h : 20.h),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = provider.popularItems[index];
        return FoodItemCard(
          key: ValueKey('popular_${item.id}'),
          foodItem: item,
          onTap: () {
            _clearSearchSilently();
            context.push(AppRoutes.foodDetail, extra: item);
          },
        );
      },
    );
  }
}

class ItemsGridPage extends StatelessWidget {
  final ItemType itemType;
  final String titleKey;
  final IconData emptyIcon;
  final String emptyTitleKey;

  const ItemsGridPage({
    super.key,
    required this.itemType,
    required this.titleKey,
    required this.emptyIcon,
    required this.emptyTitleKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    return Consumer2<LanguageService, HomeProvider>(
      builder: (context, languageService, homeProvider, _) {
        final items = itemType == ItemType.featured 
            ? homeProvider.featuredItems 
            : homeProvider.popularItems;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              AppStrings.get(titleKey),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: AppColors.textDark),
          ),
          body: homeProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: _getAspectRatio(screenWidth),
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return FoodItemCard(
                          key: ValueKey('${itemType.name}_${items[index].id}'),
                          foodItem: items[index],
                          onTap: () {
                            context.push(AppRoutes.foodDetail, extra: items[index]);
                          },
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emptyIcon, size: 80.sp, color: AppColors.textLight),
          SizedBox(height: 16.h),
          Text(
            AppStrings.get(emptyTitleKey),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.get('checkBackForItems'),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2;
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth >= 1200) return 0.7;
    if (screenWidth >= 900) return 0.72;
    if (screenWidth >= 600) return 0.75;
    return 0.68;
  }
}
