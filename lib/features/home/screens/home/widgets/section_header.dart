import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

/// Section title with an optional kicker label and "view all" action,
/// used above the categories / featured / popular / reviews sections.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final bool isWeb;
  
  final String? kicker;

  const SectionHeader(
    this.title, {
    super.key,
    this.onViewAll,
    this.isWeb = false,
    this.kicker,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null) ...[
                Text(
                  kicker!.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                title,
                style: GoogleFonts.breeSerif(
                  fontSize: isWeb ? 32.sp : 24.sp,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              if (isWeb) ...[
                SizedBox(height: 8.h),
                Container(
                  width: 84.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 20.w : 12.w,
                  vertical: isWeb ? 12.h : 8.h,
                ),
                decoration: BoxDecoration(
                  gradient: isWeb ? AppColors.surfaceGradient : null,
                  color: isWeb ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                  border: isWeb ? Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ) : null,
                  boxShadow: isWeb ? [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ] : null,
                ),
                child: Row(
                  children: [
                    Text(
                      AppStrings.viewAll,
                      style: GoogleFonts.manrope(
                        fontSize: isWeb ? 16.sp : 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward,
                      size: isWeb ? 18.sp : 16.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
