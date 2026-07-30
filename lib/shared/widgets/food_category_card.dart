import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/shared/models/food_category.dart';

// Optimized category card without animations
class FoodCategoryCard extends StatelessWidget {
  final FoodCategory category;
  final VoidCallback onTap;
  final int index;

  const FoodCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.index = 0,
  });

  @override
   Widget build(BuildContext context) {
    final colorScheme = _getCategoryColorScheme(category.name);
    final cardWidth = _isWeb(context) ? 120.w : 100.w;
    final baseIconSize = _isWeb(context) ? 90.w : 80.w;
    final fontSize = _isWeb(context) ? 14.sp : 13.sp;

    return LayoutBuilder(
      builder: (context, constraints) {
        var iconSize = baseIconSize;
        var spacing = 12.h;
        var textMaxHeight = 40.h;
        var textLines = 2;

        if (constraints.maxHeight.isFinite) {
          final desired = iconSize + spacing + textMaxHeight;
          final available = constraints.maxHeight;
          if (desired > available && available > 0) {
            final scale = (available / desired).clamp(0.55, 1.0);
            iconSize = iconSize * scale;
            spacing = spacing * scale;
            textMaxHeight = textMaxHeight * scale;
            if (scale < 0.75) textLines = 1;
          }
        }

        // Single radius shared by the container AND the image clip so no
        // sliver of the gradient background ever peeks out at the corners.
        final avatarRadius = (30.r * (iconSize / baseIconSize)).clamp(16.r, 30.r);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go(AppRoutes.menu, extra: {
              'category': category.id,
              'selectedIndex': 1,
            });
          },
          child: Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: _isWeb(context) ? 20.w : 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(avatarRadius),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(avatarRadius),
                    child: _buildIcon(iconSize, context),
                  ),
                ),
                SizedBox(height: spacing),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: textMaxHeight),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: textLines,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.15,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(double iconSize, BuildContext context) {
    if (category.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: category.imageUrl,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => _buildIconFallback(iconSize, context),
        errorWidget: (_, __, ___) => _buildIconFallback(iconSize, context),
      );
    }
    return _buildIconFallback(iconSize, context);
  }

  Widget _buildIconFallback(double iconSize, BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Center(
        child: Text(
          category.icon,
          style: TextStyle(
            fontSize: _isWeb(context) ? 36.sp : 32.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  CategoryColorScheme _getCategoryColorScheme(String name) {
    final schemes = [
      CategoryColorScheme(
        primary: const Color(0xFFD84E17),
        secondary: const Color(0xFFF5A623),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF6A1638),
        secondary: const Color(0xFFE76F51),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF2F7A53),
        secondary: const Color(0xFF6FBC8E),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF7B2F17),
        secondary: const Color(0xFFDB8A36),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFAA5C28),
        secondary: const Color(0xFFF2B15E),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFB23A48),
        secondary: const Color(0xFFF28482),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF4A2C21),
        secondary: const Color(0xFFB56A2D),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFE07A1F),
        secondary: const Color(0xFFF2CC8F),
      ),
    ];

    return schemes[name.hashCode.abs() % schemes.length];
  }
}

class CategoryColorScheme {
  final Color primary;
  final Color secondary;

  CategoryColorScheme({
    required this.primary,
    required this.secondary,
  });
}

Widget buildCategoriesSlider(
  HomeProvider provider,
  BuildContext context,
  bool isWeb,
) {
  if (provider.categories.isEmpty) {
    return const SizedBox.shrink();
  }

  // Get actual screen width
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 600;
  final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
  
  // Responsive values
  final topMargin = isSmallScreen ? 14.0 : (isMediumScreen ? 18.0 : 22.0);
  final sliderHeight = isSmallScreen ? 130.0 : (isMediumScreen ? 150.0 : 180.0);
  final horizontalPadding = isSmallScreen ? 8.0 : 16.0;

  return Container(
    margin: EdgeInsets.only(top: topMargin),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: sliderHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return FoodCategoryCard(
                category: category,
                index: index,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go(AppRoutes.menu, extra: {'category': category.id});
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

// (removed unused helpers)
