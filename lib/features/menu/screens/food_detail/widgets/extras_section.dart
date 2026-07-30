import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/food_item.dart';

class ExtrasSection extends StatelessWidget {
  final List<Extra> extras;
  final List<Extra> selectedExtras;
  final bool isLargeScreen;
  final ValueChanged<Extra> onToggle;

  const ExtrasSection({
    super.key,
    required this.extras,
    required this.selectedExtras,
    required this.isLargeScreen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('extras'),
            style: TextStyle(
              fontSize: isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          if (isLargeScreen && extras.length <= 2)
            Row(
              children: extras
                  .map((extra) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: _ExtraOption(
                            extra: extra,
                            isSelected: selectedExtras.any((e) => e.id == extra.id),
                            isLargeScreen: isLargeScreen,
                            onToggle: onToggle,
                          ),
                        ),
                      ))
                  .toList(),
            )
          else
            ...extras.map((extra) => _ExtraOption(
                  extra: extra,
                  isSelected: selectedExtras.any((e) => e.id == extra.id),
                  isLargeScreen: isLargeScreen,
                  onToggle: onToggle,
                )),
        ],
      ),
    );
  }
}

class _ExtraOption extends StatelessWidget {
  final Extra extra;
  final bool isSelected;
  final bool isLargeScreen;
  final ValueChanged<Extra> onToggle;

  const _ExtraOption({
    required this.extra,
    required this.isSelected,
    required this.isLargeScreen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onToggle(extra),
        borderRadius: BorderRadius.circular(isLargeScreen ? 16.r : 14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(isLargeScreen ? 20.w : 18.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(isLargeScreen ? 16.r : 14.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  extra.name,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 17.sp : 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${AppStrings.get('currency')}${extra.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 15.sp : 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
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
