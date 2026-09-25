import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';

/// Round "S" monogram in a brand-gradient ring, optionally followed by the
/// name — marks a video as Saborly's own, like a creator avatar on Reels.
/// (The logo asset is a wide wordmark, so it can't be used in a circle.)
class SaborlyBadge extends StatelessWidget {
  final double size;
  final bool showName;
  final double nameSize;

  const SaborlyBadge({
    super.key,
    this.size = 28,
    this.showName = false,
    this.nameSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final monogram = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary, AppColors.accentBerry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Text(
          'S',
          style: GoogleFonts.breeSerif(
            fontSize: size * 0.52,
            height: 1,
            color: AppColors.primary,
          ),
        ),
      ),
    );

    if (!showName) return monogram;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        monogram,
        SizedBox(width: size * 0.3),
        Text(
          'Saborly',
          style: GoogleFonts.manrope(
            fontSize: nameSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [Shadow(color: Color(0x80000000), blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}
