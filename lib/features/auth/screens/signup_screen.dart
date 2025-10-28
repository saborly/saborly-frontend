import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

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

Widget _buildPasswordFields() {
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

  // --- FIXED TABLET LAYOUT ---
  if (_isTablet) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildPasswordField(
                    controller: _passwordController,
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
                  if (_passwordController.text.isNotEmpty)
                    _passwordStrengthIndicator(_passwordController.text),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildPasswordField(
                controller: _confirmPasswordController,
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
                  if (value != _passwordController.text) {
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
          controller: _passwordController,
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
        if (_passwordController.text.isNotEmpty)
          _passwordStrengthIndicator(_passwordController.text),
        SizedBox(height: 16.h),
        _buildPasswordField(
          controller: _confirmPasswordController,
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