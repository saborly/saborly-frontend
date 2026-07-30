import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';

/// Web hero: light card on the left (badge, headline with colored accent
/// words, subtext, CTAs) and a dark stat panel bleeding in from the right
/// with a centered dish icon — mirrors the mobile hero's copy/stats but in
/// a wide desktop layout.
class WebHeroSection extends StatelessWidget {
  final VoidCallback onOrderNow;
  final VoidCallback onViewOffers;

  const WebHeroSection({
    super.key,
    required this.onOrderNow,
    required this.onViewOffers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 380.h),
      decoration: BoxDecoration(
        color: AppColors.premiumAccent,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: Stack(
          children: [
            // Dark panel bleeding in from the right, curved on the left edge.
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: FractionallySizedBox(
                heightFactor: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxHeight * 1.15,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(220.r)),
                      ),
                      child: _buildDarkPanel(),
                    );
                  },
                ),
              ),
            ),

            // Left light content.
            Padding(
              padding: EdgeInsets.fromLTRB(48.w, 44.h, 0, 44.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.52,
                  child: _buildLeft(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.35),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded, size: 15.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'FRESH BURGERS, BOLD DEALS',
                style: GoogleFonts.manrope(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),

        RichText(
          text: TextSpan(
            style: GoogleFonts.breeSerif(fontSize: 40.sp, height: 1.18, color: AppColors.textDark),
            children: [
              const TextSpan(text: 'Crave-worthy meals made to feel '),
              TextSpan(text: 'fast, ', style: TextStyle(color: AppColors.primary)),
              TextSpan(text: 'warm', style: TextStyle(color: AppColors.primary)),
              const TextSpan(text: ', and '),
              TextSpan(text: 'premium.', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        Text(
          'Browse favorites, jump into offers, and order in a cleaner experience across web and mobile.',
          style: GoogleFonts.manrope(fontSize: 15.sp, height: 1.5, color: AppColors.muted, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 28.h),

        Wrap(
          spacing: 14.w,
          runSpacing: 12.h,
          children: [
            _PrimaryCta(label: 'Order Now', onTap: onOrderNow),
            _SecondaryCta(label: 'View Offers', onTap: onViewOffers),
          ],
        ),
      ],
    );
  }

  Widget _buildDarkPanel() {
    return Stack(
      children: [
        Positioned(
          top: 60.h,
          left: 40.w,
          child: Icon(Icons.local_fire_department_rounded, size: 40.sp, color: Colors.white.withOpacity(0.14)),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: 140.w),
            child: Container(
              width: 190.w,
              height: 190.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.secondary.withOpacity(0.35), Colors.transparent]),
              ),
              child: Icon(Icons.lunch_dining_rounded, size: 110.sp, color: Colors.white.withOpacity(0.92)),
            ),
          ),
        ),
        Positioned(
          right: 24.w,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.center,
            child: _StatPanel(),
          ),
        ),
      ],
    );
  }
}

class _StatPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _statRow(Icons.star_rounded, '4.8', 'Average rating'),
          _divider(),
          _statRow(Icons.timer_outlined, '30 min', 'Average delivery'),
          _divider(),
          _statRow(Icons.restaurant_menu_rounded, '150+', 'Dishes to explore'),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, margin: EdgeInsets.symmetric(horizontal: 16.w), color: Colors.white.withOpacity(0.10));

  Widget _statRow(IconData icon, String value, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: GoogleFonts.breeSerif(fontSize: 18.sp, color: Colors.white, height: 1.1)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 11.sp, color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryCta({required this.label, required this.onTap});

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h).copyWith(left: 24.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: _hovering
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label, style: GoogleFonts.manrope(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w800)),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward_rounded, size: 16.sp, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryCta extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryCta({required this.label, required this.onTap});

  @override
  State<_SecondaryCta> createState() => _SecondaryCtaState();
}

class _SecondaryCtaState extends State<_SecondaryCta> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: _hovering ? AppColors.primary.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.4),
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label, style: GoogleFonts.manrope(fontSize: 15.sp, color: AppColors.primary, fontWeight: FontWeight.w800)),
              SizedBox(width: 8.w),
              Icon(Icons.local_offer_outlined, size: 16.sp, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
