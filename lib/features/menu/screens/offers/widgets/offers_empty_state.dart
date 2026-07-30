import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';

import 'offers_responsive.dart';

/// Extracted from OffersScreen._buildEmptyState.
class OffersEmptyState extends StatelessWidget {
  final double screenWidth;

  const OffersEmptyState({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final isMobile = OffersResponsive.isMobile(screenWidth);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 24.w : 48.w,
          vertical: 60.h,
        ),
        padding: EdgeInsets.all(isMobile ? 40.r : 60.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: isMobile ? 64.sp : 80.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: isMobile ? 24.h : 32.h),
            Text(
              AppStrings.get('noOffersAvailable'),
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 20.sp : 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.get('checkBackLaterOffers'),
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14.sp : 16.sp,
                color: AppColors.textLight,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                context.go(AppRoutes.home);
              },
              icon: Icon(Icons.home_rounded, size: 20.sp),
              label: Text(
                AppStrings.get('browseMenu'),
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 16.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
