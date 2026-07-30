import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import 'package:Saborly/shared/models/order.dart';

// NEW: COD Payment Type Card
class CodTypeCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final CodPaymentType type;
  final PaymentProvider provider;
  final String description;

  const CodTypeCard({
    super.key,
    required this.name,
    required this.icon,
    required this.type,
    required this.provider,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.codPaymentType == type;
    final color = AppColors.primary ?? Colors.blue;

    return GestureDetector(
      onTap: () => provider.setCodPaymentType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : Colors.grey.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? color
                : (AppColors.border?.withOpacity(0.3) ??
                    Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(isSelected ? 0.2 : 0.1),
                    color.withOpacity(isSelected ? 0.1 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textLight?.withOpacity(0.8) ??
                    Colors.grey.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
