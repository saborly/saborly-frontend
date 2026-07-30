import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';

/// Search results grid (or the "no results" empty state) shown when the
/// user is actively searching from the home screen.
class SearchResultsSection extends StatelessWidget {
  final Key resultsKey;
  final HomeProvider provider;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onClearSearchSilently;
  final VoidCallback onClearSearch;

  const SearchResultsSection({
    super.key,
    required this.resultsKey,
    required this.provider,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.onClearSearchSilently,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
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
      return _NoResultsView(onClear: onClearSearch);
    }

    int crossAxisCount = isSmallScreen ? 1 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 1.10 : (isTablet ? 0.8 : 0.75);

    return Column(
      key: resultsKey,
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
                onClearSearchSilently();
                context.push(AppRoutes.foodDetail, extra: item);
              },
            );
          },
        ),
      ],
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final VoidCallback onClear;

  const _NoResultsView({required this.onClear});

  @override
  Widget build(BuildContext context) {
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
              onPressed: onClear,
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
}
