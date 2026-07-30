import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
  text: AppStrings.get('signInNow'),
        onPressed: () => context.go(AppRoutes.login),
      ),
    );
  }
}
