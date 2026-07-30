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
import 'package:Saborly/features/home/widgets/web/web_google_reviews_section.dart';
import 'package:Saborly/features/home/widgets/web/web_hero_section.dart';
import 'package:Saborly/features/home/widgets/web/web_popular_dishes_section.dart';
import 'package:Saborly/shared/widgets/food_category_card.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';
import 'package:Saborly/shared/widgets/language_selector.dart';
import 'package:Saborly/shared/widgets/offersSection.dart';
import 'package:Saborly/shared/widgets/ooter.dart';
import 'package:Saborly/shared/widgets/promotional_banner_v2.dart';
import 'package:Saborly/shared/widgets/search_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/widgets/download_app_modal.dart';



class HomeScreen extends StatefulWidget {
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

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
  bool _downloadModalCheckInFlight = false;
  bool _hasLoadedRouteData = false;

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
    final homeProvider = context.read<HomeProvider>();
    final offersProvider = context.read<OffersProvider>();
    final currentLanguage = context.read<LanguageService>().currentLanguage;

    final dataFuture = Future.wait([
      force
          ? homeProvider.loadHomeData()
          : (homeProvider.hasInitialized
              ? homeProvider.loadHomeData()
              : homeProvider.initializeIfNeeded(currentLanguage)),
      offersProvider.loadOffers(),
    ]);

    dataFuture.then((_) {
      if (mounted) setState(() {});
    });

    if (kIsWeb) {
      _checkAndShowDownloadModal();
    }
  }

  Future<void> _checkAndShowDownloadModal() async {
    if (!mounted || _downloadModalCheckInFlight) return;
    _downloadModalCheckInFlight = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDismissed = prefs.getInt('download_modal_dismissed') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastDismissed <= 7200000) return;

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      await showDownloadAppModal(context);
      await prefs.setInt('download_modal_dismissed', now);
    } finally {
      _downloadModalCheckInFlight = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      HomeScreen.routeObserver.subscribe(this, modalRoute);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _clearSearchSilently();
      _refreshHomeData(force: true);
    });
  }

  @override
  void didPush() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _clearSearchSilently();
      _refreshHomeData(force: true);
    });
  }

  @override
  void didPushNext() {
    if (mounted) _clearSearchSilently();
  }

  @override
  void dispose() {
    HomeScreen.routeObserver.unsubscribe(this);
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
            backgroundColor: AppColors.background,
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
                                      // ── Promotional Banner (Aligned with content) ──
                                      if (!homeProvider.isInSearchMode)
                                        const DynamicPromotionalBanner(),
                                      SizedBox(height: isWeb ? 28.h : 18.h),

                                      if (!isWeb) ...[
                                        _buildHeroIntro(isWeb),
                                        SizedBox(height: 18.h),
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
                                          kicker: 'Categories',
                                          isWeb: isWeb,
                                          onViewAll: () {
                                            _clearSearchSilently();
                                            context.go(AppRoutes.menu);
                                          },
                                        ),
                                        SizedBox(height: isWeb ? 24.h : 16.h),
                                        _buildShowcaseShell(
                                          child: _buildCategoriesSlider(homeProvider, context, isWeb),
                                        ),
                                        SizedBox(height: isWeb ? 48.h : 24.h),

                                        // ── Hero (web: shown after categories) ──
                                        if (isWeb) ...[
                                          _buildHeroIntro(isWeb),
                                          SizedBox(height: 48.h),
                                        ],

                                        _buildSectionHeader(
                                          AppStrings.get('featuredItems'),
                                          kicker: 'Top Picks',
                                          isWeb: isWeb,
                                          onViewAll: () => _navigateToFeaturedPage(context, homeProvider),
                                        ),
                                        SizedBox(height: isWeb ? 24.h : 16.h),
                                        _buildShowcaseShell(
                                          child: _buildFeaturedItems(homeProvider, isSmallScreen, isTablet, isDesktop, isWeb),
                                        ),
                                        SizedBox(height: isWeb ? 48.h : 24.h),

                                        if (offersProvider.itemsWithOffers.isNotEmpty ||
                                            offersProvider.allOffers.isNotEmpty) ...[
                                          const OffersSection(),
                                          SizedBox(height: isWeb ? 48.h : 24.h),
                                        ],

                                        _buildSectionHeader(
                                          AppStrings.get('mostPopularItems'),
                                          kicker: 'Trending Now',
                                          isWeb: isWeb,
                                          onViewAll: () => _navigateToPopularPage(context, homeProvider),
                                        ),
                                        SizedBox(height: isWeb ? 24.h : 16.h),
                                        _buildShowcaseShell(
                                          child: _buildPopularItems(homeProvider, isSmallScreen, isTablet, isDesktop, isWeb),
                                        ),

                                        if (isWeb) ...[
                                          SizedBox(height: 48.h),
                                          _buildSectionHeader(
                                            'What People Are Saying',
                                            kicker: 'Google Reviews',
                                            isWeb: isWeb,
                                          ),
                                          SizedBox(height: 24.h),
                                          const WebGoogleReviewsSection(),
                                        ],
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

  Widget _buildHeroIntro(bool isWeb) {
    if (isWeb) {
      return WebHeroSection(
        onOrderNow: () {
          _clearSearchSilently();
          context.go(AppRoutes.menu);
        },
        onViewOffers: () {
          _clearSearchSilently();
          context.go(AppRoutes.offer);
        },
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Fresh burgers, bold deals',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: isWeb ? 14.sp : 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Crave-worthy meals made to feel fast, warm, and premium.',
          style: GoogleFonts.breeSerif(
            fontSize: isWeb ? 36.sp : 24.sp,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Browse favorites, jump into offers, and order in a cleaner experience across web and mobile.',
          style: GoogleFonts.manrope(
            fontSize: isWeb ? 15.sp : 13.sp,
            height: 1.5,
            color: Colors.white.withOpacity(0.84),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 22.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            ElevatedButton(
              onPressed: () {
                _clearSearchSilently();
                context.go(AppRoutes.menu);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 26.w : 22.w,
                  vertical: isWeb ? 16.h : 13.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order Now',
                    style: GoogleFonts.manrope(
                      fontSize: isWeb ? 15.sp : 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, size: isWeb ? 18.sp : 16.sp),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                _clearSearchSilently();
                context.go(AppRoutes.offer);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24.w : 20.w,
                  vertical: isWeb ? 16.h : 13.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'View Offers',
                style: GoogleFonts.manrope(
                  fontSize: isWeb ? 15.sp : 14.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (!isWeb) ...[
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _HeroStat(icon: Icons.star_rounded, label: '4.8 Rating')),
              SizedBox(width: 10.w),
              Expanded(child: _HeroStat(icon: Icons.delivery_dining_rounded, label: '30 min Delivery')),
            ],
          ),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 40.w : 20.w),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.22),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: -16.h,
            child: Container(
              width: isWeb ? 150.w : 110.w,
              height: isWeb ? 150.w : 110.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (isWeb)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: content),
                  SizedBox(width: 32.w),
                  Expanded(flex: 5, child: _HeroGraphic()),
                ],
              ),
            )
          else
            content,
        ],
      ),
    );
  }

  Widget _buildShowcaseShell({required Widget child}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.w),
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.15),
                blurRadius: 18.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: child,
        ),
        // Small branded accent tab so each panel reads as distinct, not a
        // repeated identical box.
        Positioned(
          top: -3.h,
          left: 28.w,
          child: Container(
            width: 46.w,
            height: 6.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchStatusBanner(HomeProvider provider) {
    final totalResults = provider.searchResults.length;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.18),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
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

    int crossAxisCount = isSmallScreen ? 1 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 1.10 : (isTablet ? 0.8 : 0.75);

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
      backgroundColor: AppColors.background,
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
                      color: AppColors.secondary,
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
      final address = selectedAddress.address.trim();

      if (label != null && label.isNotEmpty && address.isNotEmpty) {
        return '$label • $address';
      }
      if (address.isNotEmpty) {
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

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll, bool isWeb = false, String? kicker}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null) ...[
                Text(
                  kicker.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                title,
                style: GoogleFonts.breeSerif(
                  fontSize: isWeb ? 32.sp : 24.sp,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              if (isWeb) ...[
                SizedBox(height: 8.h),
                Container(
                  width: 84.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(999.r),
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
                  gradient: isWeb ? AppColors.surfaceGradient : null,
                  color: isWeb ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                  border: isWeb ? Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ) : null,
                  boxShadow: isWeb ? [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ] : null,
                ),
                child: Row(
                  children: [
                    Text(
                      AppStrings.viewAll,
                      style: GoogleFonts.manrope(
                        fontSize: isWeb ? 16.sp : 14.sp,
                        fontWeight: FontWeight.w800,
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
    bool isWeb,
  ) {
    if (provider.featuredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int crossAxisCount = isSmallScreen ? 1 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 1.10 : (isTablet ? 0.8 : 0.75);
    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.featuredItems.length > maxItems ? maxItems : provider.featuredItems.length;
    final items = provider.featuredItems.take(itemCount).toList();

    if (isWeb) {
      return WebPopularDishesSection(
        items: items,
        crossAxisCount: crossAxisCount,
        onTap: (item) {
          _clearSearchSilently();
          context.push(AppRoutes.foodDetail, extra: item);
        },
      );
    }

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
    bool isWeb,
  ) {
    if (provider.popularItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.popularItems.length > maxItems ? maxItems : provider.popularItems.length;
    int crossAxisCount = isSmallScreen ? 1 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 1.10 : (isTablet ? 0.8 : 0.75);
    final items = provider.popularItems.take(itemCount).toList();

    if (isWeb) {
      return WebPopularDishesSection(
        items: items,
        crossAxisCount: crossAxisCount,
        onTap: (item) {
          _clearSearchSilently();
          context.push(AppRoutes.foodDetail, extra: item);
        },
      );
    }

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

/// Small icon+label chip used in the hero (e.g. "4.8 Rating"). Both the
/// compact mobile row and the floating chips on the web hero graphic reuse
/// this so the stat styling stays consistent.
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.secondary),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative vector/icon-based graphic for the right side of the web hero.
/// Layered rounded panels with food icons + floating stat chips — no photo
/// assets exist in the project that fit the brand, so this stays icon-based.
class _HeroGraphic extends StatelessWidget {
  const _HeroGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 10.w,
            top: 10.h,
            child: _HeroIconTile(
              icon: Icons.lunch_dining_rounded,
              color: AppColors.secondary,
              size: 78.w,
            ),
          ),
          Positioned(
            right: 6.w,
            top: 46.h,
            child: _HeroIconTile(
              icon: Icons.local_pizza_rounded,
              color: Colors.white,
              size: 66.w,
            ),
          ),
          Positioned(
            bottom: 18.h,
            left: 40.w,
            child: _HeroIconTile(
              icon: Icons.icecream_rounded,
              color: Colors.white,
              size: 58.w,
            ),
          ),
          Positioned(
            top: -6.h,
            right: 24.w,
            child: const _HeroStat(icon: Icons.star_rounded, label: '4.8 Rating'),
          ),
          Positioned(
            bottom: -4.h,
            right: 0,
            child: const _HeroStat(icon: Icons.delivery_dining_rounded, label: '30 min Delivery'),
          ),
        ],
      ),
    );
  }
}

class _HeroIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _HeroIconTile({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(color == Colors.white ? 0.16 : 1),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color == Colors.white ? Colors.white : AppColors.primaryDark,
      ),
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
    return 1; // phones: bigger cards
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth >= 1200) return 0.7;
    if (screenWidth >= 900) return 0.72;
    if (screenWidth >= 600) return 0.75;
    return 1.10; // phones: less-tall card for 1-column grid
  }
}
