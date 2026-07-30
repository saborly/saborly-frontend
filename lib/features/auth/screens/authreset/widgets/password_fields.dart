import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/shared/widgets/custom_text_field.dart';

class PasswordFields extends StatelessWidget {
  final bool isTablet;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const PasswordFields({
    super.key,
    required this.isTablet,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child:
         CustomTextField(
  controller: passwordController,
  labelText: AppStrings.get('newPassword'),
  obscureText: obscurePassword,
  prefixIcon: Icons.lock_outline,
  suffixIcon: IconButton(
    onPressed: onTogglePassword,
    icon: Icon(
      obscurePassword ? Icons.visibility_off : Icons.visibility,
      color: AppColors.textLight,
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return AppStrings.get('pleaseEnterPassword');
    }
    if (value.length < 8) {
      return AppStrings.get('passwordMinLength8Error');
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
      return AppStrings.get('passwordSecurityError');
    }
    return null;
  },
), ),
          SizedBox(width: 16.w),
          Expanded(
            child:
        CustomTextField(
  controller: confirmPasswordController,
  labelText: AppStrings.get('confirmPassword'),
  obscureText: obscureConfirmPassword,
  prefixIcon: Icons.lock_outline,
  suffixIcon: IconButton(
    onPressed: onToggleConfirmPassword,
    icon: Icon(
      obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
      color: AppColors.textLight,
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return AppStrings.get('pleaseEnterPassword');
    }
    if (value != passwordController.text) {
      return AppStrings.get('passwordsDontMatch');
    }
    return null;
  },
), ),
        ],
      );
    } else {
      return Column(
        children: [
          CustomTextField(
            controller: passwordController,
            labelText: AppStrings.newPassword,
            obscureText: obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textLight,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterPassword;
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
                return 'Password must meet security requirements';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            controller: confirmPasswordController,
            labelText: AppStrings.confirmPassword,
            obscureText: obscureConfirmPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textLight,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterPassword;
              }
              if (value != passwordController.text) {
                return AppStrings.passwordsDontMatch;
              }
              return null;
            },
          ),
        ],
      );
    }
  }
}
