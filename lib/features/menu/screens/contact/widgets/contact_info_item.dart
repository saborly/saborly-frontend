import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';

class ContactInfoItem extends StatelessWidget {
  const ContactInfoItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isWeb,
  });

  final IconData icon;
  final String text;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
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
}
