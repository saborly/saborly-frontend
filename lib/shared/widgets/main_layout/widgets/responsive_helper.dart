import 'package:flutter/material.dart';

/// Shared responsive-value helper extracted from MainLayout so the new
/// widget files can compute the same mobile/tablet/desktop breakpoints
/// without depending on the private State class.
class ResponsiveHelper {
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }
}
