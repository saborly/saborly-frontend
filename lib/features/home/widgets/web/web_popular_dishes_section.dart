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
  final double childAspectRatio;
  final double spacing;
  final ValueChanged<FoodItem> onTap;

  const WebPopularDishesSection({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 4,
    this.childAspectRatio = 0.72,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Single column (phones): a tall aspect-ratio grid card looks cramped —
    // a horizontal tile (square image + content) reads far better full-width
    // and matches the pattern most food-delivery apps use for list feeds.
    if (crossAxisCount == 1) {
      return Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.h),
            _DishCardHorizontal(item: items[i], onTap: () => onTap(items[i])),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing.w,
        mainAxisSpacing: spacing.h,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _DishCard(item: items[index], onTap: () => onTap(items[index])),
    );
  }
}

/// Shared "add to cart" behavior for both card layouts: opens the detail
/// page instead when the item needs size/extra/addon selection, otherwise
/// adds directly and shows the standard cart snackbar.
void _addDishToCart(BuildContext context, FoodItem item, VoidCallback onTap, VoidCallback onAdded) {
  if (item.mealSizes.isNotEmpty || item.extras.isNotEmpty || item.addons.isNotEmpty) {
    onTap();
    return;
  }

  final platform = kIsWeb ? 'web' : 'mobile';
  final cartProvider = context.read<CartProvider>();
  final effectivePrice = item.getEffectivePriceForPlatform(platform);
  final itemWithDiscount = item.copyWith(price: effectivePrice);
  cartProvider.addItem(foodItem: itemWithDiscount);
  onAdded();

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

/// Shared rating/veg/fresh badge shown over the dish image on both layouts.
Widget _dishBadge(FoodItem item) {
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
    _addDishToCart(context, widget.item, widget.onTap, () {
      setState(() => _added = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _added = false);
      });
    });
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
                        child: _dishBadge(item),
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

/// Full-width horizontal tile used for single-column (phone) feeds: a large
/// square image on the left with the badge/favorite overlay, name,
/// description, price and add button on the right — reads much better at
/// full width than a squashed vertical card.
class _DishCardHorizontal extends StatefulWidget {
  final FoodItem item;
  final VoidCallback onTap;
  const _DishCardHorizontal({required this.item, required this.onTap});

  @override
  State<_DishCardHorizontal> createState() => _DishCardHorizontalState();
}

class _DishCardHorizontalState extends State<_DishCardHorizontal> {
  bool _favorited = false;
  bool _added = false;

  void _handleAddToCart(BuildContext context) {
    _addDishToCart(context, widget.item, widget.onTap, () {
      setState(() => _added = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _added = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    const imageSize = 112.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: imageSize.w,
              height: imageSize.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: AppColors.accentSand),
                          )
                        : Container(color: AppColors.accentSand),
                    Positioned(left: 5.w, top: 5.h, child: _dishBadge(item)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(15, color: AppColors.textDark, weight: FontWeight.w800),
                            ),
                            if (item.description.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(12, color: AppColors.muted, weight: FontWeight.w500, height: 1.35),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _favorited = !_favorited),
                        child: AnimatedScale(
                          scale: _favorited ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            _favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 19.sp,
                            color: _favorited ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '€${item.price.toStringAsFixed(2)}',
                        style: AppTypography.body(16, color: AppColors.primary, weight: FontWeight.w800),
                      ),
                      GestureDetector(
                        onTap: () => _handleAddToCart(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: _added ? AppColors.accentLeaf : AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _added ? Icons.check_rounded : Icons.add_rounded,
                                size: 15.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _added ? 'Added' : 'Add',
                                style: AppTypography.body(12.5, color: Colors.white, weight: FontWeight.w800),
                              ),
                            ],
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
    );
  }
}
