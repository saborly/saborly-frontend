import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/banner_service.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/core/utils/responsive_utils.dart';
import 'package:Saborly/shared/widgets/ooter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact/widgets/contact_app_bar.dart';
import 'contact/widgets/contact_form.dart';
import 'contact/widgets/contact_info_section.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;
  
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

Future<void> _submitForm() async {
  // Validate first
  if (!_formKey.currentState!.validate()) {
    // Stop here – do NOT submit
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final result = await ContactService.submitContactForm(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('formSubmissionSuccess')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
        _phoneController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('formSubmissionError')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  } catch (e) {
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('unexpectedError')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    // ✅ WRAP WITH Consumer TO REBUILD ON LANGUAGE CHANGE
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          backgroundColor: isWeb ? const Color(0xFFFAFAFA) : Colors.white,
          appBar: ContactAppBar(isWeb: isWeb),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1400.w),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 60.w : 16.w,
                        vertical: isWeb ? 40.h : 24.h,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (isWeb && constraints.maxWidth > 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: ContactForm(
                                    formKey: _formKey,
                                    nameController: _nameController,
                                    emailController: _emailController,
                                    phoneController: _phoneController,
                                    subjectController: _subjectController,
                                    messageController: _messageController,
                                    isSubmitting: _isSubmitting,
                                    onSubmit: _submitForm,
                                    isWeb: isWeb,
                                  ),
                                ),
                                SizedBox(width: 40.w),
                                Expanded(
                                  flex: 4,
                                  child: ContactInfoSection(
                                    isWeb: isWeb,
                                    onLaunchUrl: _launchUrl,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              ContactForm(
                                formKey: _formKey,
                                nameController: _nameController,
                                emailController: _emailController,
                                phoneController: _phoneController,
                                subjectController: _subjectController,
                                messageController: _messageController,
                                isSubmitting: _isSubmitting,
                                onSubmit: _submitForm,
                                isWeb: isWeb,
                              ),
                              SizedBox(height: 32.h),
                              ContactInfoSection(
                                isWeb: isWeb,
                                onLaunchUrl: _launchUrl,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isWeb ? 60.h : 40.h),
                if (isWeb)
                  Container(
                    width: double.infinity,
                    child: FoodKingFooter(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}