import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/men_provider.dart';

import 'menu_layout_utils.dart';

/// Extracted verbatim from `_MenuScreenState._buildFilterSectionSliver`
/// (plus its private helper `_buildModernFilterChip`).
class MenuFilterSectionSliver extends StatelessWidget {
  final MenuProvider provider;
  final double screenWidth;

  const MenuFilterSectionSliver({
    super.key,
    required this.provider,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = screenWidth >= 1200;

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MenuLayoutUtils.getMaxContentWidth(screenWidth)),
            child: Container(
              margin: EdgeInsets.fromLTRB(
                isWeb ? 48.w : 16.w,
                10.h,
                isWeb ? 48.w : 16.w,
                6.h,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildModernFilterChip(
                        AppStrings.get('vegetarian'),
                        Icons.eco_rounded,
                        provider.showVegOnly,
                        () => provider.setVegFilter(!provider.showVegOnly),
                        AppColors.accentLeaf,
                      ),
                      SizedBox(width: 12.w),
                      _buildModernFilterChip(
                        AppStrings.get('nonVegetarian'),
                        Icons.restaurant_rounded,
                        provider.showNonVegOnly,
                        () => provider.setNonVegFilter(!provider.showNonVegOnly),
                        AppColors.primary,
                      ),
                      SizedBox(width: 12.w),
                      _buildModernFilterChip(
                        AppStrings.get('featuredItems'),
                        Icons.local_fire_department_rounded,
                        provider.showPopularOnly,
                        () => provider.setPopularFilter(!provider.showPopularOnly),
                        AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Color accentColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Colors.white : accentColor,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
