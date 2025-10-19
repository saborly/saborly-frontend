// lib/features/home/widgets/offers_section.dart - FIXED

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/features/providers/offer_provider.dart';
import 'package:soely/shared/models/offer.dart';
import 'package:soely/core/services/language_service.dart';

/// ✅ FIXED: Use mixin for automatic language updates
class OffersSection extends StatefulWidget {
  const OffersSection({super.key});

  @override
  State<OffersSection> createState() => _OffersSectionState();
}

class _OffersSectionState extends State<OffersSection> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Listen to language changes
    final languageService = context.watch<LanguageService>();
    AppStrings.setLanguage(languageService.currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OffersProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allOffers.isEmpty) {
          return _buildLoadingSkeleton();
        }

        if (provider.error != null && provider.allOffers.isEmpty) {
          return _buildErrorState(context, provider);
        }

        final offers = provider.allOffers.take(2).toList();
        if (offers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            SizedBox(height: 16.h),
            _buildOffersGrid(context, offers),
          ],
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 140.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Container(
              width: 60.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 1 : 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: isSmallScreen ? 2.2 : 2.5,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, OffersProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('failedToLoadOffers'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[900],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  provider.error ?? AppStrings.get('unknownError'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.loadOffers(),
            child: Text(
              AppStrings.get('retry'),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            AppStrings.get('specialOffers'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.offer),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 20.w : 12.w,
                vertical: isWeb ? 12.h : 8.h,
              ),
              decoration: BoxDecoration(
                color: isWeb ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: isWeb ? Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ) : null,
                boxShadow: isWeb ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.get('viewAll'),
                    style: TextStyle(
                      fontSize: isWeb ? 16.sp : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (isWeb) ...[
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersGrid(BuildContext context, List<OfferModel> offers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1200;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : (isTablet ? 2 : 2),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: isSmallScreen ? 2.2 : 2.5,
          ),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return _buildOfferCard(context, offer, isSmallScreen);
          },
        );
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferModel offer, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.offer);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: offer.gradientColors,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: offer.gradientColors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  offer.imageUrl ?? 'https://via.placeholder.com/400x200.png?text=Offer',
                  fit: BoxFit.contain,
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.broken_image,
                      size: 32.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),

            // Expiry badge
            if (offer.expiryDate != null)
              Positioned(
                top: 12.h,
                left: 16.w,
                child: _buildExpiryBadge(offer),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryBadge(OfferModel offer) {
    final daysLeft = offer.expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: AppColors.primary, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            daysLeft == 0 
                ? AppStrings.get('today')
                : AppStrings.get('days').replaceAll('{days}', '$daysLeft'),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}