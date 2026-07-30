import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

/// Extracted from OffersScreen._buildLoadingState — shown while offers are
/// first loading (or empty) via the OffersProvider.
class OffersLoadingState extends StatelessWidget {
  const OffersLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.get('loadingOffers'),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
