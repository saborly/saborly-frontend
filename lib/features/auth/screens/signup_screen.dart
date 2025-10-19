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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
        onPressed: () => context.pop(),
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
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(60.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
  AppStrings.get('joinApp').replaceAll('{appName}', AppStrings.appName),
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
  AppStrings.get('createAccountDescription'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.textLight,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  _buildFeatureList(),
                ],
              ),
            ),
          ),
          
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
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
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
                        _buildForm(),
                        SizedBox(height: 40.h),
                        _buildSignInLink(),
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
          SizedBox(height: 20.h),
          _buildHeader(),
          SizedBox(height: 32.h),
          _buildForm(),
          SizedBox(height: 32.h),
          _buildSignInLink(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

 Widget _buildFeatureList() {
  final features = [
    AppStrings.get('secureCheckout'),
    AppStrings.get('personalizedRecommendations'),
    AppStrings.get('exclusiveBenefits'),
    AppStrings.get('customerSupport'),
  ];

  return Column(
    children: features.map((feature) => Padding(
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
              feature,
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
        Text(
  AppStrings.get('createAccount'),
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
  AppStrings.get('fillInDetails'),
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
        Text(
  AppStrings.get('createAccount'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
  AppStrings.get('signUpToStart').replaceAll('{appName}', AppStrings.appName),
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
          _buildNameFields(),
          SizedBox(height: 20.h),
          
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
          SizedBox(height: 20.h),
          
          CustomTextField(
            controller: _phoneController,
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
          
          _buildPasswordFields(),
          SizedBox(height: 40.h),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton(
                text: AppStrings.signUp,
                isLoading: authProvider.isLoading,
                onPressed: () => _handleSignUp(context, authProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields() {
    if (_isTablet) {
      return Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _firstNameController,
              labelText: AppStrings.firstName,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterName;
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomTextField(
              controller: _lastNameController,
              labelText: AppStrings.lastName,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterName;
                }
                return null;
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          CustomTextField(
            controller: _firstNameController,
            labelText: AppStrings.firstName,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterName;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _lastNameController,
            labelText: AppStrings.lastName,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterName;
              }
              return null;
            },
          ),
        ],
      );
    }
  }

  Widget _buildPasswordFields() {
    if (_isTablet) {
      return Row(
        children: [
          Expanded(
            child: CustomTextField(
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
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomTextField(
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
          ),
        ],
      );
    } else {
      return Column(
        children: [
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
          SizedBox(height: 16.h),
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

  Widget _buildSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMedium,
          ),
          children: [
             TextSpan(text: AppStrings.alreadyHaveAccount),
            const TextSpan(text: ' '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: Text(
                  AppStrings.signIn,
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