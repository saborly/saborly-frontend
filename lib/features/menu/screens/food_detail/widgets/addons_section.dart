import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/food_item.dart';

class AddonsSection extends StatelessWidget {
  final List<Addon> addons;
  final List<Addon> selectedAddons;
  final bool isLargeScreen;
  final ValueChanged<Addon> onToggle;

  const AddonsSection({
    super.key,
    required this.addons,
    required this.selectedAddons,
    required this.isLargeScreen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isLargeScreen ? 0 : 20.w,
        right: 0,
        top: 0,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: isLargeScreen ? 0 : 20.w),
            child: Text(
              AppStrings.get('addons'),
              style: TextStyle(
                fontSize: isLargeScreen ? 22.sp : 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: isLargeScreen ? 300.h : 190.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(right: isLargeScreen ? 0 : 20.w),
              itemCount: addons.length,
              itemBuilder: (context, index) {
                final addon = addons[index];
                return _AddonCard(
                  addon: addon,
                  isSelected: selectedAddons.any((a) => a.id == addon.id),
                  isLargeScreen: isLargeScreen,
                  onToggle: onToggle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  final Addon addon;
  final bool isSelected;
  final bool isLargeScreen;
  final ValueChanged<Addon> onToggle;

  const _AddonCard({
    required this.addon,
    required this.isSelected,
    required this.isLargeScreen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onToggle(addon),
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isLargeScreen ? 220.w : 160.w,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (addon.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final dpr = MediaQuery.of(context).devicePixelRatio;
                      final targetWidth = constraints.maxWidth.isFinite
                          ? (constraints.maxWidth * dpr).round()
                          : null;
                      return kIsWeb
                          ? Image.network(
                              addon.imageUrl,
                              height: isLargeScreen ? 140.h : 100.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              cacheWidth: targetWidth,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: isLargeScreen ? 140.h : 100.h,
                                color: const Color(0xFFF0F0F0),
                                child: Icon(Icons.fastfood_rounded, size: 40.sp, color: Colors.grey[400]),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: addon.imageUrl,
                              height: isLargeScreen ? 140.h : 100.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              memCacheWidth: targetWidth,
                              placeholder: (context, url) => Container(
                                height: isLargeScreen ? 140.h : 100.h,
                                color: const Color(0xFFF0F0F0),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: isLargeScreen ? 140.h : 100.h,
                                color: const Color(0xFFF0F0F0),
                                child: Icon(Icons.fastfood_rounded, size: 40.sp, color: Colors.grey[400]),
                              ),
                            );
                    },
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              addon.name,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16.sp : 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${AppStrings.currency}${addon.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 15.sp : 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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
