import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../models/food_item.dart';
import 'card_sizing.dart';

/// Card image with veg/non-veg indicator and (optional) discount badge.
/// Extracted verbatim from `FoodItemCard._buildImageSection` /
/// `_buildImageError`.
class FoodItemImageSection extends StatelessWidget {
  final FoodItem foodItem;
  final CardSize cardSize;
  final double screenWidth;
  final String platform;

  const FoodItemImageSection({
    super.key,
    required this.foodItem,
    required this.cardSize,
    required this.screenWidth,
    required this.platform,
  });

  Widget _buildImageError(CardSize cardSize, double screenWidth) {
    return Container(
      color: AppColors.shimmer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood,
            size: CardSizing.getIconSize(cardSize, screenWidth) * 1.5,
            color: AppColors.textLight,
          ),
          if (cardSize != CardSize.extraSmall) ...[
            SizedBox(height: 8.h),
            Text(
              AppStrings.get('imageNotAvailable'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: CardSizing.getSmallFontSize(cardSize, screenWidth),
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveOffer = foodItem.hasActiveOfferForPlatform(platform);
    final discountPercentage =
        foodItem.getDiscountPercentageForPlatform(platform);

    return Stack(
      children: [
        SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Decode at roughly the on-screen pixel size instead of full
              // source resolution — full-res food photos in a small grid
              // card were the main cause of scroll jank / high memory use.
              final dpr = MediaQuery.of(context).devicePixelRatio;
              final targetWidth = constraints.maxWidth.isFinite
                  ? (constraints.maxWidth * dpr).round()
                  : null;
              final imageUrl = foodItem.imageUrl.isNotEmpty
                  ? foodItem.imageUrl
                  : 'https://picsum.photos/200/200?random=${foodItem.id}';

              return kIsWeb
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      cacheWidth: targetWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.shimmer,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(cardSize, screenWidth),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 200),
                      memCacheWidth: targetWidth,
                      placeholder: (context, url) => Container(
                        color: AppColors.shimmer,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildImageError(cardSize, screenWidth),
                    );
            },
          ),
        ),
        Positioned(
          top: CardSizing.getPadding(cardSize, screenWidth),
          left: CardSizing.getPadding(cardSize, screenWidth),
          child: Container(
            padding: EdgeInsets.all(
              CardSizing.getSmallPadding(cardSize, screenWidth) * 1.5,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(
              Icons.circle,
              color: foodItem.isVeg ? Colors.green : Colors.red,
              size: CardSizing.getSmallIconSize(cardSize, screenWidth),
            ),
          ),
        ),
        if (hasActiveOffer)
          Positioned(
            top: CardSizing.getPadding(cardSize, screenWidth),
            right: CardSizing.getPadding(cardSize, screenWidth),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth >= 600 ? 120.w : 104.w,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CardSizing.getPadding(cardSize, screenWidth) * 0.9,
                  vertical: CardSizing.getSmallPadding(cardSize, screenWidth) * 1.5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentBerry, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBerry.withOpacity(0.28),
                      blurRadius: 10.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: CardSizing.getSmallIconSize(cardSize, screenWidth),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        foodItem.offer?.badge ?? '$discountPercentage% OFF',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: CardSizing.getSmallFontSize(cardSize, screenWidth),
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.manrope().fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
