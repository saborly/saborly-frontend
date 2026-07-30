import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/shared/models/food_item.dart';
import 'package:Saborly/shared/models/offer.dart';
import 'package:Saborly/shared/widgets/food_item_card.dart';

import 'offers_responsive.dart';

/// Extracted from OffersScreen._buildItemsGrid and ._convertToFoodItem — the
/// responsive grid of discounted food items.
class OffersItemsGrid extends StatelessWidget {
  final OffersProvider provider;
  final double screenWidth;

  const OffersItemsGrid({
    super.key,
    required this.provider,
    required this.screenWidth,
  });

  FoodItem _convertToFoodItem(FoodItemWithOffer item) {
    return FoodItem(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      imageUrl: item.imageUrl,
      category: item.category.id,
      isVeg: false,
      offer: item.offer,
      isFeatured: false,
      isPopular: false,
      rating: 0.0,
      reviewCount: 0,
      tags: [],
      mealSizes: [],
      extras: [],
      addons: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = OffersResponsive.getCrossAxisCount(screenWidth);
    final isMobile = OffersResponsive.isMobile(screenWidth);
    final childAspectRatio = OffersResponsive.getChildAspectRatio(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 12.w : (OffersResponsive.isTablet(screenWidth) ? 16.w : 20.w),
        mainAxisSpacing: isMobile ? 12.h : (OffersResponsive.isTablet(screenWidth) ? 16.h : 20.h),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: provider.itemsWithOffers.length,
      itemBuilder: (context, index) {
        final item = provider.itemsWithOffers[index];
        final foodItem = _convertToFoodItem(item);
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          ),
          child: FoodItemCard(
            foodItem: foodItem,
            showDescription: true,
            onTap: () => context.push(AppRoutes.foodDetail, extra: foodItem),
          ),
        );
      },
    );
  }
}
