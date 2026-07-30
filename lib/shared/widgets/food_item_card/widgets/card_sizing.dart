import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CardSize {
  extraSmall,
  small,
  medium,
  large,
}

/// Shared responsive-sizing helpers for the food item card and its
/// extracted sub-widgets. Extracted verbatim from `food_item_card.dart`
/// so behavior/output is unchanged.
class CardSizing {
  CardSizing._();

  static double getResponsiveValue({
    required double mobile,
    required double tablet,
    required double desktop,
    required double screenWidth,
  }) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 600) return tablet;
    return mobile;
  }

  static bool useCompactFooter(CardSize cardSize) {
    return cardSize == CardSize.extraSmall || cardSize == CardSize.small;
  }

  static double getBorderRadius(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 18,
      tablet: 20,
      desktop: 22,
      screenWidth: screenWidth,
    ).r;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(8.0, 12.0);
      case CardSize.small:
        return base.clamp(10.0, 14.0);
      case CardSize.medium:
        return (base * 1.1).clamp(12.0, 16.0);
      case CardSize.large:
        return (base * 1.2).clamp(14.0, 18.0);
    }
  }

  static double getPadding(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 10,
      tablet: 12,
      desktop: 14,
      screenWidth: screenWidth,
    ).w;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(6.0, 8.0);
      case CardSize.small:
        return (base * 0.75).clamp(8.0, 10.0);
      case CardSize.medium:
        return base.clamp(10.0, 12.0);
      case CardSize.large:
        return (base * 1.15).clamp(12.0, 14.0);
    }
  }

  static double getSmallPadding(CardSize cardSize, double screenWidth) {
    return getPadding(cardSize, screenWidth) * 0.4;
  }

  static double getSpacing(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 4,
      tablet: 6,
      desktop: 8,
      screenWidth: screenWidth,
    ).h;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.7).clamp(3.0, 4.0);
      case CardSize.small:
        return (base * 0.85).clamp(4.0, 6.0);
      case CardSize.medium:
        return base.clamp(6.0, 8.0);
      case CardSize.large:
        return (base * 1.15).clamp(5.0, 7.0);
    }
  }

  static double getTitleFontSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 14,
      tablet: 17,
      desktop: 18,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.82).clamp(12.5, 13.5);
      case CardSize.small:
        return (base * 0.9).clamp(14.0, 15.0);
      case CardSize.medium:
        return base.clamp(15.0, 17.0);
      case CardSize.large:
        return (base * 1.05).clamp(16.0, 18.0);
    }
  }

  static double getDescriptionFontSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 12,
      tablet: 14,
      desktop: 15,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.85).clamp(10.5, 11.5);
      case CardSize.small:
        return (base * 0.9).clamp(11.0, 12.0);
      case CardSize.medium:
        return base.clamp(12.0, 14.0);
      case CardSize.large:
        return (base * 1.1).clamp(13.0, 15.0);
    }
  }

  static double getPriceFontSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 14,
      tablet: 16,
      desktop: 17,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.92).clamp(12.5, 14.0);
      case CardSize.small:
        return (base * 0.98).clamp(13.5, 15.0);
      case CardSize.medium:
        return base.clamp(14.0, 17.0);
      case CardSize.large:
        return (base * 1.03).clamp(15.0, 18.0);
    }
  }

  static double getButtonFontSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 14,
      tablet: 15,
      desktop: 16,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.85).clamp(11.0, 12.0);
      case CardSize.small:
        return (base * 0.92).clamp(12.0, 13.0);
      case CardSize.medium:
        return base.clamp(13.0, 15.0);
      case CardSize.large:
        return (base * 1.03).clamp(14.0, 16.0);
    }
  }

  static double getSmallFontSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 11,
      tablet: 12,
      desktop: 13,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.9).clamp(9.5, 10.5);
      case CardSize.small:
        return (base * 0.96).clamp(10.0, 11.0);
      case CardSize.medium:
        return base.clamp(11.0, 13.0);
      case CardSize.large:
        return (base * 1.02).clamp(11.5, 13.5);
    }
  }

  static double getIconSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 20,
      tablet: 22,
      desktop: 24,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(16.0, 20.0);
      case CardSize.small:
        return (base * 0.9).clamp(18.0, 22.0);
      case CardSize.medium:
        return base.clamp(20.0, 24.0);
      case CardSize.large:
        return (base * 1.1).clamp(22.0, 26.0);
    }
  }

  static double getSmallIconSize(CardSize cardSize, double screenWidth) {
    final base = getResponsiveValue(
      mobile: 10,
      tablet: 11,
      desktop: 12,
      screenWidth: screenWidth,
    ).sp;
    switch (cardSize) {
      case CardSize.extraSmall:
        return (base * 0.8).clamp(8.0, 10.0);
      case CardSize.small:
        return (base * 0.9).clamp(9.0, 11.0);
      case CardSize.medium:
        return base.clamp(10.0, 12.0);
      case CardSize.large:
        return (base * 1.1).clamp(11.0, 13.0);
    }
  }
}
