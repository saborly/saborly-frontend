import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';

import 'offers_responsive.dart';

/// Extracted from OffersScreen._buildHeader — the trio-of-icons badge shown
/// above the offers content. The original method received the OffersProvider
/// as a parameter but never used it, so it is intentionally not carried over
/// here (no behavior change).
class OffersHeaderBadge extends StatelessWidget {
  final double screenWidth;

  const OffersHeaderBadge({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final isMobile = OffersResponsive.isMobile(screenWidth);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth * 0.7 : 360.w,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: isMobile ? 18.h : 22.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.12),
                AppColors.primary.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: isMobile ? 20.sp : 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  color: AppColors.primary,
                  size: isMobile ? 20.sp : 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: AppColors.primary,
                  size: isMobile ? 20.sp : 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
