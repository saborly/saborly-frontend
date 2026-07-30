import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../models/food_item.dart';
import 'card_sizing.dart';
import 'food_item_add_button.dart';
import 'food_item_meta_chip.dart';
import 'food_item_price_block.dart';

/// Title/description, meta chips and the price/add-to-cart footer.
/// Extracted verbatim from `FoodItemCard._buildDetailsSection` /
/// `_buildCompactFooter` / `_buildRegularFooter`.
class FoodItemDetailsSection extends StatelessWidget {
  final FoodItem foodItem;
  final CardSize cardSize;
  final double screenWidth;
  final String platform;
  final bool showDescription;
  final VoidCallback onTap;

  const FoodItemDetailsSection({
    super.key,
    required this.foodItem,
    required this.cardSize,
    required this.screenWidth,
    required this.platform,
    required this.showDescription,
    required this.onTap,
  });

  Widget _buildCompactFooter(
    BuildContext context,
    CardSize cardSize,
    double screenWidth,
    String platform,
    bool hasActiveOffer,
    double effectivePrice,
  ) {
    final spacing = CardSizing.getSpacing(cardSize, screenWidth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: FoodItemPriceBlock(
            foodItem: foodItem,
            cardSize: cardSize,
            screenWidth: screenWidth,
            hasActiveOffer: hasActiveOffer,
            effectivePrice: effectivePrice,
          ),
        ),
        SizedBox(width: spacing * 0.75),
        Align(
          alignment: Alignment.centerRight,
          child: FoodItemAddButton(
            foodItem: foodItem,
            cardSize: cardSize,
            screenWidth: screenWidth,
            platform: platform,
            onTap: onTap,
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
          child: FoodItemPriceBlock(
            foodItem: foodItem,
            cardSize: cardSize,
            screenWidth: screenWidth,
            hasActiveOffer: hasActiveOffer,
            effectivePrice: effectivePrice,
          ),
        ),
        SizedBox(width: CardSizing.getSpacing(cardSize, screenWidth) * 1.3),
        Align(
          alignment: Alignment.centerRight,
          child: FoodItemAddButton(
            foodItem: foodItem,
            cardSize: cardSize,
            screenWidth: screenWidth,
            platform: platform,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = CardSizing.useCompactFooter(cardSize);
    final padding = CardSizing.getPadding(cardSize, screenWidth);
    final spacing = CardSizing.getSpacing(cardSize, screenWidth);
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
                                        CardSizing.getTitleFontSize(cardSize, screenWidth),
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
                                      fontSize: CardSizing.getDescriptionFontSize(
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
                                    CardSizing.getTitleFontSize(cardSize, screenWidth),
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
                                  fontSize: CardSizing.getDescriptionFontSize(
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
                          fontSize: CardSizing.getTitleFontSize(cardSize, screenWidth),
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
                  child: FoodItemMetaChip(
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
                    child: FoodItemMetaChip(
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
}
