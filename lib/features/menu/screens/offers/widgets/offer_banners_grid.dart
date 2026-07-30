import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/shared/models/offer.dart';

import 'offer_banner_card.dart';
import 'offers_responsive.dart';

/// Extracted from OffersScreen._buildOfferBanners — the responsive grid of
/// combo/banner offer cards.
class OfferBannersGrid extends StatelessWidget {
  final List<OfferModel> offers;
  final double screenWidth;

  const OfferBannersGrid({
    super.key,
    required this.offers,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = OffersResponsive.isMobile(screenWidth);
    final isTablet = OffersResponsive.isTablet(screenWidth);
    final crossAxisCount = isMobile ? 1 : 2;
    final aspectRatio = isMobile ? 2.2 : 2.5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 12.w : (isTablet ? 16.w : 20.w),
        mainAxisSpacing: isMobile ? 12.h : (isTablet ? 16.h : 20.h),
        childAspectRatio: aspectRatio,
      ),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 80)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          ),
          child: OfferBannerCard(offer: offer),
        );
      },
    );
  }
}
