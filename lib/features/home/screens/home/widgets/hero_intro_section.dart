import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/home/widgets/web/web_hero_section.dart';

/// Home hero: on web, delegates to [WebHeroSection]; on mobile, renders the
/// gradient intro card with the CTA buttons and rating/delivery stat chips.
class HeroIntroSection extends StatelessWidget {
  final bool isWeb;
  final VoidCallback onClearSearchSilently;

  const HeroIntroSection({
    super.key,
    required this.isWeb,
    required this.onClearSearchSilently,
  });

  @override
  Widget build(BuildContext context) {
    if (isWeb) {
      return WebHeroSection(
        onOrderNow: () {
          onClearSearchSilently();
          context.go(AppRoutes.menu);
        },
        onViewOffers: () {
          onClearSearchSilently();
          context.go(AppRoutes.offer);
        },
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Fresh burgers, bold deals',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: isWeb ? 14.sp : 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Crave-worthy meals made to feel fast, warm, and premium.',
          style: GoogleFonts.breeSerif(
            fontSize: isWeb ? 36.sp : 24.sp,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Browse favorites, jump into offers, and order in a cleaner experience across web and mobile.',
          style: GoogleFonts.manrope(
            fontSize: isWeb ? 15.sp : 13.sp,
            height: 1.5,
            color: Colors.white.withOpacity(0.84),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 22.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            ElevatedButton(
              onPressed: () {
                onClearSearchSilently();
                context.go(AppRoutes.menu);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 26.w : 22.w,
                  vertical: isWeb ? 16.h : 13.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order Now',
                    style: GoogleFonts.manrope(
                      fontSize: isWeb ? 15.sp : 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, size: isWeb ? 18.sp : 16.sp),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                onClearSearchSilently();
                context.go(AppRoutes.offer);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24.w : 20.w,
                  vertical: isWeb ? 16.h : 13.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'View Offers',
                style: GoogleFonts.manrope(
                  fontSize: isWeb ? 15.sp : 14.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (!isWeb) ...[
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _HeroStat(icon: Icons.star_rounded, label: '4.8 Rating')),
              SizedBox(width: 10.w),
              Expanded(child: _HeroStat(icon: Icons.delivery_dining_rounded, label: '30 min Delivery')),
            ],
          ),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 40.w : 20.w),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.22),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: -16.h,
            child: Container(
              width: isWeb ? 150.w : 110.w,
              height: isWeb ? 150.w : 110.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (isWeb)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: content),
                  SizedBox(width: 32.w),
                  Expanded(flex: 5, child: _HeroGraphic()),
                ],
              ),
            )
          else
            content,
        ],
      ),
    );
  }
}

/// Small icon+label chip used in the hero (e.g. "4.8 Rating"). Both the
/// compact mobile row and the floating chips on the web hero graphic reuse
/// this so the stat styling stays consistent.
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.secondary),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative vector/icon-based graphic for the right side of the web hero.
/// Layered rounded panels with food icons + floating stat chips — no photo
/// assets exist in the project that fit the brand, so this stays icon-based.
class _HeroGraphic extends StatelessWidget {
  const _HeroGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 10.w,
            top: 10.h,
            child: _HeroIconTile(
              icon: Icons.lunch_dining_rounded,
              color: AppColors.secondary,
              size: 78.w,
            ),
          ),
          Positioned(
            right: 6.w,
            top: 46.h,
            child: _HeroIconTile(
              icon: Icons.local_pizza_rounded,
              color: Colors.white,
              size: 66.w,
            ),
          ),
          Positioned(
            bottom: 18.h,
            left: 40.w,
            child: _HeroIconTile(
              icon: Icons.icecream_rounded,
              color: Colors.white,
              size: 58.w,
            ),
          ),
          Positioned(
            top: -6.h,
            right: 24.w,
            child: const _HeroStat(icon: Icons.star_rounded, label: '4.8 Rating'),
          ),
          Positioned(
            bottom: -4.h,
            right: 0,
            child: const _HeroStat(icon: Icons.delivery_dining_rounded, label: '30 min Delivery'),
          ),
        ],
      ),
    );
  }
}

class _HeroIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _HeroIconTile({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(color == Colors.white ? 0.16 : 1),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color == Colors.white ? Colors.white : AppColors.primaryDark,
      ),
    );
  }
}
