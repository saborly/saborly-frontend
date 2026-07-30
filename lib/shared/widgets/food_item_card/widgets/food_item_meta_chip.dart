import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'card_sizing.dart';

/// Small pill-shaped label chip (e.g. "Veg choice", "Featured", "Popular").
/// Extracted verbatim from `FoodItemCard._buildMetaChip`.
class FoodItemMetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final CardSize cardSize;
  final double screenWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  const FoodItemMetaChip({
    super.key,
    required this.label,
    required this.icon,
    required this.cardSize,
    required this.screenWidth,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CardSizing.getSmallPadding(cardSize, screenWidth) * 2.8,
        vertical: CardSizing.getSmallPadding(cardSize, screenWidth) * 1.35,
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
            size: CardSizing.getSmallIconSize(cardSize, screenWidth),
            color: foregroundColor,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: CardSizing.getSmallFontSize(cardSize, screenWidth),
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
}
