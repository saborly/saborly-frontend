// lib/features/auth/screens/login_screen.dart - FIXED

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';
import 'package:Saborly/shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 500 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 40.w : 24.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isLargeScreen ? 40.h : 20.h),
                  
                  // Header
                  _buildHeader(isLargeScreen),
                  SizedBox(height: isLargeScreen ? 60.h : 40.h),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        CustomTextField(
                          controller: _emailController,
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
                        SizedBox(height: isLargeScreen ? 24.h : 16.h),
                        
                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          labelText: AppStrings.password,
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
                            if (value.length < 6) {
                              return AppStrings.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.h),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.go(AppRoutes.forgotPassword);
                            },
                            child: Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 32.h : 24.h),
                        
                        // Sign In Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return CustomButton(
                              text: AppStrings.signIn,
                              isLoading: authProvider.isLoading,
                              onPressed: () => _handleSignIn(context, authProvider),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isLargeScreen ? 40.h : 30.h),
                  
                  // Divider with "OR"
                  _buildDivider(),
                  SizedBox(height: isLargeScreen ? 40.h : 30.h),
                  
                  // Social Login Buttons
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return _buildSocialButton(
                        onPressed: authProvider.isLoading 
                          ? null 
                          : () => _handleGoogleSignIn(context, authProvider),
                        label: 'Continue with Google',
                        isLoading: authProvider.isLoading && authProvider.isSocialLoading,
                      );
                    },
                  ),
                  
                  SizedBox(height: isLargeScreen ? 60.h : 40.h),
                  
                  // Sign Up Link
                  _buildSignUpLink(),
                  SizedBox(height: isLargeScreen ? 60.h : 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('welcomeBack'),
          style: TextStyle(
            fontSize: isLargeScreen ? 18.sp : 16.sp,
            color: AppColors.textLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textLight.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textLight.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }


// Alternative simpler version if the CustomPaint is too complex:
Widget _buildSocialButton({
  required VoidCallback? onPressed,
  required String label,
  bool isLoading = false,
}) {
  return Container(
    height: 56.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textLight.withOpacity(0.15),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4285F4),
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Logo Image
                    Image.network(
                      'https://www.pngfind.com/pngs/m/84-847501_contact-us-google-app-logo-transparent-hd-png.png',
                      width: 20.w,
                      height: 20.h,
                    
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}
  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMedium,
          ),
          children: [
            TextSpan(text: AppStrings.dontHaveAccount),
            const TextSpan(text: ' '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.signup),
                child: Text(
                  AppStrings.signUp,
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

  Future<void> _handleSignIn(BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? AppStrings.failedToLogin),
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

  Future<void> _handleGoogleSignIn(BuildContext context, AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();

    if (success) {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Google sign-in failed'),
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
 