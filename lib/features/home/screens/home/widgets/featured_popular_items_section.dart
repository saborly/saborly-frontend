import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/features/home/widgets/web/web_popular_dishes_section.dart';

/// Featured-items grid/carousel shown in the "Top Picks" section.
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
    if (provider.featuredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int crossAxisCount = isSmallScreen ? 1 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 1.35 : (isTablet ? 0.78 : 0.72);
    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.featuredItems.length > maxItems ? maxItems : provider.featuredItems.length;
    final items = provider.featuredItems.take(itemCount).toList();

    return WebPopularDishesSection(
      items: items,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      spacing: isSmallScreen ? 14 : 20,
      onTap: (item) {
        onClearSearchSilently();
        context.push(AppRoutes.foodDetail, extra: item);
      },
    );
  }
}

/// Popular-items grid/carousel shown in the "Trending Now" section.
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
    if (provider.popularItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.popularItems.length > maxItems ? maxItems : provider.popularItems.length;
    int crossAxisCount = isSmallScreen ? 1 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 1.35 : (isTablet ? 0.78 : 0.72);
    final items = provider.popularItems.take(itemCount).toList();

    return WebPopularDishesSection(
      items: items,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      spacing: isSmallScreen ? 14 : 20,
      onTap: (item) {
        onClearSearchSilently();
        context.push(AppRoutes.foodDetail, extra: item);
      },
    );
  }
}
