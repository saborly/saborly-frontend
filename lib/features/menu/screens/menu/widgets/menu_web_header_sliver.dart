import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'menu_layout_utils.dart';

/// Extracted verbatim from `_MenuScreenState._buildWebHeaderSliver`.
class MenuWebHeaderSliver extends StatelessWidget {
  final double screenWidth;
  final VoidCallback onFilterTap;

  const MenuWebHeaderSliver({
    super.key,
    required this.screenWidth,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(48.w, 32.h, 48.w, 24.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MenuLayoutUtils.getMaxContentWidth(screenWidth)),
            child: Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(32.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.24),
                    blurRadius: 28.r,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Bolder menu discovery',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppStrings.ourMenu,
                          style: GoogleFonts.breeSerif(
                            fontSize: 42.sp,
                            color: Colors.white,
                            letterSpacing: -1.3,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          AppStrings.get('discoverOfferings'),
                          style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.84),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),
                  ElevatedButton.icon(
                    onPressed: onFilterTap,
                    icon: Icon(Icons.tune_rounded, size: 20.sp),
                    label: Text(
                      AppStrings.get('filters'),
                      style: GoogleFonts.manrope(fontSize: 15.sp, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 18.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                      elevation: 0,
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
}
