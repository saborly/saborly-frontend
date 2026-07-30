import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';

/// Decorative panel shell (gradient background + branded accent tab) used
/// to wrap the categories/featured/popular showcase sliders on web.
class ShowcaseShell extends StatelessWidget {
  final Widget child;

  const ShowcaseShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.w),
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.15),
                blurRadius: 18.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: child,
        ),
        // Small branded accent tab so each panel reads as distinct, not a
        // repeated identical box.
        Positioned(
          top: -3.h,
          left: 28.w,
          child: Container(
            width: 46.w,
            height: 6.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}
