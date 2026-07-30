import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';

import 'offers_responsive.dart';

/// Extracted from OffersScreen._buildSliverAppBar.
class OffersSliverAppBar extends StatelessWidget {
  final double screenWidth;

  const OffersSliverAppBar({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      surfaceTintColor: Colors.white,
      leading: Container(
        margin: EdgeInsets.all(8.r),
        child: Material(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 20.sp,
            ),
          ),
        ),
      ),
      title: Text(
        AppStrings.get('specialOffers'),
        style: GoogleFonts.poppins(
          fontSize: OffersResponsive.isMobile(screenWidth) ? 18.sp : 22.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey[200]!,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
