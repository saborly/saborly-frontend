import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/cart_provider.dart';
import '../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isWeb = screenWidth >= 600;
        
        return GestureDetector(
          onTap: onTap,
          child: _buildVerticalCard(context, constraints, screenWidth, isWeb),
        );
      },
    );
  }

  Widget _buildVerticalCard(BuildContext context, BoxConstraints constraints, double screenWidth, bool isWeb) {
    final cardSize = _getCardSize(constraints);
    final isExtraSmall = cardSize == CardSize.extraSmall;
    final isSmall = cardSize == CardSize.small || cardSize == CardSize.extraSmall;
    final isOutOfStock = AppStrings.get('outOfStock');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(mobile: 4, tablet: 6, desktop: 8, screenWidth: screenWidth).w,
        vertical: _getResponsiveValue(mobile: 4, tablet: 6, desktop: 8, screenWidth: screenWidth).h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_getBorderRadius(cardSize, screenWidth)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: isWeb ? Border.all(color: Colors.grey.withOpacity(0.1), width: 1) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getBorderRadius(cardSize, screenWidth)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isExtraSmall ? 2 : (isSmall ? 3 : 4),
                  child: _buildImageSection(cardSize, screenWidth),
                ),
                Expanded(
                  flex: isExtraSmall ? 3 : (isSmall ? 4 : 4),
                  child: _buildDetailsSection(cardSize, screenWidth, isWeb, context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(CardSize cardSize, double screenWidth, bool isWeb, BuildContext context) {
    final isExtraSmall = cardSize == CardSize.extraSmall;
    final padding = _getPadding(cardSize, screenWidth);
    final isOutOfStock = AppStrings.get('outOfStock');

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with proper constraints
          Flexible(
            child: Text(
              foodItem.name,
              maxLines: isExtraSmall ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              strutStyle: StrutStyle(
                fontSize: _getTitleFontSize(cardSize, screenWidth),
                height: 1.4,
                forceStrutHeight: true,
              ),
              style: TextStyle(
                fontSize: _getTitleFontSize(cardSize, screenWidth),
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.4,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ),
          if (cardSize != CardSize.extraSmall) ...[
            SizedBox(height: _getSpacing(cardSize, screenWidth) * 0.8),
            // Description with proper constraints
            Flexible(
              child: Text(
                foodItem.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                strutStyle: StrutStyle(
                  fontSize: _getDescriptionFontSize(cardSize, screenWidth),
                  height: 1.4,
                  forceStrutHeight: true,
                ),
                style: TextStyle(
                  fontSize: _getDescriptionFontSize(cardSize, screenWidth),
                  color: AppColors.textLight,
                  height: 1.4,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (foodItem.hasActiveOffer) ...[
                      Text(
                        '${AppStrings.currency}${foodItem.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: _getSmallFontSize(cardSize, screenWidth),
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                    ],
                    Text(
                      '${AppStrings.currency}${foodItem.effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: _getPriceFontSize(cardSize, screenWidth),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              _buildAddButton(cardSize, screenWidth, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(CardSize cardSize, double screenWidth) {
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
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => _buildImageError(cardSize, screenWidth),
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
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildImageError(cardSize, screenWidth),
                ),
        ),
        Positioned(
          top: _getPadding(cardSize, screenWidth),
          left: _getPadding(cardSize, screenWidth),
          child: Container(
            padding: EdgeInsets.all(_getSmallPadding(cardSize, screenWidth) * 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
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
        if (foodItem.hasActiveOffer)
          Positioned(
            top: _getPadding(cardSize, screenWidth),
            right: _getPadding(cardSize, screenWidth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getPadding(cardSize, screenWidth),
                vertical: _getSmallPadding(cardSize, screenWidth) * 1.5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
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
                  Text(
                    foodItem.offer?.badge ?? '${foodItem.discountPercentage}% OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getSmallFontSize(cardSize, screenWidth),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (foodItem.rating != null && foodItem.rating! > 0)
          Positioned(
            bottom: _getPadding(cardSize, screenWidth),
            left: _getPadding(cardSize, screenWidth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getPadding(cardSize, screenWidth),
                vertical: _getSmallPadding(cardSize, screenWidth) * 1.5,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: _getSmallIconSize(cardSize, screenWidth),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    foodItem.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: _getSmallFontSize(cardSize, screenWidth),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
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
              style: TextStyle(
                fontSize: _getSmallFontSize(cardSize, screenWidth),
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, CartProvider cartProvider) {
    if (foodItem.mealSizes.isNotEmpty ||
        foodItem.extras.isNotEmpty ||
        foodItem.addons.isNotEmpty) {
      onTap();
    } else {
      final foodItemWithDiscount = foodItem.copyWith(
        price: foodItem.effectivePrice,
      );
      cartProvider.addItem(foodItem: foodItemWithDiscount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('addedToCart').replaceAll('{itemName}', foodItem.name),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
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

  Widget _buildAddButton(CardSize cardSize, double screenWidth, BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: () => _addToCart(context, cartProvider),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getPadding(cardSize, screenWidth) * 1.2,
                vertical: _getSmallPadding(cardSize, screenWidth) * 2.2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: _getButtonFontSize(cardSize, screenWidth),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    AppStrings.add,
                    style: TextStyle(
                      fontSize: _getButtonFontSize(cardSize, screenWidth),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    final base = _getResponsiveValue(mobile: 12, tablet: 14, desktop: 16, screenWidth: screenWidth).r;
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
    final base = _getResponsiveValue(mobile: 8, tablet: 10, desktop: 12, screenWidth: screenWidth).w;
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
    final base = _getResponsiveValue(mobile: 4, tablet: 6, desktop: 8, screenWidth: screenWidth).h;
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
    final base = _getResponsiveValue(mobile: 14, tablet: 17, desktop: 18, screenWidth: screenWidth).sp;
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
    final base = _getResponsiveValue(mobile: 12, tablet: 14, desktop: 15, screenWidth: screenWidth).sp;
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
    final base = _getResponsiveValue(mobile: 14, tablet: 16, desktop: 17, screenWidth: screenWidth).sp;
    return base.clamp(14.0, 17.0);
  }

  double _getButtonFontSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(mobile: 14, tablet: 15, desktop: 16, screenWidth: screenWidth).sp;
    return base.clamp(13.0, 15.0);
  }

  double _getSmallFontSize(CardSize cardSize, double screenWidth) {
    return _getResponsiveValue(mobile: 11, tablet: 12, desktop: 13, screenWidth: screenWidth).sp;
  }

  double _getIconSize(CardSize cardSize, double screenWidth) {
    final base = _getResponsiveValue(mobile: 20, tablet: 22, desktop: 24, screenWidth: screenWidth).sp;
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
    final base = _getResponsiveValue(mobile: 10, tablet: 11, desktop: 12, screenWidth: screenWidth).sp;
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