import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/main.dart';
import '../../../models/food_item.dart';
import 'card_sizing.dart';

/// The "Add" button rendered in the card footer. Tapping it either opens
/// customization (via [onTap], the card's own tap callback) when the item
/// has meal sizes/extras/addons, or adds it directly to the cart.
///
/// Extracted verbatim from `FoodItemCard._buildAddButton` / `_addToCart`.
class FoodItemAddButton extends StatelessWidget {
  final FoodItem foodItem;
  final CardSize cardSize;
  final double screenWidth;
  final String platform;
  final VoidCallback onTap;
  final bool expand;

  const FoodItemAddButton({
    super.key,
    required this.foodItem,
    required this.cardSize,
    required this.screenWidth,
    required this.platform,
    required this.onTap,
    this.expand = false,
  });

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
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('addedToCart').replaceAll('{itemName}', foodItem.name),
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          action: SnackBarAction(
            label: AppStrings.get('undo'),
            textColor: Colors.white,
            onPressed: () => cartProvider.removeItem(foodItem.id),
          ),
        ),
      );

      // Manual backup dismissal for Web stability
      Future.delayed(const Duration(seconds: 5), () {
        scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = CardSizing.useCompactFooter(cardSize);

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
                    ? CardSizing.getPadding(cardSize, screenWidth)
                    : CardSizing.getPadding(cardSize, screenWidth) *
                        (isCompact ? 0.95 : 1.2),
                vertical: CardSizing.getSmallPadding(cardSize, screenWidth) *
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
                    size: CardSizing.getButtonFontSize(cardSize, screenWidth),
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      AppStrings.add,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: CardSizing.getButtonFontSize(cardSize, screenWidth),
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
}
