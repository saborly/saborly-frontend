import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/men_provider.dart';

/// Extracted verbatim from `_MenuScreenState._buildFilterOptions`
/// (plus its private helper `_buildCheckboxTile`).
///
/// Used inside both the filter bottom sheet and the filter dialog.
class MenuFilterOptions extends StatelessWidget {
  final MenuProvider provider;

  const MenuFilterOptions({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
  AppStrings.get('foodType'),
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 16.h),
        _buildCheckboxTile(
          AppStrings.get('vegetarian'),
          Icons.eco_rounded,
          provider.showVegOnly,
          (value) => provider.setVegFilter(value ?? false),
          const Color(0xFF10B981),
        ),
        SizedBox(height: 8.h),
        _buildCheckboxTile(
          AppStrings.get('nonVegetarian'),
          Icons.restaurant_rounded,
          provider.showNonVegOnly,
          (value) => provider.setNonVegFilter(value ?? false),
          const Color(0xFFEF4444),
        ),
        SizedBox(height: 8.h),
        _buildCheckboxTile(
          AppStrings.get('popularItems'),
          Icons.local_fire_department_rounded,
          provider.showPopularOnly,
          (value) => provider.setPopularFilter(value ?? false),
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool?> onChanged,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: value ? accentColor.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: value ? accentColor : Colors.grey.shade200,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(icon, size: 20.sp, color: value ? accentColor : Colors.grey.shade600),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                color: value ? accentColor : AppColors.textDark,
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        checkColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
