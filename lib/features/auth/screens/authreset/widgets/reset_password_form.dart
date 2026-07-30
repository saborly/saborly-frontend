import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';

import 'password_fields.dart';

class ResetPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isTablet;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final void Function(BuildContext context, AuthProvider authProvider) onSubmit;

  const ResetPasswordForm({
    super.key,
    required this.formKey,
    required this.isTablet,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Password Fields - Responsive layout
          PasswordFields(
            isTablet: isTablet,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            obscurePassword: obscurePassword,
            obscureConfirmPassword: obscureConfirmPassword,
            onTogglePassword: onTogglePassword,
            onToggleConfirmPassword: onToggleConfirmPassword,
          ),
          SizedBox(height: 32.h),

          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton(
  text: AppStrings.get('updatePassword'),
                isLoading: authProvider.isLoading,
                onPressed: () => onSubmit(context, authProvider),
              );
            },
          ),
        ],
      ),
    );
  }
}
