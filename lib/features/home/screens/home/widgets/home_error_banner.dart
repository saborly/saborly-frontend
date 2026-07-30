import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';

/// Shown when the homepage couldn't load anything at all (connection lost
/// or the backend is down) — otherwise sections just silently disappear
/// with no explanation, which reads as a broken app rather than an outage.
class HomeErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const HomeErrorBanner({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 14, offset: Offset(0, 6.h)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.10), shape: BoxShape.circle),
            child: Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Couldn\'t load the menu',
                  style: GoogleFonts.manrope(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Check your connection and try again.',
                  style: GoogleFonts.manrope(fontSize: 12.sp, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.premiumAccent,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Retry', style: GoogleFonts.manrope(fontSize: 13.sp, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
