import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import 'signup_feature_list.dart';
import 'signup_form.dart';
import 'signup_form_header.dart';
import 'signup_sign_in_link.dart';

class SignupLargeScreenLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final void Function(BuildContext context, AuthProvider authProvider) onSignUp;

  const SignupLargeScreenLayout({
    super.key,
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
                  const SignupFeatureList(),
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
                        const SignupFormHeader(isLargeScreen: true),
                        SizedBox(height: 40.h),
                        SignupForm(
                          formKey: formKey,
                          isTablet: true,
                          firstNameController: firstNameController,
                          lastNameController: lastNameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          onSignUp: onSignUp,
                        ),
                        SizedBox(height: 40.h),
                        const SignupSignInLink(),
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
}
