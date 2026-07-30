import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/men_provider.dart';

import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';
import 'menu_empty_state.dart';
import 'menu_layout_utils.dart';

/// Extracted verbatim from `_MenuScreenState._buildFoodGridSliver`.
///
/// The original method reused `_buildEmptyState`, whose retry button called
/// `context.read<MenuProvider>().loadFoodItems(categoryId: _selectedCategoryId)`.
/// That call is passed in as [onEmptyStateRetry].
class MenuFoodGridSliver extends StatelessWidget {
  final MenuProvider provider;
  final double screenWidth;
  final VoidCallback onEmptyStateRetry;

  const MenuFoodGridSliver({
    super.key,
    required this.provider,
    required this.screenWidth,
    required this.onEmptyStateRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading indicator only when actually loading
    if (provider.isLoading || provider.isSearching) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Check if we have any items at all (before filtering)
    if (!provider.hasItems) {
      return SliverFillRemaining(
        child: MenuEmptyState(
          message: AppStrings.get('noFoodItemsAvailable'),
          onRetry: onEmptyStateRetry,
        ),
      );
    }

    // If filtered items are empty, show "no results" instead of loading
    if (provider.foodItems.isEmpty) {
      return SliverFillRemaining(
        child: MenuEmptyState(
          message: AppStrings.get('noFoodItemsAvailable'),
          onRetry: onEmptyStateRetry,
        ),
      );
    }

    final crossAxisCount = MenuLayoutUtils.getCrossAxisCount(screenWidth);
    // On phones we show 1 column, so use a less-tall ratio.
    final aspectRatio = screenWidth >= 1200
        ? 0.75
        : (screenWidth >= 600 ? 0.7 : 1.10);
    final isWeb = screenWidth >= 1200;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 48.w : 16.w,
        isWeb ? 8.h : 10.h,
        isWeb ? 48.w : 16.w,
        32.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(isWeb ? 18.w : 12.w),
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withOpacity(0.96), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.16),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20.w,
              mainAxisSpacing: 20.h,
              childAspectRatio: aspectRatio,
            ),
            itemCount: provider.foodItems.length,
            itemBuilder: (context, index) {
              final item = provider.foodItems[index];
              return FoodItemCard(
                foodItem: item,
                showDescription: true,
                onTap: () => context.push(AppRoutes.foodDetail, extra: item),
              );
            },
          ),
        ),
      ),
    );
  }
}
