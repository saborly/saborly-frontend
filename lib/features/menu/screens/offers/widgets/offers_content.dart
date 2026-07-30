import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/features/providers/offer_provider.dart';

import 'offer_banners_grid.dart';
import 'offers_empty_state.dart';
import 'offers_items_grid.dart';
import 'offers_responsive.dart';

/// Extracted from OffersScreen._buildContent — orchestrates the banner
/// grid and items grid (or the empty state when there is nothing to show).
class OffersContent extends StatelessWidget {
  final OffersProvider provider;
  final double screenWidth;

  const OffersContent({
    super.key,
    required this.provider,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final hasItemOffers = provider.itemsWithOffers.isNotEmpty;
    final hasAllOffers = provider.allOffers.isNotEmpty;

    if (!hasItemOffers && !hasAllOffers) {
      return OffersEmptyState(screenWidth: screenWidth);
    }

    final isMobile = OffersResponsive.isMobile(screenWidth);
    final edgePadding = EdgeInsets.only(
      top: isMobile ? 12.h : 20.h,
      bottom: isMobile ? 100.h : 120.h,
    );

    return Padding(
      padding: edgePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combo / banner offers
          if (hasAllOffers) ...[
            OfferBannersGrid(offers: provider.allOffers, screenWidth: screenWidth),
            if (hasItemOffers) SizedBox(height: isMobile ? 24.h : 32.h),
          ],

          // Food items with discounts
          if (hasItemOffers) OffersItemsGrid(provider: provider, screenWidth: screenWidth),
        ],
      ),
    );
  }
}
