import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import '../../../../../core/routes/app_routes.dart';

void showLoginRequiredDialog(BuildContext context) {
  final isWeb = kIsWeb;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        ),
        contentPadding: EdgeInsets.all(isWeb ? 32 : 24),
        title: Text(
          AppStrings.loginRequired,
          style: TextStyle(
            fontSize: isWeb ? 22 : 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          'Please login to continue with your takeaway order.',
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            color: AppColors.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 24 : 20,
                vertical: isWeb ? 14 : 12,
              ),
            ),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                fontSize: isWeb ? 15 : 14,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Close dialog first
              Navigator.of(dialogContext).pop();

              // Navigate using AppRoutes router
              Future.delayed(const Duration(milliseconds: 50), () {
                AppRoutes.router.go(AppRoutes.login);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 28 : 24,
                vertical: isWeb ? 14 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
              ),
            ),
            child: Text(
              AppStrings.signIn,
              style: TextStyle(
                fontSize: isWeb ? 15 : 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}
