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
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/features/home/widgets/mobile_categories_section.dart';
import 'package:Saborly/features/home/widgets/web/web_google_reviews_section.dart';
import 'package:Saborly/features/videos/data/saborly_videos.dart';
import 'package:Saborly/features/videos/screens/video_reels_viewer.dart';
import 'package:Saborly/features/videos/widgets/video_showcase_section.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';
import 'package:Saborly/shared/widgets/offersSection.dart';
import 'package:Saborly/shared/widgets/ooter.dart';
import 'package:Saborly/shared/widgets/promotional_banner_v2.dart';
import 'package:Saborly/shared/widgets/search_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/download_app_modal.dart';
import 'home/widgets/categories_slider.dart';
import 'home/widgets/featured_popular_items_section.dart';
import 'home/widgets/hero_intro_section.dart';
import 'home/widgets/home_error_banner.dart';
import 'home/widgets/home_mobile_app_bar.dart';
import 'home/widgets/search_results_section.dart';
import 'home/widgets/search_status_banner.dart';
import 'home/widgets/section_header.dart';
import 'home/widgets/showcase_shell.dart';



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

    // Note: no extra setState() here — HomeProvider/OffersProvider already
    // call notifyListeners(), which the Consumer2 below rebuilds on. An
    // additional setState() was rebuilding the whole screen a second time
    // on every load.
    Future.wait([
      force
          ? homeProvider.loadHomeData()
          : (homeProvider.hasInitialized
              ? homeProvider.loadHomeData()
              : homeProvider.initializeIfNeeded(currentLanguage)),
      offersProvider.loadOffers(),
    ]);

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
    // MainLayout shows its own app bar from 600px up, so the home screen only
    // adds the mobile one below that (600–767px used to get both).
    final showMobileAppBar = MediaQuery.sizeOf(context).width < 600;

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
            appBar: showMobileAppBar
                ? HomeMobileAppBar(
                    onClearSearchSilently: _clearSearchSilently,
                    onClearSearch: _clearSearch,
                  )
                : null,
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
                      final isSearching = homeProvider.isInSearchMode;
                      final sectionGap = SizedBox(height: isWeb ? 64 : 32);
                      final hasOffers = offersProvider.itemsWithOffers.isNotEmpty ||
                          offersProvider.allOffers.isNotEmpty;

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
                                      SizedBox(height: isWeb ? 28 : 14),

                                      // ── Search (app: first thing on the page) ──
                                      if (!isWeb) ...[
                                        SearchBarWidget(
                                          controller: _searchController,
                                          onSearch: _handleSearch,
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      if (isSearching) ...[
                                        if (!isWeb)
                                          SearchStatusBanner(
                                            provider: homeProvider,
                                            onClear: _clearSearch,
                                          ),
                                        const SizedBox(height: 24),
                                        SearchResultsSection(
                                          resultsKey: _searchResultsKey,
                                          provider: homeProvider,
                                          isSmallScreen: isSmallScreen,
                                          isTablet: isTablet,
                                          isDesktop: isDesktop,
                                          onClearSearchSilently: _clearSearchSilently,
                                          onClearSearch: _clearSearch,
                                        ),
                                      ] else ...[
                                        // ── Promotional banner ──
                                        const DynamicPromotionalBanner(),

                                        // ── Connection/server error (nothing loaded at all) ──
                                        if (homeProvider.error != null &&
                                            homeProvider.categories.isEmpty &&
                                            homeProvider.featuredItems.isEmpty &&
                                            homeProvider.popularItems.isEmpty) ...[
                                          SizedBox(height: isWeb ? 28 : 18),
                                          HomeErrorBanner(onRetry: () => _refreshHomeData(force: true)),
                                        ],

                                        // ── Categories ──
                                        if (homeProvider.categories.isNotEmpty) ...[
                                          SizedBox(height: isWeb ? 48 : 28),
                                          _section(
                                            isWeb: isWeb,
                                            title: AppStrings.get('ourMenu'),
                                            kicker: AppStrings.get('homeKickerCategories'),
                                            onViewAll: () {
                                              _clearSearchSilently();
                                              context.go(AppRoutes.menu);
                                            },
                                            child: isWeb
                                                ? ShowcaseShell(
                                                    child: CategoriesSlider(
                                                      provider: homeProvider,
                                                      isWeb: isWeb,
                                                      onClearSearchSilently: _clearSearchSilently,
                                                    ),
                                                  )
                                                : MobileCategoriesSection(
                                                    categories: homeProvider.categories,
                                                    onTap: (category) {
                                                      _clearSearchSilently();
                                                      context.push(AppRoutes.menu, extra: {'category': category.id});
                                                    },
                                                  ),
                                          ),
                                        ],

                                        // ── Top picks ──
                                        if (homeProvider.featuredItems.isNotEmpty) ...[
                                          sectionGap,
                                          _section(
                                            isWeb: isWeb,
                                            title: AppStrings.get('featuredItems'),
                                            kicker: AppStrings.get('homeKickerTopPicks'),
                                            onViewAll: () => _navigateToFeaturedPage(context, homeProvider),
                                            child: FeaturedItemsSection(
                                              provider: homeProvider,
                                              isSmallScreen: isSmallScreen,
                                              isTablet: isTablet,
                                              isDesktop: isDesktop,
                                              isWeb: isWeb,
                                              onClearSearchSilently: _clearSearchSilently,
                                            ),
                                          ),
                                        ],

                                        // ── Brand band: why Saborly + order CTA ──
                                        sectionGap,
                                        HeroIntroSection(
                                          isWeb: isWeb,
                                          onClearSearchSilently: _clearSearchSilently,
                                        ),

                                        // ── Offers ──
                                        if (hasOffers) ...[
                                          sectionGap,
                                          OffersSection(
                                            header: Padding(
                                              padding: EdgeInsets.only(bottom: isWeb ? 24 : 16),
                                              child: SectionHeader(
                                                AppStrings.get('specialOffers'),
                                                kicker: AppStrings.get('homeKickerOffers'),
                                                isWeb: isWeb,
                                                onViewAll: () {
                                                  _clearSearchSilently();
                                                  context.go(AppRoutes.offer);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],

                                        // ── Trending now ──
                                        if (homeProvider.popularItems.isNotEmpty) ...[
                                          sectionGap,
                                          _section(
                                            isWeb: isWeb,
                                            title: AppStrings.get('mostPopularItems'),
                                            kicker: AppStrings.get('homeKickerTrending'),
                                            onViewAll: () => _navigateToPopularPage(context, homeProvider),
                                            child: PopularItemsSection(
                                              provider: homeProvider,
                                              isSmallScreen: isSmallScreen,
                                              isTablet: isTablet,
                                              isDesktop: isDesktop,
                                              isWeb: isWeb,
                                              onClearSearchSilently: _clearSearchSilently,
                                            ),
                                          ),
                                        ],

                                        // ── Videos ──
                                        sectionGap,
                                        _section(
                                          isWeb: isWeb,
                                          title: AppStrings.get('videosTitle'),
                                          kicker: AppStrings.get('videosKicker'),
                                          onViewAll: () => VideoReelsViewer.open(context, videos: saborlyVideos),
                                          child: VideoShowcaseSection(isWeb: isWeb),
                                        ),

                                        // ── Google reviews ── (header lives inside the
                                        // section so it's hidden too if reviews fail to load)
                                        WebGoogleReviewsSection(
                                          header: Padding(
                                            padding: EdgeInsets.only(
                                              top: isWeb ? 52 : 20,
                                              bottom: isWeb ? 24 : 16,
                                            ),
                                            child: SectionHeader(
                                              AppStrings.get('homeReviewsTitle'),
                                              kicker: AppStrings.get('homeKickerReviews'),
                                              isWeb: isWeb,
                                            ),
                                          ),
                                        ),
                                      ],

                                      SizedBox(height: isWeb ? 72 : 32),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (isWeb && !isSearching)
                              const SizedBox(
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

  /// Header (kicker + title + "view all") above a section's content, with
  /// the same spacing everywhere.
  Widget _section({
    required bool isWeb,
    required String title,
    required String kicker,
    required Widget child,
    VoidCallback? onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title, kicker: kicker, isWeb: isWeb, onViewAll: onViewAll),
        SizedBox(height: isWeb ? 24 : 14),
        child,
      ],
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
