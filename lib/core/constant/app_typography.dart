import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared type scale for the homepage sections (app and web).
/// Serif (breeSerif) is used for display/heading moments, Manrope for
/// body/UI copy.
class AppTypography {
  /// ScreenUtil scales text against a 1920px-wide design on desktop web, so
  /// on a typical 1366–1536px laptop every size shrinks to ~75% (a 14px dish
  /// name renders at ~10px). Clamp the scaled size so copy stays readable on
  /// laptops without ballooning on very large monitors.
  static double size(double base) => base.sp.clamp(base * 0.92, base * 1.2).toDouble();

  static TextStyle display(double size, {Color? color, double height = 1.08}) {
    return GoogleFonts.breeSerif(
      fontSize: AppTypography.size(size),
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle heading(double size, {Color? color, double height = 1.2}) {
    return GoogleFonts.breeSerif(
      fontSize: AppTypography.size(size),
      color: color,
      height: height,
      letterSpacing: -0.3,
    );
  }

  static TextStyle kicker(Color color, {double size = 12}) {
    return GoogleFonts.manrope(
      fontSize: AppTypography.size(size),
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 1.4,
    );
  }

  static TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w500, double height = 1.5}) {
    return GoogleFonts.manrope(
      fontSize: AppTypography.size(size),
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}
