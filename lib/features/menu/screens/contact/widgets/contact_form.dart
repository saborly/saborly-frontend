import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'contact_text_field.dart';

class ContactForm extends StatelessWidget {
  const ContactForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.subjectController,
    required this.messageController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.isWeb,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 40.w : 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('sendUsMessage'),
              style: TextStyle(
                fontSize: isWeb ? 28.sp : 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 32.h),
            ContactTextField(
              controller: nameController,
              label: AppStrings.get('fullName'),
              hint: AppStrings.get('yourName'),
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterName;
                }
                return null;
              },
              isWeb: isWeb,
            ),
            SizedBox(height: 20.h),
            ContactTextField(
              controller: emailController,
              label: AppStrings.email,
              hint: AppStrings.get('yourEmail'),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterEmail;
                }
                if (!value.contains('@')) {
                  return AppStrings.pleaseEnterValidEmail;
                }
                return null;
              },
              isWeb: isWeb,
            ),
            SizedBox(height: 20.h),
            ContactTextField(
              controller: phoneController,
              label: AppStrings.get('phoneNumber'),
              hint: AppStrings.get('yourPhone'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                    return AppStrings.get('pleaseEnterValidPhone');
                  }
                }
                return null;
              },
              isWeb: isWeb,
            ),
            SizedBox(height: 20.h),
            ContactTextField(
              controller: subjectController,
              label: AppStrings.get('subject'),
              hint: AppStrings.get('yourSubject'),
              icon: Icons.subject,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.get('pleaseEnterSubject');
                }
                return null;
              },
              isWeb: isWeb,
            ),
            SizedBox(height: 20.h),
            ContactTextField(
              controller: messageController,
              label: AppStrings.get('message'),
              hint: AppStrings.get('yourMessage'),
              icon: Icons.message_outlined,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.get('pleaseEnterMessage');
                }
                return null;
              },
              isWeb: isWeb,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                child: isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppStrings.get('sendMessage'),
                        style: TextStyle(
                          fontSize: isWeb ? 18.sp : 16.sp,
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
}
