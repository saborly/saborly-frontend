import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/banner_service.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/shared/widgets/ooter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (_formKey.currentState!.validate()) {
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
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    // ✅ WRAP WITH Consumer TO REBUILD ON LANGUAGE CHANGE
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          backgroundColor: isWeb ? const Color(0xFFFAFAFA) : Colors.white,
          appBar: _buildAppBar(context, isWeb),
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
                                  child: _buildContactForm(isWeb),
                                ),
                                SizedBox(width: 40.w),
                                Expanded(
                                  flex: 4,
                                  child: _buildContactInfo(isWeb),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildContactForm(isWeb),
                              SizedBox(height: 32.h),
                              _buildContactInfo(isWeb),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isWeb) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textDark, size: 24.sp),
        onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
      ),
      title: Text(
        AppStrings.get('contactUs'),
        style: TextStyle(
          fontSize: isWeb ? 24.sp : 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContactForm(bool isWeb) {
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
        key: _formKey,
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
            _buildTextField(
              controller: _nameController,
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
            _buildTextField(
              controller: _emailController,
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
            _buildTextField(
              controller: _phoneController,
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
            _buildTextField(
              controller: _subjectController,
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
            _buildTextField(
              controller: _messageController,
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
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    required bool isWeb,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: isWeb ? 16.sp : 14.sp,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textLight,
              fontSize: isWeb ? 15.sp : 13.sp,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22.sp),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(bool isWeb) {
    return Column(
      children: [
        _buildInfoCard(
          title: AppStrings.get('callUs'),
          icon: Icons.phone,
          children: [
            _buildInfoItem(
              icon: Icons.phone_in_talk,
              text: '+34932112072',
              isWeb: isWeb,
            ),
            SizedBox(height: 12.h),
            _buildInfoItem(
              icon: Icons.access_time,
              text: AppStrings.get('businessHours'),
              isWeb: isWeb,
            ),
          ],
          isWeb: isWeb,
        ),
        SizedBox(height: 20.h),
        _buildInfoCard(
          title: AppStrings.get('visitUs'),
          icon: Icons.location_on,
          children: [
            _buildInfoItem(
              icon: Icons.place,
              text: AppStrings.get('address'),
              isWeb: isWeb,
            ),
          ],
          isWeb: isWeb,
        ),
        SizedBox(height: 20.h),
        _buildInfoCard(
          title: AppStrings.get('writeUs'),
          icon: Icons.email,
          children: [
            _buildInfoItem(
              icon: Icons.email,
              text: AppStrings.get('infoEmail'),
              isWeb: isWeb,
            ),
            SizedBox(height: 12.h),
            _buildInfoItem(
              icon: Icons.support_agent,
              text: AppStrings.get('supportEmail'),
              isWeb: isWeb,
            ),
          ],
          isWeb: isWeb,
        ),
        SizedBox(height: 20.h),
        _buildSocialMedia(isWeb),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isWeb,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 28.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: isWeb ? 20.sp : 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required bool isWeb,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isWeb ? 16.sp : 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMedia(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 28.w : 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.get('followUs'),
            style: TextStyle(
              fontSize: isWeb ? 20.sp : 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.facebook, () {
                _launchUrl('https://www.facebook.com/SaborlyBurger/');
              }),
              _buildSocialButton(Icons.camera_alt, () {
                _launchUrl('https://www.instagram.com/saborly.es/?igsh=eDg0a2FvZ2Zqbmg%3D&utm_source=qr#');
              }),
              _buildSocialButton(Icons.play_arrow, () {
                _launchUrl('https://www.youtube.com/@saborlyburger');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }
}