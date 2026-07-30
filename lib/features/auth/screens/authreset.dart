import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import '../../../core/routes/app_routes.dart';
import 'authreset/widgets/authreset_app_bar.dart';
import 'authreset/widgets/password_requirements_list.dart';
import 'authreset/widgets/reset_form_header.dart';
import 'authreset/widgets/reset_header.dart';
import 'authreset/widgets/reset_password_form.dart';
import 'authreset/widgets/reset_success_content.dart';
import 'authreset/widgets/sign_in_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token; // Reset token from email link

  const ResetPasswordScreen({super.key, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordReset = false;

  @override
  void dispose() {
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
      appBar: _isLargeScreen ? null : const AuthResetAppBar(),
      body: SafeArea(
        child: _isLargeScreen ? _buildLargeScreenLayout() : _buildSmallScreenLayout(),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            Colors.white,
            AppColors.primary.withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        children: [
          // Left side - Branding/Image section
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(60.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Logo or Icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      _passwordReset ? Icons.check_circle : Icons.security,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
  _passwordReset ? AppStrings.get('allSet') : AppStrings.get('createNewPassword'),
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    _passwordReset
                      ? AppStrings.get('passwordUpdatedDescription')
    : AppStrings.get('newPasswordRequirements'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.textLight,
                      height: 1.6,
                    ),
                  ),
                  if (!_passwordReset) ...[
                    SizedBox(height: 60.h),
                    const PasswordRequirementsList(),
                  ],
                ],
              ),
            ),
          ),

          // Right side - Form section
          Expanded(
            flex: 4,
            child: Container(
              constraints: BoxConstraints(maxWidth: 500.w),
              child: Card(
                margin: EdgeInsets.all(40.w),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(48.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Back button for large screens
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go(AppRoutes.login),
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.textDark,
                                size: 24.sp,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        ResetFormHeader(
                          passwordReset: _passwordReset,
                          isLargeScreen: _isLargeScreen,
                        ),
                        SizedBox(height: 40.h),
                        _passwordReset ? const ResetSuccessContent() : _buildForm(),
                        SizedBox(height: 40.h),
                        if (_passwordReset) const SignInButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: _isTablet ? 48.w : 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          ResetHeader(passwordReset: _passwordReset),
          SizedBox(height: 40.h),
          _passwordReset ? const ResetSuccessContent() : _buildForm(),
          SizedBox(height: 32.h),
          if (_passwordReset) const SignInButton(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ResetPasswordForm(
      formKey: _formKey,
      isTablet: _isTablet,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      obscurePassword: _obscurePassword,
      obscureConfirmPassword: _obscureConfirmPassword,
      onTogglePassword: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      onToggleConfirmPassword: () {
        setState(() {
          _obscureConfirmPassword = !_obscureConfirmPassword;
        });
      },
      onSubmit: _handleResetPassword,
    );
  }

  Future<void> _handleResetPassword(BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Simulate API call - replace with actual implementation
      // await authProvider.resetPassword(widget.token, _passwordController.text);
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _passwordReset = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
      content: Text(AppStrings.get('passwordUpdatedSuccess')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
      content: Text(AppStrings.get('passwordResetFailed')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }
}
