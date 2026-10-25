import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

const String _platform = kIsWeb ? 'web' : 'mobile';

/// How [WebPopularDishesSection] lays its dishes out.
enum DishLayout {
  /// Fixed-column grid of image-first cards (tablet/desktop).
  grid,

  /// Full-width horizontal tiles stacked vertically (phone feeds).
  list,

  /// One swipeable row of image-first cards (phone highlights).
  carousel,
}

/// Premium dish cards for the featured/popular sections: large image,
/// price (with the original struck through when discounted), a
/// discount/rating/veg tag and an add button.
class WebPopularDishesSection extends StatelessWidget {
  final List<FoodItem> items;
  final DishLayout layout;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final ValueChanged<FoodItem> onTap;

  const WebPopularDishesSection({
    super.key,
    required this.items,
    required this.onTap,
    this.layout = DishLayout.grid,
    this.crossAxisCount = 4,
    this.childAspectRatio = 0.72,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    switch (layout) {
      case DishLayout.list:
        return Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.h),
              _DishCardHorizontal(item: items[i], onTap: () => onTap(items[i])),
            ],
          ],
        );
      case DishLayout.carousel:
        return _DishCarousel(items: items, spacing: spacing, onTap: onTap);
      case DishLayout.grid:
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Room for the hover lift/shadow so it isn't clipped.
          padding: const EdgeInsets.only(top: 6),
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
}

/// A single swipeable row; the next card peeks in so it reads as scrollable.
class _DishCarousel extends StatelessWidget {
  static const double _shadowBleed = 10;

  final List<FoodItem> items;
  final double spacing;
  final ValueChanged<FoodItem> onTap;

  const _DishCarousel({required this.items, required this.spacing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - spacing) / 1.8).clamp(160.0, 230.0);
        final cardHeight = cardWidth * 1.36;

        return SizedBox(
          height: cardHeight + _shadowBleed * 2,
          child: ScrollConfiguration(
            // Let mouse/trackpad users drag the row too (mobile web, desktop
            // windows narrow enough to get the phone layout).
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: _shadowBleed),
              clipBehavior: Clip.none,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: spacing),
              itemBuilder: (context, index) => SizedBox(
                width: cardWidth,
                child: _DishCard(item: items[index], onTap: () => onTap(items[index])),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shared "add to cart" behavior for every card layout: opens the detail
/// page instead when the item needs size/extra/addon selection, otherwise
/// adds directly and shows the standard cart snackbar.
void _addDishToCart(BuildContext context, FoodItem item, VoidCallback onTap, VoidCallback onAdded) {
  if (item.mealSizes.isNotEmpty || item.extras.isNotEmpty || item.addons.isNotEmpty) {
    onTap();
    return;
  }

  final cartProvider = context.read<CartProvider>();
  final effectivePrice = item.getEffectivePriceForPlatform(_platform);
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

/// Tag shown over the dish image — only when it says something real: an
/// active discount, then the rating, then "veg". Most dishes get none.
Widget? _dishBadge(FoodItem item) {
  final IconData icon;
  final String label;
  final Color background;
  var iconColor = Colors.white;

  if (item.hasActiveOfferForPlatform(_platform)) {
    icon = Icons.local_offer_rounded;
    label = '-${item.getDiscountPercentageForPlatform(_platform)}%';
    background = AppColors.primary;
  } else if (item.rating > 0) {
    icon = Icons.star_rounded;
    label = item.rating.toStringAsFixed(1);
    background = Colors.black.withValues(alpha: 0.6);
    iconColor = AppColors.secondary;
  } else if (item.isVeg) {
    icon = Icons.eco_rounded;
    label = AppStrings.get('homeVeg');
    background = AppColors.accentLeaf;
  } else {
    return null;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppTypography.size(11), color: iconColor),
        const SizedBox(width: 3),
        Text(label, style: AppTypography.body(10.5, color: Colors.white, weight: FontWeight.w800, height: 1.2)),
      ],
    ),
  );
}

/// Effective price, with the original struck through when discounted —
/// the same price the cart will charge.
class _DishPrice extends StatelessWidget {
  final FoodItem item;
  final double size;

  const _DishPrice({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    final discounted = item.hasActiveOfferForPlatform(_platform);
    final effective = item.getEffectivePriceForPlatform(_platform);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 6,
      children: [
        Text(
          '${AppStrings.currency}${effective.toStringAsFixed(2)}',
          style: AppTypography.body(size, color: AppColors.primaryDark, weight: FontWeight.w800, height: 1.1),
        ),
        if (discounted)
          Text(
            '${AppStrings.currency}${item.price.toStringAsFixed(2)}',
            style: AppTypography.body(size * 0.72, color: AppColors.textLight, weight: FontWeight.w600, height: 1.3)
                .copyWith(decoration: TextDecoration.lineThrough),
          ),
      ],
    );
  }
}

Widget _dishImage(BuildContext context, FoodItem item, double width) {
  final placeholder = Container(
    color: AppColors.accentSand,
    alignment: Alignment.center,
    child: Icon(Icons.restaurant_rounded, color: AppColors.textHint, size: 28),
  );
  if (item.imageUrl.isEmpty) return placeholder;

  final dpr = MediaQuery.devicePixelRatioOf(context);
  return CachedNetworkImage(
    imageUrl: item.imageUrl,
    fit: BoxFit.cover,
    memCacheWidth: width.isFinite ? (width * dpr).round() : null,
    fadeInDuration: const Duration(milliseconds: 200),
    placeholder: (_, __) => Container(color: AppColors.shimmer),
    errorWidget: (_, __, ___) => placeholder,
  );
}

/// Image-first card used by the grid and the carousel.
class _DishCard extends StatefulWidget {
  final FoodItem item;
  final VoidCallback onTap;
  const _DishCard({required this.item, required this.onTap});

  @override
  State<_DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<_DishCard> {
  bool _hovering = false;
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
    final badge = _dishBadge(item);
    const radius = 20.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border.withValues(alpha: _hovering ? 0.9 : 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: _hovering ? 0.16 : 0.06),
                blurRadius: _hovering ? 22 : 12,
                offset: Offset(0, _hovering ? 10 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(radius - 1)),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedScale(
                          scale: _hovering ? 1.06 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: _dishImage(context, item, constraints.maxWidth),
                        ),
                        if (badge != null) Positioned(left: 10, top: 10, child: badge),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(14.5, color: AppColors.textDark, weight: FontWeight.w800, height: 1.3),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(12, color: AppColors.muted, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _DishPrice(item: item, size: 15.5)),
                        _AddCircleButton(added: _added, onTap: () => _handleAddToCart(context)),
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

class _AddCircleButton extends StatelessWidget {
  final bool added;
  final VoidCallback onTap;

  const _AddCircleButton({required this.added, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: added ? AppStrings.get('homeAdded') : AppStrings.get('add'),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: added ? AppColors.accentLeaf : AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(added ? Icons.check_rounded : Icons.add_rounded, size: 19, color: Colors.white),
        ),
      ),
    );
  }
}

/// Full-width horizontal tile used for single-column (phone) feeds: a
/// square image on the left, name, description, price and an add button on
/// the right — reads much better at full width than a squashed card.
class _DishCardHorizontal extends StatefulWidget {
  final FoodItem item;
  final VoidCallback onTap;
  const _DishCardHorizontal({required this.item, required this.onTap});

  @override
  State<_DishCardHorizontal> createState() => _DishCardHorizontalState();
}

class _DishCardHorizontalState extends State<_DishCardHorizontal> {
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
    final badge = _dishBadge(item);
    const imageSize = 104.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _dishImage(context, item, imageSize),
                      if (badge != null) Positioned(left: 6, top: 6, child: badge),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(15, color: AppColors.textDark, weight: FontWeight.w800, height: 1.3),
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(12.5, color: AppColors.muted, height: 1.35),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _DishPrice(item: item, size: 16)),
                          GestureDetector(
                            onTap: () => _handleAddToCart(context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _added ? AppColors.accentLeaf : AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _added ? Icons.check_rounded : Icons.add_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _added ? AppStrings.get('homeAdded') : AppStrings.get('add'),
                                    style: AppTypography.body(12.5, color: Colors.white, weight: FontWeight.w800, height: 1.2),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
