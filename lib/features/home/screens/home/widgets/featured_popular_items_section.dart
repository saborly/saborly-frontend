import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/features/home/widgets/web/web_popular_dishes_section.dart';
import 'package:Saborly/shared/models/food_item.dart';

/// Featured dishes ("Top picks"): a swipeable row on phones so the section
/// stays short, a grid on tablet/desktop.
class FeaturedItemsSection extends StatelessWidget {
  final HomeProvider provider;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final bool isWeb;
  final VoidCallback onClearSearchSilently;

  const FeaturedItemsSection({
    super.key,
    required this.provider,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.isWeb,
    required this.onClearSearchSilently,
  });

  @override
  Widget build(BuildContext context) {
    return _DishSection(
      items: provider.featuredItems,
      phoneLayout: DishLayout.carousel,
      phoneMaxItems: 8,
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      onClearSearchSilently: onClearSearchSilently,
    );
  }
}

/// Popular dishes ("Trending now"): a list of full-width tiles on phones,
/// a grid on tablet/desktop.
class PopularItemsSection extends StatelessWidget {
  final HomeProvider provider;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final bool isWeb;
  final VoidCallback onClearSearchSilently;

  const PopularItemsSection({
    super.key,
    required this.provider,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.isWeb,
    required this.onClearSearchSilently,
  });

  @override
  Widget build(BuildContext context) {
    return _DishSection(
      items: provider.popularItems,
      phoneLayout: DishLayout.list,
      phoneMaxItems: 4,
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      onClearSearchSilently: onClearSearchSilently,
    );
  }
}

class _DishSection extends StatelessWidget {
  final List<FoodItem> items;
  final DishLayout phoneLayout;
  final int phoneMaxItems;
  final bool isSmallScreen;
  final bool isTablet;
  final VoidCallback onClearSearchSilently;

  const _DishSection({
    required this.items,
    required this.phoneLayout,
    required this.phoneMaxItems,
    required this.isSmallScreen,
    required this.isTablet,
    required this.onClearSearchSilently,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final maxItems = isSmallScreen ? phoneMaxItems : (isTablet ? 6 : 10);

    return WebPopularDishesSection(
      items: items.take(maxItems).toList(),
      layout: isSmallScreen ? phoneLayout : DishLayout.grid,
      crossAxisCount: isTablet ? 3 : 5,
      childAspectRatio: isTablet ? 0.8 : 0.74,
      spacing: isSmallScreen ? 12 : 20,
      onTap: (item) {
        onClearSearchSilently();
        context.push(AppRoutes.foodDetail, extra: item);
      },
    );
  }
}
