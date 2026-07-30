import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'package:Saborly/core/routes/app_routes.dart';

class SignupSignInLink extends StatelessWidget {
  const SignupSignInLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMedium,
          ),
          children: [
             TextSpan(text: AppStrings.alreadyHaveAccount),
            const TextSpan(text: ' '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: Text(
                  AppStrings.signIn,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
