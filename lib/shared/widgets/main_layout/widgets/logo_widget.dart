import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildLogo.
class LogoWidget extends StatelessWidget {
  final bool isTablet;

  const LogoWidget({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final logoWidth = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 100.0,
      tablet: 120.0,
      desktop: 140.0
    );
    final logoHeight = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 45.0,
      desktop: 50.0
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 4.0,
          tablet: 6.0,
          desktop: 10.0
        ),
      ),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.home),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: logoWidth,
          height: logoHeight,
          child: Image.asset(
            'assets/images/logo3.png',
            fit: BoxFit.contain,
            semanticLabel: AppStrings.get('appLogo'),
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
