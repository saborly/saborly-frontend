import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import 'signup_form.dart';
import 'signup_header.dart';
import 'signup_sign_in_link.dart';

class SignupSmallScreenLayout extends StatelessWidget {
  final bool isTablet;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final void Function(BuildContext context, AuthProvider authProvider) onSignUp;

  const SignupSmallScreenLayout({
    super.key,
    required this.isTablet,
    required this.formKey,
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.w : 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          const SignupHeader(),
          SizedBox(height: 32.h),
          SignupForm(
            formKey: formKey,
            isTablet: isTablet,
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            emailController: emailController,
            phoneController: phoneController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            onSignUp: onSignUp,
          ),
          SizedBox(height: 32.h),
          const SignupSignInLink(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
