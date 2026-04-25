import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import '../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;

  /// When true (e.g. menu), shows description under the title. Home grids omit this.
  final bool showDescription;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.onTap,
    this.showDescription = false,
  });

  String _getCurrentPlatform() {
    if (kIsWeb) return 'web';
    return 'mobile';
  }

  double _getResponsiveValue({
    required double mobile,
    required double tablet,
    required double desktop,
    required double screenWidth,
  }) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 600) return tablet;
    return mobile;
  }

  CardSize _getCardSize(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    if (width < 140 || height < 180) return CardSize.extraSmall;
    if (width < 180 || height < 220) return CardSize.small;
    if (width < 220 || height < 280) return CardSize.medium;
    return CardSize.large;
  }

  bool _useCompactFooter(CardSize cardSize) {
    return cardSize == CardSize.extraSmall || cardSize == CardSize.small;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardSize = _getCardSize(constraints);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: _buildVerticalCard(
              context,
              screenWidth,
              cardSize,
              showDescription,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalCard(
    BuildContext context,
    double screenWidth,
    CardSize cardSize,
    bool showDescription,
  ) {
    final isCompact = _useCompactFooter(cardSize);
    final platform = _getCurrentPlatform();
    final borderRadius = _getBorderRadius(cardSize, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(
          mobile: 4,
          tablet: 6,
          desktop: 8,
          screenWidth: screenWidth,
        ).w,
        vertical: _getResponsiveValue(
          mobile: 4,
          tablet: 6,
          desktop: 8,
          screenWidth: screenWidth,
        ).h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFAF4),
            Color(0xFFFFF2E4),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.18),
            blurRadius: 26.r,
            offset: Offset(0, 12.h),
            spreadRadius: -8.r,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
            spreadRadius: -6.r,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.96),
          width: 1.4,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Positioned(
              top: -20.h,
              right: -8.w,
              child: Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.08),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isCompact ? 5 : 11,
                  child: _buildImageSection(cardSize, screenWidth, platform),
                ),
                Expanded(
                  flex: isCompact ? 15 : 9,
                  child: _buildDetailsSection(
                    cardSize,
                    screenWidth,
                    context,
                    platform,
                    showDescription,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
    CardSize cardSize,
    double screenWidth,
    BuildContext context,
    String platform,
    bool showDescription,
  ) {
    final isCompact = _useCompactFooter(cardSize);
    final padding = _getPadding(cardSize, screenWidth);
    final spacing = _getSpacing(cardSize, screenWidth);
    final hasActiveOffer = foodItem.hasActiveOfferForPlatform(platform);
    final effectivePrice = foodItem.getEffectivePriceForPlatform(platform);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding,
        padding,
        padding,
        isCompact ? padding * 0.75 : padding + 1.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDescription)
            // Mobile (1-col menu): use natural height (looks better).
            // Wider grids: give the header a flexible height and clip safely
            // to avoid tiny bottom overflows in short cards.
            (screenWidth < 600)
                ? Flexible(
                    fit: FlexFit.loose,
                    child: LayoutBuilder(
                      builder: (context, headerBox) {
                        final tight = headerBox.maxHeight.isFinite &&
                            headerBox.maxHeight < 52.h;
                        final titleLines = tight ? 1 : (isCompact ? 1 : 2);
                        final showDesc = !tight && cardSize != CardSize.extraSmall;
                        final descLines = isCompact ? 2 : 3;

                        return ClipRect(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  foodItem.name,
                                  maxLines: titleLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize:
                                        _getTitleFontSize(cardSize, screenWidth),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                    height: 1.2,
                                    fontFamily:
                                        GoogleFonts.manrope().fontFamily,
                                  ),
                                ),
                                if (showDesc) ...[
                                  SizedBox(height: spacing * 0.45),
                                  Text(
                                    foodItem.description,
                                    maxLines: descLines,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: _getDescriptionFontSize(
                                        cardSize,
                                        screenWidth,
                                      ),
                                      color: AppColors.textLight,
                                      height: 1.25,
                                      fontFamily:
                                          GoogleFonts.manrope().fontFamily,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: ClipRect(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              foodItem.name,
                              maxLines: isCompact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    _getTitleFontSize(cardSize, screenWidth),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                height: 1.2,
                                fontFamily: GoogleFonts.manrope().fontFamily,
                              ),
                            ),
                            if (cardSize != CardSize.extraSmall) ...[
                              SizedBox(height: spacing * 0.45),
                              Text(
                                foodItem.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: _getDescriptionFontSize(
                                    cardSize,
                                    screenWidth,
                                  ),
                                  color: AppColors.textLight,
                                  height: 1.25,
                                  fontFamily:
                                      GoogleFonts.manrope().fontFamily,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
          else
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        foodItem.name,
                        maxLines: isCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: _getTitleFontSize(cardSize, screenWidth),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.2,
                          fontFamily: GoogleFonts.manrope().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!isCompact) ...[
            SizedBox(height: spacing * 0.45),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildMetaChip(
                    label: foodItem.isVeg ? 'Veg choice' : 'Chef pick',
                    icon: foodItem.isVeg ? Icons.eco : Icons.restaurant,
                    cardSize: cardSize,
                    screenWidth: screenWidth,
                    backgroundColor: AppColors.accentCream,
                    foregroundColor: AppColors.primaryDark,
                  ),
                ),
                if (foodItem.isFeatured || foodItem.isPopular) ...[
                  SizedBox(width: 6.w),
                  Flexible(
                    fit: FlexFit.loose,
                    child: _buildMetaChip(
                      label: foodItem.isFeatured
                          ? AppStrings.get('featured')
                          : AppStrings.get('popular'),
                      icon: foodItem.isFeatured
                          ? Icons.star
                          : Icons.local_fire_department,
                      cardSize: cardSize,
                      screenWidth: screenWidth,
                      backgroundColor: foodItem.isFeatured
                          ? const Color(0xFFFDE7C3)
                          : const Color(0xFFFCD9CC),
                      foregroundColor: foodItem.isFeatured
                          ? const Color(0xFF9A5A00)
                          : const Color(0xFFB93812),
                    ),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: spacing * 0.35),
          if (isCompact)
            _buildCompactFooter(
              context,
              cardSize,
              screenWidth,
              platform,
              hasActiveOffer,
              effectivePrice,
            )
          else
            _buildRegularFooter(
              context,
              cardSize,
              screenWidth,
              platform,
              hasActiveOffer,
              effectivePrice,
            ),
        ],
      ),
    );
  }

  Widget _buildCompactFooter(
    BuildContext context,
    CardSize cardSize,
    double screenWidth,
    String platform,
    bool hasActiveOffer,
    double effectivePrice,
  ) {
    final spacing = _getSpacing(cardSize, screenWidth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildPriceBlock(
            cardSize,
            screenWidth,
            hasActiveOffer,
            effectivePrice,
          ),
        ),
        SizedBox(width: spacing * 0.75),
        Align(
          alignment: Alignment.centerRight,
          child: _buildAddButton(
            cardSize,
            screenWidth,
            context,
            platform,
          ),
        ),
      ],
    );
  }

  Widget _buildRegularFooter(
    BuildContext context,
    CardSize cardSize,
    double screenWidth,
    String platform,
    bool hasActiveOffer,
    double effectivePrice,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildPriceBlock(
            cardSize,
            screenWidth,
            hasActiveOffer,
            effectivePrice,
          ),
        ),
        SizedBox(width: _getSpacing(cardSize, screenWidth) * 1.3),
        Align(
          alignment: Alignment.centerRight,
          child: _buildAddButton(
            cardSize,
            screenWidth,
            context,
            platform,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBlock(
    CardSize cardSize,
    double screenWidth,
    bool hasActiveOffer,
    double effectivePrice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasActiveOffer) ...[
          Text(
            '${AppStrings.currency}${foodItem.price.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _getSmallFontSize(cardSize, screenWidth),
              color: AppColors.textLight,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              height: 1.15,
              fontFamily: GoogleFonts.manrope().fontFamily,
            ),
          ),
          SizedBox(height: 2.h),
        ],
        Text(
          '${AppStrings.currency}${effectivePrice.toStringAsFixed(2)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _getPriceFontSize(cardSize, screenWidth),
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            height: 1.1,
            fontFamily: GoogleFonts.manrope().fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChip({
    required String label,
    required IconData icon,
    required CardSize cardSize,
    required double screenWidth,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getSmallPadding(cardSize, screenWidth) * 2.8,
        vertical: _getSmallPadding(cardSize, screenWidth) * 1.35,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: foregroundColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getSmallIconSize(cardSize, screenWidth),
            color: foregroundColor,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _getSmallFontSize(cardSize, screenWidth),
              fontWeight: FontWeight.w700,
              color: foregroundColor,
              fontFamily: GoogleFonts.manrope().fontFamily,
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    CardSize cardSize,
    double screenWidth,
    String platform,
  ) {
    final hasActiveOffer = foodItem.hasActiveOfferForPlatform(platform);
    final discountPercentage =
        foodItem.getDiscountPercentageForPlatform(platform);

    return Stack(
      children: [
        SizedBox.expand(
          child: kIsWeb
              ? Image.network(
                  foodItem.imageUrl.isNotEmpty
                      ? foodItem.imageUrl
                      : 'https://picsum.photos/200/200?random=${foodItem.id}',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
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
                  imageUrl: foodItem.imageUrl.isNotEmpty
                      ? foodItem.imageUrl
                      : 'https://picsum.photos/200/200?random=${foodItem.id}',
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
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
                ),
        ),
        Positioned(
          top: _getPadding(cardSize, screenWidth),
          left: _getPadding(cardSize, screenWidth),
          child: Container(
            padding: EdgeInsets.all(
              _getSmallPadding(cardSize, screenWidth) * 1.5,
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
              size: _getSmallIconSize(cardSize, screenWidth),
            ),
          ),
        ),
        if (hasActiveOffer)
          Positioned(
            top: _getPadding(cardSize, screenWidth),
            right: _getPadding(cardSize, screenWidth),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth >= 600 ? 120.w : 104.w,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _getPadding(cardSize, screenWidth) * 0.9,
                  vertical: _getSmallPadding(cardSize, screenWidth) * 1.5,
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
                      size: _getSmallIconSize(cardSize, screenWidth),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        foodItem.offer?.badge ?? '$discountPercentage% OFF',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getSmallFontSize(cardSize, screenWidth),
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

  Widget _buildImageError(CardSize cardSize, double screenWidth) {
    return Container(
      color: AppColors.shimmer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood,
            size: _getIconSize(cardSize, screenWidth) * 1.5,
            color: AppColors.textLight,
          ),
          if (cardSize != CardSize.extraSmall) ...[
            SizedBox(height: 8.h),
            Text(
              AppStrings.get('imageNotAvailable'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _getSmallFontSize(cardSize, screenWidth),
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addToCart(
    BuildContext context,
    CartProvider cartProvider,
    String platform,
  ) {
    if (foodItem.mealSizes.isNotEmpty ||
        foodItem.extras.isNotEmpty ||
        foodItem.addons.isNotEmpty) {
      onTap();
    } else {
      final effectivePrice = foodItem.getEffectivePriceForPlatform(platform);
      final foodItemWithDiscount = foodItem.copyWith(price: effectivePrice);
      cartProvider.addItem(foodItem: foodItemWithDiscount);
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('addedToCart').replaceAll('{itemName}', foodItem.name),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.all(16.w),
          action: SnackBarAction(
            label: AppStrings.get('undo'),
            textColor: Colors.white,
            onPressed: () => cartProvider.removeItem(foodItem.id),
          ),
        ),
      );
    }
  }

  Widget _buildAddButton(
    CardSize cardSize,
    double screenWidth,
    BuildContext context,
    String platform, {
    bool expand = false,
  }) {
    final isCompact = _useCompactFooter(cardSize);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => _addToCart(context, cartProvider, platform),
            child: Container(
              constraints: expand
                  ? BoxConstraints(minHeight: 38.h)
                  : BoxConstraints(
                      minHeight: isCompact ? 32.h : 36.h,
                      minWidth: isCompact ? 0 : 84.w,
                    ),
              padding: EdgeInsets.symmetric(
                horizontal: expand
                    ? _getPadding(cardSize, screenWidth)
                    : _getPadding(cardSize, screenWidth) *
                        (isCompact ? 0.95 : 1.2),
                vertical: _getSmallPadding(cardSize, screenWidth) *
                    (isCompact ? 1.65 : 2.1),
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                    spreadRadius: -6.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: _getButtonFontSize(cardSize, screenWidth),
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      AppStrings.add,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _getButtonFontSize(cardSize, screenWidth),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: GoogleFonts.manrope().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getBorderRadius(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 18,
      tablet: 20,
      desktop: 22,
      screenWidth: screenWidth,
    ).r;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(8.0, 12.0);
      case CardSize.small:
        return base.clamp(10.0, 14.0);
      case CardSize.medium:
        return (base * 1.1).clamp(12.0, 16.0);
      case CardSize.large:
        return (base * 1.2).clamp(14.0, 18.0);
    }
  }

  double _getPadding(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 10,
      tablet: 12,
      desktop: 14,
      screenWidth: screenWidth,
    ).w;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(6.0, 8.0);
      case CardSize.small:
        return (base * 0.75).clamp(8.0, 10.0);
      case CardSize.medium:
        return base.clamp(10.0, 12.0);
      case CardSize.large:
        return (base * 1.15).clamp(12.0, 14.0);
    }
  }

  double _getSmallPadding(CardSize cardSize, double screenWidth) {
    return _getPadding(cardSize, screenWidth) * 0.4;
  }

  double _getSpacing(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 4,
      tablet: 6,
      desktop: 8,
      screenWidth: screenWidth,
    ).h;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.7).clamp(3.0, 4.0);
      case CardSize.small:
        return (base * 0.85).clamp(4.0, 6.0);
      case CardSize.medium:
        return base.clamp(6.0, 8.0);
      case CardSize.large:
        return (base * 1.15).clamp(5.0, 7.0);
    }
  }

  double _getTitleFontSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 14,
      tablet: 17,
      desktop: 18,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.82).clamp(12.5, 13.5);
      case CardSize.small:
        return (base * 0.9).clamp(14.0, 15.0);
      case CardSize.medium:
        return base.clamp(15.0, 17.0);
      case CardSize.large:
        return (base * 1.05).clamp(16.0, 18.0);
    }
  }

  double _getDescriptionFontSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 12,
      tablet: 14,
      desktop: 15,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.85).clamp(10.5, 11.5);
      case CardSize.small:
        return (base * 0.9).clamp(11.0, 12.0);
      case CardSize.medium:
        return base.clamp(12.0, 14.0);
      case CardSize.large:
        return (base * 1.1).clamp(13.0, 15.0);
    }
  }

  double _getPriceFontSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 14,
      tablet: 16,
      desktop: 17,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.92).clamp(12.5, 14.0);
      case CardSize.small:
        return (base * 0.98).clamp(13.5, 15.0);
      case CardSize.medium:
        return base.clamp(14.0, 17.0);
      case CardSize.large:
        return (base * 1.03).clamp(15.0, 18.0);
    }
  }

  double _getButtonFontSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 14,
      tablet: 15,
      desktop: 16,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.85).clamp(11.0, 12.0);
      case CardSize.small:
        return (base * 0.92).clamp(12.0, 13.0);
      case CardSize.medium:
        return base.clamp(13.0, 15.0);
      case CardSize.large:
        return (base * 1.03).clamp(14.0, 16.0);
    }
  }

  double _getSmallFontSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 11,
      tablet: 12,
      desktop: 13,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.9).clamp(9.5, 10.5);
      case CardSize.small:
        return (base * 0.96).clamp(10.0, 11.0);
      case CardSize.medium:
        return base.clamp(11.0, 13.0);
      case CardSize.large:
        return (base * 1.02).clamp(11.5, 13.5);
    }
  }

  double _getIconSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 20,
      tablet: 22,
      desktop: 24,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(16.0, 20.0);
      case CardSize.small:
        return (base * 0.9).clamp(18.0, 22.0);
      case CardSize.medium:
        return base.clamp(20.0, 24.0);
      case CardSize.large:
        return (base * 1.1).clamp(22.0, 26.0);
    }
  }

  double _getSmallIconSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(
      mobile: 10,
      tablet: 11,
      desktop: 12,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(8.0, 10.0);
      case CardSize.small:
        return (base * 0.9).clamp(9.0, 11.0);
      case CardSize.medium:
        return base.clamp(10.0, 12.0);
      case CardSize.large:
        return (base * 1.1).clamp(11.0, 13.0);
    }
  }
}

enum CardSize {
  extraSmall,
  small,
  medium,
  large,
}
