import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared type scale for the premium web homepage sections.
/// Serif (breeSerif) is used for display/heading moments, Manrope for
/// body/UI copy — matching the pairing already used in the existing hero.
class AppTypography {
  static TextStyle display(double size, {Color? color, double height = 1.08}) {
    return GoogleFonts.breeSerif(
      fontSize: size.sp,
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle heading(double size, {Color? color, double height = 1.2}) {
    return GoogleFonts.breeSerif(
      fontSize: size.sp,
      color: color,
      height: height,
      letterSpacing: -0.3,
    );
  }

  static TextStyle kicker(Color color) {
    return GoogleFonts.manrope(
      fontSize: 12.sp,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 1.6,
    );
  }

  static TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w500, double height = 1.5}) {
    return GoogleFonts.manrope(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}
