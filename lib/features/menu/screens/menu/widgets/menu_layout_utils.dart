/// Shared layout helper calculations for the menu screen and its widgets.
///
/// Extracted verbatim from `menu_screen.dart` (`_getCrossAxisCount` /
/// `_getMaxContentWidth`) so multiple sliver widgets can share the exact
/// same responsive logic without duplicating it.
class MenuLayoutUtils {
  MenuLayoutUtils._();

  static int getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1600) return 5;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 900) return 3;
    if (screenWidth >= 600) return 2;
    return 1; // phones: bigger cards
  }

  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1400;
    if (screenWidth >= 1200) return 1200;
    return screenWidth * 0.95;
  }
}
