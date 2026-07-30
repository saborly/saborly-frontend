import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final bool isLargeScreen;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.isLargeScreen,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('quantity'),
            style: TextStyle(
              fontSize: isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrement,
                  enabled: quantity > 1,
                  isLargeScreen: isLargeScreen,
                ),
                Container(
                  width: isLargeScreen ? 90.w : 70.w,
                  alignment: Alignment.center,
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 22.sp : 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrement,
                  enabled: true,
                  isLargeScreen: isLargeScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLargeScreen;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: isLargeScreen ? 52.w : 44.w,
          height: isLargeScreen ? 52.h : 44.h,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.grey[400],
            size: isLargeScreen ? 24.sp : 22.sp,
          ),
        ),
      ),
    );
  }
}
