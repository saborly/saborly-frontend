import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../models/food_item.dart';
import 'card_sizing.dart';

/// Displays the (optional) struck-through original price and the
/// effective price. Extracted verbatim from `FoodItemCard._buildPriceBlock`.
class FoodItemPriceBlock extends StatelessWidget {
  final FoodItem foodItem;
  final CardSize cardSize;
  final double screenWidth;
  final bool hasActiveOffer;
  final double effectivePrice;

  const FoodItemPriceBlock({
    super.key,
    required this.foodItem,
    required this.cardSize,
    required this.screenWidth,
    required this.hasActiveOffer,
    required this.effectivePrice,
  });

  @override
  Widget build(BuildContext context) {
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
              fontSize: CardSizing.getSmallFontSize(cardSize, screenWidth),
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
            fontSize: CardSizing.getPriceFontSize(cardSize, screenWidth),
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            height: 1.1,
            fontFamily: GoogleFonts.manrope().fontFamily,
          ),
        ),
      ],
    );
  }
}
