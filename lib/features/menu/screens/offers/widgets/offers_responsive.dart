import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared responsive breakpoint helpers for the Offers screen and its
/// extracted widgets. Extracted verbatim from OffersScreen to keep all
/// layout math identical across the split widgets.
class OffersResponsive {
  OffersResponsive._();

  static bool isMobile(double width) => width < 600;
  static bool isTablet(double width) => width >= 600 && width < 1000;

  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1280;
    if (screenWidth >= 1000) return screenWidth * 0.88;
    return screenWidth;
  }

  static double getHorizontalPadding(double screenWidth) {
    if (isMobile(screenWidth)) return 16.w;
    if (isTablet(screenWidth)) return 32.w;
    return 48.w;
  }

  static int getCrossAxisCount(double screenWidth) {
    if (screenWidth < 500) return 1;
    if (screenWidth < 800) return 3;
    if (screenWidth < 1200) return 4;
    return 5;
  }

  static double getChildAspectRatio(double screenWidth) {
    if (isMobile(screenWidth)) return 1.10;
    if (isTablet(screenWidth)) return 0.75;
    return 0.78;
  }
}
