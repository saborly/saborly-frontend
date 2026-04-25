// lib/features/search/search_results_page.dart - PROFESSIONAL IMPLEMENTATION

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/shared/models/food_item.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';
import 'package:Saborly/shared/widgets/search_bar_widget.dart';

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;

  const SearchResultsPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;
  String _activeQuery = '';
  
  static const _debounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    
    // Perform initial search if query provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    
    // Clean up provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().exitSearchMode();
    });
    
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Immediate clear if empty
    if (query.trim().isEmpty) {
      _performSearch('');
      return;
    }
    
    // Debounce search
    _debounceTimer = Timer(_debounceDelay, () {
      _performSearch(query.trim());
    });
  }

  void _performSearch(String query) {
    if (_activeQuery == query) return;
    
    setState(() {
      _activeQuery = query;
    });
    
    final provider = context.read<HomeProvider>();
    
    if (query.isEmpty) {
      provider.exitSearchMode();
    } else {
      provider.performSearch(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<HomeProvider>().exitSearchMode();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with search bar
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              
              // Content
              Consumer<HomeProvider>(
                builder: (context, provider, _) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: _buildContent(provider),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: SearchBarWidget(
        controller: _searchController,
        onSearch: _onSearchChanged,
        hintText: AppStrings.get('search'),
      ),
    );
  }

  Widget _buildContent(HomeProvider provider) {
    // Loading state
    if (provider.isSearchLoading) {
      return SliverFillRemaining(
        child: _buildLoadingState(),
      );
    }
    
    // Error state
    if (provider.searchError != null) {
      return SliverFillRemaining(
        child: _buildErrorState(provider.searchError!),
      );
    }
    
    // Empty search (initial state)
    if (_activeQuery.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptySearchState(),
      );
    }
    
    // Search results
    final results = provider.searchResults;
    
    if (results.isEmpty) {
      return SliverFillRemaining(
        child: _buildNoResultsState(),
      );
    }
    
    return _buildResultsGrid(results);
  }

  Widget _buildResultsGrid(List<FoodItem> results) {
    return SliverMainAxisGroup(
      slivers: [
        // Results header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
            child: _buildResultsHeader(results.length),
          ),
        ),
        
        // Results grid
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final crossAxisCount = _getCrossAxisCount(width);
            
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: width < 600 ? 1.10 : 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = results[index];
                  return FoodItemCard(
                    key: ValueKey('search_${item.id}'),
                    foodItem: item,
                    showDescription: true,
                    onTap: () => context.push(AppRoutes.foodDetail, extra: item),
                  );
                },
                childCount: results.length,
              ),
            );
          },
        ),
        
        // Bottom spacing
        SliverToBoxAdapter(
          child: SizedBox(height: 24.h),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(int count) {
    final itemsLabel = count == 1 
        ? AppStrings.get('item') 
        : AppStrings.get('items');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$_activeQuery"',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '$count $itemsLabel ${AppStrings.get("found")}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearSearch,
            icon: Icon(
              Icons.close,
              color: AppColors.textMedium,
              size: 20.sp,
            ),
            padding: EdgeInsets.all(8.w),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48.w,
            height: 48.h,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '${AppStrings.get("search")}...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red[400],
            ),
            SizedBox(height: 20.h),
            Text(
              AppStrings.get('error'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _performSearch(_activeQuery),
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text(AppStrings.get('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
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
      AppStrings.get('salad'),
    ];

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 64.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              AppStrings.get('startYourCulinaryJourney'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.get('searchFoodDescription'),
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              alignment: WrapAlignment.center,
              children: suggestions.map((label) {
                return _buildSuggestionChip(label);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          _searchController.text = label;
          _performSearch(label);
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForFood(label),
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              AppStrings.get('noData'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '${AppStrings.get("search")} "$_activeQuery" ${AppStrings.get("noData")}',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: Icon(Icons.clear_all, size: 18.sp),
              label: Text(
                '${AppStrings.get("clear")} ${AppStrings.get("search")}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFood(String food) {
    final lower = food.toLowerCase();
    if (lower.contains('pizza')) return Icons.local_pizza_rounded;
    if (lower.contains('burger')) return Icons.lunch_dining_rounded;
    if (lower.contains('pasta') || lower.contains('noodle')) return Icons.ramen_dining_rounded;
    if (lower.contains('salad')) return Icons.eco_rounded;
    return Icons.restaurant_rounded;
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 1; // phones: bigger cards
  }
}
