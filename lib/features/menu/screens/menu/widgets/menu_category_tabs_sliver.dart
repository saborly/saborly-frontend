import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/men_provider.dart';

import 'menu_layout_utils.dart';

/// Extracted verbatim from `_MenuScreenState._buildCategoryTabsSliver`
/// (plus its private helpers `_buildEnhancedTab` and `_getCategoryIcon`).
class MenuCategoryTabsSliver extends StatelessWidget {
  final TabController? tabController;
  final MenuProvider provider;
  final double screenWidth;
  final bool isWeb;

  const MenuCategoryTabsSliver({
    super.key,
    required this.tabController,
    required this.provider,
    required this.screenWidth,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    if (tabController == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MenuLayoutUtils.getMaxContentWidth(screenWidth)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isWeb ? 48.w : 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              gradient: AppColors.surfaceGradient,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              height: 60.h,
              padding: EdgeInsets.all(6.w),
              child: TabBar(
                controller: tabController!,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                tabAlignment: TabAlignment.start,
                physics: const BouncingScrollPhysics(),
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMedium,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                  labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  tabs: [
                    _buildEnhancedTab(AppStrings.get('allCategories'), Icons.apps_rounded),

                  ...provider.categories.map(
                    (category) => _buildEnhancedTab(
                      category.name.replaceAll('\n', ' '),
                      _getCategoryIcon(category.name),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTab(String text, IconData icon) {
    return Tab(
      height: 48.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('burger')) return Icons.lunch_dining_rounded;
    if (name.contains('pizza')) return Icons.local_pizza_rounded;
    if (name.contains('chicken')) return Icons.set_meal_rounded;
    if (name.contains('seafood')) return Icons.set_meal_rounded;
    if (name.contains('sandwich')) return Icons.lunch_dining_rounded;
    if (name.contains('salad')) return Icons.eco_rounded;
    if (name.contains('appetizer')) return Icons.restaurant_rounded;
    if (name.contains('dessert')) return Icons.cake_rounded;
    if (name.contains('drink') || name.contains('beverage')) return Icons.local_cafe_rounded;
    return Icons.restaurant_menu_rounded;
  }
}
