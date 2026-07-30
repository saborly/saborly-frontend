import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'contact_social_button.dart';

class ContactSocialMedia extends StatelessWidget {
  const ContactSocialMedia({
    super.key,
    required this.isWeb,
    required this.onLaunchUrl,
  });

  final bool isWeb;
  final Future<void> Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
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
              ContactSocialButton(
                icon: Icons.facebook,
                onTap: () {
                  onLaunchUrl('https://www.facebook.com/SaborlyBurger/');
                },
              ),
              ContactSocialButton(
                icon: Icons.camera_alt,
                onTap: () {
                  onLaunchUrl('https://www.instagram.com/saborly.es/?igsh=eDg0a2FvZ2Zqbmg%3D&utm_source=qr#');
                },
              ),
              ContactSocialButton(
                icon: Icons.play_arrow,
                onTap: () {
                  onLaunchUrl('https://www.youtube.com/@saborlyburger');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
