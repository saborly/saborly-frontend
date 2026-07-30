import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'contact_info_card.dart';
import 'contact_info_item.dart';
import 'contact_phone_item.dart';
import 'contact_social_media.dart';

class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({
    super.key,
    required this.isWeb,
    required this.onLaunchUrl,
  });

  final bool isWeb;
  final Future<void> Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContactInfoCard(
          title: AppStrings.get('callUs'),
          icon: Icons.phone,
          children: [
            Text(
              'Sabadell',
              style: TextStyle(
                fontSize: isWeb ? 15.sp : 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8.h),
            ContactPhoneItem(icon: Icons.phone_in_talk, phone: '669 37 85 28', isWeb: isWeb, onLaunchUrl: onLaunchUrl),
            SizedBox(height: 8.h),
            ContactPhoneItem(icon: Icons.phone_in_talk, phone: '935 35 92 24', isWeb: isWeb, onLaunchUrl: onLaunchUrl),
            SizedBox(height: 16.h),
            Text(
              'Barcelona',
              style: TextStyle(
                fontSize: isWeb ? 15.sp : 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8.h),
            ContactPhoneItem(icon: Icons.phone_in_talk, phone: '932 11 20 72', isWeb: isWeb, onLaunchUrl: onLaunchUrl),
            SizedBox(height: 8.h),
            ContactPhoneItem(icon: Icons.phone_in_talk, phone: '619 80 70 84', isWeb: isWeb, onLaunchUrl: onLaunchUrl),
            SizedBox(height: 12.h),
            ContactInfoItem(
              icon: Icons.access_time,
              text: AppStrings.get('businessHours'),
              isWeb: isWeb,
            ),
          ],
          isWeb: isWeb,
        ),
        SizedBox(height: 20.h),
        ContactInfoCard(
          title: AppStrings.get('visitUs'),
          icon: Icons.location_on,
          children: [
            ContactInfoItem(
              icon: Icons.place,
              text: AppStrings.get('address'),
              isWeb: isWeb,
            ),
          ],
          isWeb: isWeb,
        ),
        SizedBox(height: 20.h),
        ContactInfoCard(
          title: AppStrings.get('writeUs'),
          icon: Icons.email,
          children: [
            ContactInfoItem(
              icon: Icons.email,
              text: AppStrings.get('infoEmail'),
              isWeb: isWeb,
            ),
            SizedBox(height: 12.h),
            ContactInfoItem(
              icon: Icons.support_agent,
              text: AppStrings.get('supportEmail'),
              isWeb: isWeb,
            ),
          ],
          isWeb: isWeb,
        ),
        SizedBox(height: 20.h),
        ContactSocialMedia(isWeb: isWeb, onLaunchUrl: onLaunchUrl),
      ],
    );
  }
}
