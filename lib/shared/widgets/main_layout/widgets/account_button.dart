import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildAccountButton.
class AccountButtonWidget extends StatelessWidget {
  final bool isTablet;

  const AccountButtonWidget({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0
    );
    final iconSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 17.0,
      desktop: 18.0
    );
    final fontSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 13.0,
      desktop: 14.0
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.profile),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 10
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.85)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: iconSize
              ),
              SizedBox(width: 6),
              Text(
                AppStrings.get('account'),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
