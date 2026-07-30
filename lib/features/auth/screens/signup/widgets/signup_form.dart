import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import 'package:Saborly/shared/widgets/custom_button.dart';
import 'package:Saborly/shared/widgets/custom_text_field.dart';

import 'signup_name_fields.dart';
import 'signup_password_fields.dart';

class SignupForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isTablet;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final void Function(BuildContext context, AuthProvider authProvider) onSignUp;

  const SignupForm({
    super.key,
    required this.formKey,
    required this.isTablet,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          SignupNameFields(
            isTablet: isTablet,
            firstNameController: firstNameController,
            lastNameController: lastNameController,
          ),
          SizedBox(height: 20.h),

          CustomTextField(
            controller: emailController,
            labelText: AppStrings.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterEmail;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return AppStrings.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),

          CustomTextField(
            controller: phoneController,
            labelText: AppStrings.phoneNumber,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterPhone;
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),

          SignupPasswordFields(
            isTablet: isTablet,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
          ),
          SizedBox(height: 40.h),

          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton(
                text: AppStrings.signUp,
                isLoading: authProvider.isLoading,
                onPressed: () => onSignUp(context, authProvider),
              );
            },
          ),
        ],
      ),
    );
  }
}
