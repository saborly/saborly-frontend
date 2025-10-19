import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 60, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  static EdgeInsets getContentPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Responsive grid columns
  static int getGridCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    if (isDesktop(context)) return desktop ?? 4;
    if (isTablet(context)) return tablet ?? 3;
    return mobile ?? 2;
  }

  // Responsive font sizes
  static double getFontSize(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) return desktop ?? (mobile * 1.2);
    if (isTablet(context)) return tablet ?? (mobile * 1.1);
    return mobile;
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) return desktop ?? (mobile * 1.5);
    if (isTablet(context)) return tablet ?? (mobile * 1.25);
    return mobile;
  }

  // Card width for web
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) {
      return (screenWidth - 240) / 4 - 16; // 4 columns with margins
    } else if (isTablet(context)) {
      return (screenWidth - 120) / 3 - 16; // 3 columns with margins
    } else {
      return (screenWidth - 32) / 2 - 8; // 2 columns with margins
    }
  }

  // Container constraints for web
  static BoxConstraints getContainerConstraints(BuildContext context) {
    if (isDesktop(context)) {
      return const BoxConstraints(maxWidth: 1200);
    } else if (isTablet(context)) {
      return const BoxConstraints(maxWidth: 800);
    } else {
      return const BoxConstraints(maxWidth: double.infinity);
    }
  }

  // Layout type
  static LayoutType getLayoutType(BuildContext context) {
    final width = getScreenWidth(context);
    if (width >= desktopBreakpoint) return LayoutType.desktop;
    if (width >= tabletBreakpoint) return LayoutType.tablet;
    return LayoutType.mobile;
  }
}

enum LayoutType {
  mobile,
  tablet,
  desktop,
}

// Responsive wrapper widget
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 
            (ResponsiveUtils.isDesktop(context) 
              ? 1200 
              : ResponsiveUtils.isTablet(context) 
                ? 800 
                : double.infinity),
        ),
        child: child,
      ),
    );
  }
}

// Responsive grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridCrossAxisCount(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: ResponsiveUtils.isDesktop(context) ? 0.8 : 0.75,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}