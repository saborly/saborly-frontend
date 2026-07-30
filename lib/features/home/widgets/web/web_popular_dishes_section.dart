import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/constant/app_typography.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/main.dart' show scaffoldMessengerKey;
import 'package:Saborly/shared/models/food_item.dart';

/// Premium dish cards for the featured/popular grids: large image, price,
/// a rating/veg tag, add button and favorite heart.
class WebPopularDishesSection extends StatelessWidget {
  final List<FoodItem> items;
  final int crossAxisCount;
  final ValueChanged<FoodItem> onTap;

  const WebPopularDishesSection({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.h,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _DishCard(item: items[index], onTap: () => onTap(items[index])),
    );
  }
}

class _DishCard extends StatefulWidget {
  final FoodItem item;
  final VoidCallback onTap;
  const _DishCard({required this.item, required this.onTap});

  @override
  State<_DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<_DishCard> {
  bool _hovering = false;
  bool _favorited = false;
  bool _added = false;

  void _handleAddToCart(BuildContext context) {
    final item = widget.item;

    if (item.mealSizes.isNotEmpty || item.extras.isNotEmpty || item.addons.isNotEmpty) {
      widget.onTap();
      return;
    }

    final platform = kIsWeb ? 'web' : 'mobile';
    final cartProvider = context.read<CartProvider>();
    final effectivePrice = item.getEffectivePriceForPlatform(platform);
    final itemWithDiscount = item.copyWith(price: effectivePrice);
    cartProvider.addItem(foodItem: itemWithDiscount);

    setState(() => _added = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _added = false);
    });

    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('addedToCart').replaceAll('{itemName}', item.name)),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        action: SnackBarAction(
          label: AppStrings.get('undo'),
          textColor: Colors.white,
          onPressed: () => cartProvider.removeItem(item.id),
        ),
      ),
    );
  }

  Widget _buildBadge(FoodItem item) {
    final hasRating = item.rating > 0;
    final label = hasRating ? item.rating.toStringAsFixed(1) : (item.isVeg ? 'Veg' : 'Fresh');
    final icon = hasRating ? Icons.star_rounded : (item.isVeg ? Icons.eco_rounded : Icons.local_fire_department_rounded);
    final iconColor = hasRating ? AppColors.secondary : AppColors.accentLeaf;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: iconColor),
          SizedBox(width: 3.w),
          Text(label, style: AppTypography.body(10, color: Colors.white, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hovering ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(_hovering ? 0.20 : 0.09),
                blurRadius: _hovering ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hovering ? 1.07 : 1.0,
                        duration: const Duration(milliseconds: 260),
                        child: item.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(color: AppColors.accentSand),
                              )
                            : Container(color: AppColors.accentSand),
                      ),
                      Positioned(
                        left: 8.w,
                        top: 8.h,
                        child: _buildBadge(item),
                      ),
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: GestureDetector(
                          onTap: () => setState(() => _favorited = !_favorited),
                          child: AnimatedScale(
                            scale: _favorited ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                              child: Icon(
                                _favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 15.sp,
                                color: _favorited ? AppColors.primary : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(14, color: AppColors.textDark, weight: FontWeight.w800),
                    ),
                    if (item.description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(11.5, color: AppColors.muted, weight: FontWeight.w500),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€${item.price.toStringAsFixed(2)}',
                          style: AppTypography.body(15, color: AppColors.primary, weight: FontWeight.w800),
                        ),
                        GestureDetector(
                          onTap: () => _handleAddToCart(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: _added ? AppColors.accentLeaf : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _added ? Icons.check_rounded : Icons.add_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
