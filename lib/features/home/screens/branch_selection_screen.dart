import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/geolocation_service.dart';

// ─────────────────────────────────────────────────────────────
// Branch coordinates
// ─────────────────────────────────────────────────────────────
const _barcelonaLat = 41.3851;
const _barcelonaLng = 2.1734;
const _sabadellLat = 41.5433;
const _sabadellLng = 2.1093;

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class BranchSelectionScreen extends StatefulWidget {
  const BranchSelectionScreen({super.key});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen>
    with SingleTickerProviderStateMixin {
  // 0 = Barcelona, 1 = Sabadell, null = none
  int? _nearestBranchIndex;
  bool _isDetectingLocation = true;

  // Subtle pulse animation for the pre-selected card
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.028).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _detectLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Geolocation ────────────────────────────────────────────
  Future<void> _detectLocation() async {
    if (!kIsWeb) {
      if (mounted) setState(() => _isDetectingLocation = false);
      return;
    }

    try {
      final coords = await detectUserLocation();
      if (!mounted) return;

      if (coords != null) {
        final distBarcelona = _haversine(
          coords['lat']!, coords['lng']!,
          _barcelonaLat, _barcelonaLng,
        );
        final distSabadell = _haversine(
          coords['lat']!, coords['lng']!,
          _sabadellLat, _sabadellLng,
        );
        setState(() {
          _nearestBranchIndex = distBarcelona <= distSabadell ? 0 : 1;
          _isDetectingLocation = false;
        });
      } else {
        setState(() => _isDetectingLocation = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double deg) => deg * math.pi / 180;

  // ── Navigation / interactions ───────────────────────────────
  void _onSelectBranch(int index) {
    if (index == 0) {
      // Barcelona — go to main app
      context.go('/home');
    } else {
      // Sabadell — show "Coming Soon" modal, no navigation
      _showComingSoonModal();
    }
  }

  void _showComingSoonModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _ComingSoonDialog(
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Soft gradient background ──────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF0F6),
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Decorative blobs ─────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: _GradientBlob(
              size: isWide ? 360 : 240,
              color: AppColors.primary.withOpacity(0.07),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _GradientBlob(
              size: isWide ? 280 : 200,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),

          // ── Main scroll content ───────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80.w : 24.w,
                    vertical: 40.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo ────────────────────────────
                      Image.asset(
                        'assets/images/logo3.png',
                        height: 56.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 44.h),

                      // ── Heading ─────────────────────────
                      Text(
                        'Choose Your Branch',
                        style: GoogleFonts.poppins(
                          fontSize: isWide ? 38.sp : 26.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),

                      // ── Sub-heading (changes with location state) ─
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _isDetectingLocation
                            ? Row(
                                key: const ValueKey('detecting'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              AppColors.primary),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Detecting your location…',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                key: const ValueKey('hint'),
                                _nearestBranchIndex != null
                                    ? '📍 We\'ve highlighted your nearest branch'
                                    : 'Select the branch you\'d like to order from',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: AppColors.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),

                      SizedBox(height: 52.h),

                      // ── Branch cards ─────────────────────
                      isWide
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 420),
                                    child: _buildBarcelonaCard(),
                                  ),
                                ),
                                SizedBox(width: 28.w),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 420),
                                    child: _buildSabadellCard(),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildBarcelonaCard(),
                                SizedBox(height: 20.h),
                                _buildSabadellCard(),
                              ],
                            ),

                      SizedBox(height: 52.h),

                      // ── Footer ───────────────────────────
                      Text(
                        '© ${DateTime.now().year} Saborly · Delivering happiness to your door',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card builders ───────────────────────────────────────────
  Widget _buildBarcelonaCard() {
    final isNearest = _nearestBranchIndex == 0;
    return _BranchCard(
      name: 'Barcelona',
      subtitle: 'Gràcia · Barcelona',
      address: 'C/ Còrsega 183, 08036 Barcelona',
      iconData: Icons.location_city_rounded,
      isNearest: isNearest,
      isComingSoon: false,
      onTap: () => _onSelectBranch(0),
      pulseAnimation: isNearest ? _pulseAnimation : null,
    );
  }

  Widget _buildSabadellCard() {
    final isNearest = _nearestBranchIndex == 1;
    return _BranchCard(
      name: 'Sabadell',
      subtitle: 'Sabadell · Barcelona',
      address: 'Opening soon — stay tuned!',
      iconData: Icons.storefront_rounded,
      isNearest: isNearest,
      isComingSoon: true,
      onTap: () => _onSelectBranch(1),
      pulseAnimation: null, // Never pulse for coming soon
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Branch card widget
// ─────────────────────────────────────────────────────────────
class _BranchCard extends StatefulWidget {
  final String name;
  final String subtitle;
  final String address;
  final IconData iconData;
  final bool isNearest;
  final bool isComingSoon;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  const _BranchCard({
    required this.name,
    required this.subtitle,
    required this.address,
    required this.iconData,
    required this.isNearest,
    required this.isComingSoon,
    required this.onTap,
    this.pulseAnimation,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: widget.isNearest
                  ? AppColors.primary
                  : widget.isComingSoon
                      ? const Color(0xFFE0E0E0)
                      : (_hovered
                          ? AppColors.primary.withOpacity(0.5)
                          : const Color(0xFFE8E8E8)),
              width: widget.isNearest ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isNearest
                    ? AppColors.primary.withOpacity(_hovered ? 0.22 : 0.14)
                    : Colors.black
                        .withOpacity(_hovered && !widget.isComingSoon
                            ? 0.10
                            : 0.06),
                blurRadius: widget.isNearest ? 24 : (_hovered ? 18 : 12),
                spreadRadius: widget.isNearest ? 2 : 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row: icon + badges ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: widget.isComingSoon
                          ? const Color(0xFFF5F5F5)
                          : AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      widget.iconData,
                      size: 30.sp,
                      color: widget.isComingSoon
                          ? const Color(0xFFBDBDBD)
                          : AppColors.primary,
                    ),
                  ),

                  // Badge column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.isNearest && !widget.isComingSoon)
                        _Pill(
                          text: '📍 Nearest to you',
                          bgColor: AppColors.primary.withOpacity(0.10),
                          textColor: AppColors.primary,
                        ),
                      if (widget.isComingSoon) ...[
                        _Pill(
                          text: '🚧 Coming Soon',
                          bgColor: const Color(0xFFFFF3E0),
                          textColor: const Color(0xFFE65100),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              SizedBox(height: 22.h),

              // ── Branch name ───────────────────────────────
              Text(
                widget.name,
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.isComingSoon
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),

              SizedBox(height: 10.h),

              // ── Address row ───────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 13.sp,
                    color: const Color(0xFFBDBDBD),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFFBDBDBD),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // ── Divider ───────────────────────────────────
              const Divider(color: Color(0xFFF2F2F2), thickness: 1, height: 1),

              SizedBox(height: 20.h),

              // ── Footer row: status + CTA ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status indicator
                  if (!widget.isComingSoon)
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Open Now',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB74D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Coming soon',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),

                  // CTA button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 18.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: widget.isComingSoon
                          ? const Color(0xFFF5F5F5)
                          : (_hovered
                              ? AppColors.primaryDark
                              : AppColors.primary),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: widget.isComingSoon
                          ? []
                          : [
                              BoxShadow(
                                color:
                                    AppColors.primary.withOpacity(0.30),
                                blurRadius: _hovered ? 12 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isComingSoon ? 'Learn more' : 'Order now',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: widget.isComingSoon
                                ? const Color(0xFF9E9E9E)
                                : Colors.white,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14.sp,
                          color: widget.isComingSoon
                              ? const Color(0xFF9E9E9E)
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap nearest card in pulse animation
    if (widget.pulseAnimation != null) {
      return AnimatedBuilder(
        animation: widget.pulseAnimation!,
        builder: (context, child) => Transform.scale(
          scale: widget.pulseAnimation!.value,
          child: child,
        ),
        child: card,
      );
    }

    return card;
  }
}

// ─────────────────────────────────────────────────────────────
// Coming Soon dialog
// ─────────────────────────────────────────────────────────────
class _ComingSoonDialog extends StatelessWidget {
  final VoidCallback onDismiss;
  const _ComingSoonDialog({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction_rounded,
                size: 44.sp,
                color: const Color(0xFFFF9800),
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              'Coming Soon to Sabadell!',
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 14.h),

            // Body
            Text(
              'We\'re working hard to bring Saborly\'s delicious food to Sabadell. '
              'Our team is setting up the branch and we\'ll be ready very soon!',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.textLight,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),

            // Coming soon chip
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: const Color(0xFFFFCC80), width: 1.2),
              ),
              child: Text(
                '🗓️  Expected opening: Coming soon',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE65100),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Dismiss button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Text(
                  'Got it, thanks!',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Order from Barcelona instead
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              child: Text(
                'Order from Barcelona instead →',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _Pill({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GradientBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
