import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/shared/models/food_category.dart';

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
    final iconSize = _isWeb(context) ? 90.w : 80.w;
    final fontSize = _isWeb(context) ? 14.sp : 13.sp;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(AppRoutes.menu, extra: {
          'category': category.id,
          'selectedIndex': 1, // Explicitly set Menu index
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
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                  Center(child: _buildIcon(iconSize, context)),
                ],
              ),
            ),
            SizedBox(height: _isWeb(context) ? 12.h : 12.h),
            Container(
              width: cardWidth,
              constraints: BoxConstraints(maxHeight: 40.h),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(double iconSize, BuildContext context) {
    if (category.imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Image.network(
          category.imageUrl,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        ),
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
        primary: const Color(0xFFFF6B9D),
        secondary: const Color(0xFFFF8FB8),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF4FACFE),
        secondary: const Color(0xFF00F2FE),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF43E97B),
        secondary: const Color(0xFF38F9D7),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFFA709A),
        secondary: const Color(0xFFFEE140),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFA8E6CF),
        secondary: const Color(0xFF88D8A3),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFFFD93D),
        secondary: const Color(0xFF6BCF7F),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF667EEA),
        secondary: const Color(0xFF764BA2),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFF093FB),
        secondary: const Color(0xFFF5576C),
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

// Helper function if you need it elsewhere
bool _isSmallScreen(BuildContext context) {
  return MediaQuery.of(context).size.width < 600;
}
bool _isWeb(BuildContext context) {
  return MediaQuery.of(context).size.width > 600;









}