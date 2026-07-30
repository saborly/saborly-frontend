import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import '../models/food_item.dart';
import 'food_item_card/widgets/card_sizing.dart';
import 'food_item_card/widgets/food_item_details_section.dart';
import 'food_item_card/widgets/food_item_image_section.dart';

export 'food_item_card/widgets/card_sizing.dart' show CardSize;

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
    final borderRadius = CardSizing.getBorderRadius(cardSize, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: CardSizing.getResponsiveValue(
          mobile: 4,
          tablet: 6,
          desktop: 8,
          screenWidth: screenWidth,
        ).w,
        vertical: CardSizing.getResponsiveValue(
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
                  child: FoodItemImageSection(
                    foodItem: foodItem,
                    cardSize: cardSize,
                    screenWidth: screenWidth,
                    platform: platform,
                  ),
                ),
                Expanded(
                  flex: isCompact ? 15 : 9,
                  child: FoodItemDetailsSection(
                    foodItem: foodItem,
                    cardSize: cardSize,
                    screenWidth: screenWidth,
                    platform: platform,
                    showDescription: showDescription,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
