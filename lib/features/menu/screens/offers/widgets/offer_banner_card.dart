import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/shared/models/food_item.dart';
import 'package:Saborly/shared/models/offer.dart';

/// Extracted from OffersScreen._buildOfferBannerCard, ._buildExpiryBadge and
/// ._addComboToCart — a single combo/banner offer card with an "Order Now"
/// action that adds a synthetic combo item to the cart.
class OfferBannerCard extends StatelessWidget {
  final OfferModel offer;

  const OfferBannerCard({super.key, required this.offer});

  void _addComboToCart(BuildContext context, OfferModel offer, double price) {
    final cart = context.read<CartProvider>();
    final syntheticItem = FoodItem(
      id: offer.id,
      name: offer.title,
      description: offer.description,
      price: price,
      imageUrl: offer.imageUrl ?? '',
      category: 'combo',
      tags: const [],
      mealSizes: const [],
      extras: const [],
      addons: const [],
    );

    cart.addItem(foodItem: syntheticItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get('addedToCart').replaceAll('{itemName}', offer.title),
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.r),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildExpiryBadge(OfferModel offer) {
    final daysLeft = offer.expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8.r),
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

  @override
  Widget build(BuildContext context) {
    final price = offer.comboPrice ?? offer.value ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: offer.gradientColors,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: offer.gradientColors.first.withValues(alpha: 0.3),
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
              child: offer.imageUrl != null
                  ? Image.network(
                      offer.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : const Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Expiry badge
          if (offer.expiryDate != null)
            Positioned(
              top: 12.h,
              left: 16.w,
              child: _buildExpiryBadge(offer),
            ),

          // Order Now button — bottom, full width
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => _addComboToCart(context, offer, price),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_rounded, size: 18.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        price > 0
                            ? 'Order Now — €${price.toStringAsFixed(2)}'
                            : 'Order Now',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
