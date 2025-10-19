// lib/features/search/search_results_page.dart - FIXED: Clear search when navigating away

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/shared/models/food_item.dart';
import 'package:soely/shared/widgets/food_item_card.dart';
import 'package:soely/shared/widgets/search_bar_widget.dart';

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;

  const SearchResultsPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  String _currentSearchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _currentSearchQuery = widget.initialQuery!;
      _searchController.text = widget.initialQuery!;
      _isSearching = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HomeProvider>().searchFoodItems(widget.initialQuery!);
          _fadeController.forward();
        }
      });
    } else {
      _fadeController.forward();
    }
  }

  
 @override
void dispose() {
  // ✅ CRITICAL: Clear all search state before disposing
  _searchController.clear();
  _currentSearchQuery = '';
  _isSearching = false;

  // ✅ CRITICAL: Reset HomeProvider to load normal data
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      context.read<HomeProvider>().resetSearch(); // ✅ Use resetSearch instead of loadData
    }
  });

  _searchController.dispose();
  _fadeController.dispose();
  super.dispose();
}

  void _handleSearch(String query) {
    setState(() {
      _currentSearchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      context.read<HomeProvider>().loadData();
    } else {
      context.read<HomeProvider>().searchFoodItems(query);
    }
  }

  void _clearSearch() {
    setState(() {
      _currentSearchQuery = '';
      _isSearching = false;
      _searchController.clear();
    });
    context.read<HomeProvider>().loadData();
  }

  List<FoodItem> _getAllResults(HomeProvider provider) {
    return [...provider.featuredItems, ...provider.popularItems];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          // ✅ Add WillPopScope to handle back button
          body: WillPopScope(
            onWillPop: () async {
              // Clear search when back button is pressed
              _clearSearch();
              return true;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildContent(provider),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(HomeProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isSmallScreen = constraints.maxWidth < 600;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1400 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    _getHorizontalPadding(isSmallScreen, isTablet, isDesktop),
                vertical: 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedSearchBar(),
                  SizedBox(height: 24.h),
                  if (_isSearching) _buildSearchStatusBanner(provider),
                  if (_isSearching) SizedBox(height: 32.h),
                  if (provider.isLoading)
                    _buildLoadingState()
                  else if (!_isSearching)
                    _buildEmptySearchState()
                  else if (_getAllResults(provider).isEmpty)
                    _buildNoResultsView()
                  else
                    _buildSearchResults(
                      provider,
                      isSmallScreen,
                      isTablet,
                      isDesktop,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: SearchBarWidget(
        controller: _searchController,
        onSearch: _handleSearch,
        hintText: AppStrings.get('search'),
      ),
    );
  }

  Widget _buildSearchStatusBanner(HomeProvider provider) {
    final totalResults = _getAllResults(provider).length;
    final itemsLabel =
        totalResults == 1 ? AppStrings.get('item') : AppStrings.get('items');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.get("search")} ${AppStrings.get("for")} "$_currentSearchQuery"',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$totalResults $itemsLabel ${AppStrings.get("found")}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: _clearSearch,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textMedium,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
    HomeProvider provider,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final allResults = _getAllResults(provider);
    int crossAxisCount = isSmallScreen ? 2 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 0.75 : (isTablet ? 0.8 : 0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${AppStrings.get('search')} ${AppStrings.get('viewDetails')}',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '${allResults.length}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isSmallScreen ? 12.w : (isTablet ? 16.w : 20.w),
            mainAxisSpacing: isSmallScreen ? 12.h : (isTablet ? 16.h : 20.h),
            childAspectRatio: childAspectRatio,
          ),
          itemCount: allResults.length,
          itemBuilder: (context, index) {
            final item = allResults[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 30)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 15 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: FoodItemCard(
                      key: ValueKey('search_${item.id}'),
                      foodItem: item,
                      onTap: () =>
                          context.push(AppRoutes.foodDetail, extra: item),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(80.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.get('loading'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    final suggestions = [
      AppStrings.get('pizza'),
      AppStrings.get('burger'),
      AppStrings.get('pasta'),
      AppStrings.get('salad')
    ];

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 60.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.get('startYourCulinaryJourney'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              constraints: BoxConstraints(maxWidth: 350.w),
              child: Text(
                AppStrings.get('searchFoodDescription'),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((label) =>
                      _buildSuggestionChip(label, _getIconForFood(label)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFood(String food) {
    final sa = food.toLowerCase();

    if (sa == AppStrings.get('pizza').toLowerCase()) {
      return Icons.local_pizza;
    } else if (sa == AppStrings.get('burger').toLowerCase()) {
      return Icons.lunch_dining;
    } else if (sa == AppStrings.get('pasta').toLowerCase()) {
      return Icons.ramen_dining;
    } else if (sa == AppStrings.get('salad').toLowerCase()) {
      return Icons.eco;
    } else {
      return Icons.restaurant;
    }
  }

  Widget _buildSuggestionChip(String label, IconData icon) {
    return InkWell(
      onTap: () => _handleSearch(label),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.search_off,
                size: 60.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.get('noData'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              constraints: BoxConstraints(maxWidth: 350.w),
              child: Text(
                '${AppStrings.get("search")} "$_currentSearchQuery" ${AppStrings.get("noData")}',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 28.h),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text(
                AppStrings.get('retry'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding(
      bool isSmallScreen, bool isTablet, bool isDesktop) {
    if (isSmallScreen) return 20.w;
    if (isTablet) return 40.w;
    return 60.w;
  }
}