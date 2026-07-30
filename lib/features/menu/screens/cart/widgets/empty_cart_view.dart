import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../shared/widgets/custom_button.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && screenWidth > 600;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(isWeb ? 48 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 48 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: isWeb ? 80 : 60,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: isWeb ? 32 : 24),
            Text(
  AppStrings.get('emptyCart'),
              style: TextStyle(
                fontSize: isWeb ? 28 : 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
  AppStrings.get('addFoodToStart'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            SizedBox(height: isWeb ? 40 : 32),
            SizedBox(
              width: isWeb ? 240 : 200,
              height: isWeb ? 54 : 59,
              child: CustomButton(
  text: AppStrings.get('browseMenu'),
                onPressed: () => context.go(AppRoutes.menu),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
