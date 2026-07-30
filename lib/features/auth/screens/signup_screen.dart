import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import '../../../core/routes/app_routes.dart';
import 'signup/widgets/signup_app_bar.dart';
import 'signup/widgets/signup_large_screen_layout.dart';
import 'signup/widgets/signup_small_screen_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isLargeScreen => MediaQuery.of(context).size.width >= 800;
  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isLargeScreen ? null : const SignupAppBar(),
      body: SafeArea(
        child: _isLargeScreen ? _buildLargeScreenLayout() : _buildSmallScreenLayout(),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return SignupLargeScreenLayout(
      formKey: _formKey,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      phoneController: _phoneController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      onSignUp: _handleSignUp,
    );
  }

  Widget _buildSmallScreenLayout() {
    return SignupSmallScreenLayout(
      isTablet: _isTablet,
      formKey: _formKey,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      phoneController: _phoneController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      onSignUp: _handleSignUp,
    );
  }

  Future<void> _handleSignUp(BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.signUp(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // API returns success with requiresVerification flag
      if (authProvider.requiresVerification) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
    content: Text(AppStrings.get('verificationCodeSent')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to OTP verification screen
        context.go(
          '${AppRoutes.emailVerification}?email=${Uri.encodeComponent(_emailController.text.trim())}',
        );
      } else {
        // Direct login (shouldn't happen with new API, but kept for safety)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
    content: Text(AppStrings.get('accountCreatedSuccess')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        context.go(AppRoutes.home);
      }
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.error ?? AppStrings.failedToCreateAccount,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
