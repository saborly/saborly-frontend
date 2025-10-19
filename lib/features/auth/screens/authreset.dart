import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/auth_proveder.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

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
      appBar: _isLargeScreen ? null : _buildAppBar(),
      body: SafeArea(
        child: _isLargeScreen ? _buildLargeScreenLayout() : _buildSmallScreenLayout(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go(AppRoutes.login),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20.sp,
        ),
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
                    _buildPasswordRequirements(),
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
                        _buildFormHeader(),
                        SizedBox(height: 40.h),
                        _passwordReset ? _buildSuccessContent() : _buildForm(),
                        SizedBox(height: 40.h),
                        if (_passwordReset) _buildSignInButton(),
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
          _buildHeader(),
          SizedBox(height: 40.h),
          _passwordReset ? _buildSuccessContent() : _buildForm(),
          SizedBox(height: 32.h),
          if (_passwordReset) _buildSignInButton(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
   final requirements = [
    AppStrings.get('passwordMinLength8'),
    AppStrings.get('passwordUpperLower'),
    AppStrings.get('passwordNumber'),
    AppStrings.get('passwordSpecialChar'),
  ];

    return Column(
      children: requirements.map((requirement) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.check,
                color: AppColors.primary,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                requirement,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: _passwordReset 
              ? Colors.green.withOpacity(0.1) 
              : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            _passwordReset ? Icons.check_circle : Icons.security,
            color: _passwordReset ? Colors.green : AppColors.primary,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
  _passwordReset ? AppStrings.get('passwordUpdated') : AppStrings.get('resetPassword'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _isLargeScreen ? 32.sp : 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
         _passwordReset 
    ? AppStrings.get('passwordChanged')
    : AppStrings.get('createStrongPassword'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: _passwordReset 
              ? Colors.green.withOpacity(0.1) 
              : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            _passwordReset ? Icons.check_circle : Icons.security,
            color: _passwordReset ? Colors.green : AppColors.primary,
            size: 32.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
  _passwordReset ? AppStrings.get('passwordUpdated') : AppStrings.get('resetPassword'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
           _passwordReset 
    ? AppStrings.get('passwordChanged')
    : AppStrings.get('createStrongPassword'),
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Password Fields - Responsive layout
          _buildPasswordFields(),
          SizedBox(height: 32.h),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton(
  text: AppStrings.get('updatePassword'),
                isLoading: authProvider.isLoading,
                onPressed: () => _handleResetPassword(context, authProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    if (_isTablet) {
      return Row(
        children: [
          Expanded(
            child:
         CustomTextField(
  controller: _passwordController,
  labelText: AppStrings.get('newPassword'),
  obscureText: _obscurePassword,
  prefixIcon: Icons.lock_outline,
  suffixIcon: IconButton(
    onPressed: () {
      setState(() {
        _obscurePassword = !_obscurePassword;
      });
    },
    icon: Icon(
      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
  controller: _confirmPasswordController,
  labelText: AppStrings.get('confirmPassword'),
  obscureText: _obscureConfirmPassword,
  prefixIcon: Icons.lock_outline,
  suffixIcon: IconButton(
    onPressed: () {
      setState(() {
        _obscureConfirmPassword = !_obscureConfirmPassword;
      });
    },
    icon: Icon(
      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
      color: AppColors.textLight,
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return AppStrings.get('pleaseEnterPassword');
    }
    if (value != _passwordController.text) {
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
            controller: _passwordController,
            labelText: AppStrings.newPassword,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
            controller: _confirmPasswordController,
            labelText: AppStrings.confirmPassword,
            obscureText: _obscureConfirmPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textLight,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterPassword;
              }
              if (value != _passwordController.text) {
                return AppStrings.passwordsDontMatch;
              }
              return null;
            },
          ),
        ],
      );
    }
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
  AppStrings.get('passwordResetSuccess'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
  AppStrings.get('passwordResetSuccessDescription'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        
        // Security tip
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
  AppStrings.get('passwordSecurityTip'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
  text: AppStrings.get('signInNow'),
        onPressed: () => context.go(AppRoutes.login),
      ),
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