import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';

class FrequentlyBoughtSection extends StatelessWidget {
  final CartProvider cartProvider;
  final bool isWeb;

  const FrequentlyBoughtSection(this.cartProvider, this.isWeb, {super.key});

  @override
  Widget build(BuildContext context) {
    final suggestedItems = cartProvider.getFrequentlyBoughtTogether();
    if (suggestedItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: isWeb ? null : EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(isWeb ? 28 : 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 20 : 12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: isWeb ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: isWeb ? 24 : 20.sp,
                  ),
                ),
                SizedBox(width: isWeb ? 12 : 8.w),
                Text(
                  AppStrings.frequentlyBoughtTogether,
                  style: TextStyle(
                    fontSize: isWeb ? 19 : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: isWeb ? 20 : 12.h),
            SizedBox(
              height: isWeb ? 170 : 110.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestedItems.length,
                itemBuilder: (context, index) {
                  final item = suggestedItems[index];
                  return Container(
                    width: isWeb ? 140 : 90.w,
                    margin: EdgeInsets.only(right: isWeb ? 20 : 12.w),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(isWeb ? 16 : 8.r),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.network(
                              item.imageUrl,
                              width: isWeb ? 110 : 70.w,
                              height: isWeb ? 110 : 70.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: isWeb ? 110 : 70.w,
                                height: isWeb ? 110 : 70.h,
                                color: Colors.grey.shade100,
                                child: Icon(Icons.fastfood, size: isWeb ? 36 : 24.sp, color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isWeb ? 10 : 6.h),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: isWeb ? 4 : 2.h),
                        Text(
                          '${AppStrings.currency}${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
