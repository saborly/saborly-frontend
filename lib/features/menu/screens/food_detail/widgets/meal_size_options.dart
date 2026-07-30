import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/food_item.dart';

class MealSizeOptions extends StatelessWidget {
  final List<MealSize> mealSizes;
  final MealSize? selectedMealSize;
  final bool isLargeScreen;
  final ValueChanged<MealSize?> onSelected;

  const MealSizeOptions({
    super.key,
    required this.mealSizes,
    required this.selectedMealSize,
    required this.isLargeScreen,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('mealSize'),
            style: TextStyle(
              fontSize: isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          if (isLargeScreen && mealSizes.length <= 3)
            Row(
              children: mealSizes
                  .map((size) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: _MealSizeOption(
                            size: size,
                            isSelected: selectedMealSize?.id == size.id,
                            selectedMealSize: selectedMealSize,
                            onSelected: onSelected,
                          ),
                        ),
                      ))
                  .toList(),
            )
          else
            ...mealSizes.map((size) => _MealSizeOption(
                  size: size,
                  isSelected: selectedMealSize?.id == size.id,
                  selectedMealSize: selectedMealSize,
                  onSelected: onSelected,
                )),
        ],
      ),
    );
  }
}

class _MealSizeOption extends StatelessWidget {
  final MealSize size;
  final bool isSelected;
  final MealSize? selectedMealSize;
  final ValueChanged<MealSize?> onSelected;

  const _MealSizeOption({
    required this.size,
    required this.isSelected,
    required this.selectedMealSize,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => onSelected(size),
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? AppColors.border : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.border.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Radio<MealSize>(
                value: size,
                groupValue: selectedMealSize,
                onChanged: onSelected,
                activeColor: AppColors.success,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  size.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
              if (size.additionalPrice != 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${size.additionalPrice > 0 ? '+' : ''}${AppStrings.get('currency')}${size.additionalPrice.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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
