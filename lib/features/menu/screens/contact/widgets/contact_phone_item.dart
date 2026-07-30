import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';

class ContactPhoneItem extends StatelessWidget {
  const ContactPhoneItem({
    super.key,
    required this.icon,
    required this.phone,
    required this.isWeb,
    required this.onLaunchUrl,
  });

  final IconData icon;
  final String phone;
  final bool isWeb;
  final Future<void> Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    final dialNumber = phone.replaceAll(' ', '');
    return InkWell(
      onTap: () => onLaunchUrl('tel:$dialNumber'),
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            phone,
            style: TextStyle(
              fontSize: isWeb ? 16.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
