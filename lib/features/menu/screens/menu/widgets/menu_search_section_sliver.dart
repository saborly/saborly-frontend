import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/features/providers/men_provider.dart';

import 'package:Saborly/shared/widgets/search_bar_widget.dart';

/// Extracted verbatim from `_MenuScreenState._buildSearchSectionSliver`.
class MenuSearchSectionSliver extends StatelessWidget {
  final MenuProvider provider;

  const MenuSearchSectionSliver({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.16),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: SearchBarWidget(onSearch: provider.searchFoodItems),
        ),
      ),
    );
  }
}
