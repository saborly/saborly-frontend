import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import 'package:Saborly/shared/models/order.dart';

class PaymentMethodCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final PaymentMethod method;
  final PaymentProvider provider;
  final bool isAvailable;
  final String? description;

  const PaymentMethodCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.method,
    required this.provider,
    required this.isAvailable,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.selectedPaymentMethod == method && isAvailable;

    return GestureDetector(
      onTap: isAvailable ? () => provider.selectPaymentMethod(method) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : (isAvailable
                  ? Colors.grey.withOpacity(0.02)
                  : Colors.grey.withOpacity(0.01)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? color
                : (AppColors.border?.withOpacity(0.3) ??
                    Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.4,
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30.sp,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? AppColors.textDark
                                : AppColors.textLight,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.textLight?.withOpacity(0.12) ??
                                  Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              AppStrings.get('comingSoon'),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textLight?.withOpacity(0.8) ??
                              Colors.grey.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
