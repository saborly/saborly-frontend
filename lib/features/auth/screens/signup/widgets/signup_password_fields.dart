import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'package:Saborly/shared/widgets/custom_text_field.dart';

class SignupPasswordFields extends StatefulWidget {
  final bool isTablet;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignupPasswordFields({
    super.key,
    required this.isTablet,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<SignupPasswordFields> createState() => _SignupPasswordFieldsState();
}

class _SignupPasswordFieldsState extends State<SignupPasswordFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,128}$',
  );

  final commonPasswords = [
    'password123',
    'qwerty123',
    '12345678',
    'abc123',
    'admin123'
  ];

  Map<String, bool> _evaluatePassword(String value) {
    return {
      'length': value.length >= 8 && value.length <= 128,
      'uppercase': RegExp(r'[A-Z]').hasMatch(value),
      'lowercase': RegExp(r'[a-z]').hasMatch(value),
      'digit': RegExp(r'\d').hasMatch(value),
      'special': RegExp(r'[@$!%*?&]').hasMatch(value),
      'noSpaces': !value.contains(' '),
      'notCommon': !commonPasswords.contains(value.toLowerCase()),
      'noRepeats': !RegExp(r'(.)\1{3,}').hasMatch(value),
    };
  }

  String _getPasswordStrength(String value) {
    final checks = _evaluatePassword(value);
    final passedChecks = checks.values.where((v) => v).length;

    if (value.isEmpty) return "Empty";
    if (passedChecks <= 3) return "Weak";
    if (passedChecks <= 5) return "Medium";
    return "Strong";
  }

  Widget _buildRequirementText(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 12.sp,
          color: isValid ? Colors.green : Colors.red,
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _passwordStrengthIndicator(String password) {
    final checks = _evaluatePassword(password);
    final strength = _getPasswordStrength(password);
    Color color;
    double progress;
    switch (strength) {
      case "Strong":
        color = Colors.green;
        progress = 1.0;
        break;
      case "Medium":
        color = Colors.orange;
        progress = 0.6;
        break;
      case "Weak":
        color = Colors.red;
        progress = 0.3;
        break;
      default:
        color = Colors.grey;
        progress = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: Colors.grey.shade300,
          minHeight: 5,
          borderRadius: BorderRadius.circular(10),
        ),
        SizedBox(height: 8.h),
        Text(
          "Password Strength: $strength",
          style: TextStyle(fontSize: 12.sp, color: color),
        ),
        SizedBox(height: 8.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequirementText("At least 8 characters", checks['length']!),
            _buildRequirementText("Contains uppercase letter", checks['uppercase']!),
            _buildRequirementText("Contains lowercase letter", checks['lowercase']!),
            _buildRequirementText("Contains a number", checks['digit']!),
            _buildRequirementText("Contains a special character", checks['special']!),
            _buildRequirementText("No spaces allowed", checks['noSpaces']!),
            _buildRequirementText("Not a common password", checks['notCommon']!),
            _buildRequirementText("No repeated characters", checks['noRepeats']!),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: label,
      obscureText: obscureText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        onPressed: toggleVisibility,
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textLight,
        ),
      ),
      validator: validator,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordController = widget.passwordController;
    final confirmPasswordController = widget.confirmPasswordController;

    // --- FIXED TABLET LAYOUT ---
    if (widget.isTablet) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: passwordController,
                      label: AppStrings.password,
                      obscureText: _obscurePassword,
                      toggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.pleaseEnterPassword;
                        }
                        if (value.contains(' ')) {
                          return "Password cannot contain spaces";
                        }
                        if (commonPasswords.contains(value.toLowerCase())) {
                          return "This password is too common";
                        }
                        if (RegExp(r'(.)\1{3,}').hasMatch(value)) {
                          return "Password contains too many repeated characters";
                        }
                        if (value.length > 128) {
                          return "Password is too long (max 128 characters)";
                        }
                        if (!passwordRegex.hasMatch(value)) {
                          return AppStrings.passwordRequirements;
                        }
                        return null;
                      },
                    ),
                    if (passwordController.text.isNotEmpty)
                      _passwordStrengthIndicator(passwordController.text),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildPasswordField(
                  controller: confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
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
              ),
            ],
          ),
        ],
      );
    } else {
      // Mobile layout remains the same
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPasswordField(
            controller: passwordController,
            label: AppStrings.password,
            obscureText: _obscurePassword,
            toggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterPassword;
              }
              if (value.contains(' ')) {
                return "Password cannot contain spaces";
              }
              if (commonPasswords.contains(value.toLowerCase())) {
                return "This password is too common";
              }
              if (RegExp(r'(.)\1{3,}').hasMatch(value)) {
                return "Password contains too many repeated characters";
              }
              if (value.length > 128) {
                return "Password is too long (max 128 characters)";
              }
              if (!passwordRegex.hasMatch(value)) {
                return AppStrings.passwordRequirements;
              }
              return null;
            },
          ),
          if (passwordController.text.isNotEmpty)
            _passwordStrengthIndicator(passwordController.text),
          SizedBox(height: 16.h),
          _buildPasswordField(
            controller: confirmPasswordController,
            label: AppStrings.confirmPassword,
            obscureText: _obscureConfirmPassword,
            toggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
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
