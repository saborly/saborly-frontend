import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/features/providers/home_provider.dart';

/// Small banner shown above the search results grid on mobile, indicating
/// the active query, loading state, and result count.
class SearchStatusBanner extends StatelessWidget {
  final HomeProvider provider;
  final VoidCallback onClear;

  const SearchStatusBanner({super.key, required this.provider, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final totalResults = provider.searchResults.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.18),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Searching for "${provider.lastSearchQuery}"',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  provider.isSearchLoading
                      ? 'Loading...'
                      : '$totalResults ${totalResults == 1 ? 'result' : 'results'} found',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: Icon(Icons.close, color: AppColors.textDark, size: 20.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
