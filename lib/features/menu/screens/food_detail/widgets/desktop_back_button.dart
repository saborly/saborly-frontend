import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';

class DesktopBackButton extends StatelessWidget {
  const DesktopBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32.h,
      left: 32.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textDark,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }
}
