import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/shared/widgets/food_category_card.dart';

/// Horizontal, scrollable category chips shown above the web showcase
/// panel (mobile uses [MobileCategoriesSection] instead).
class CategoriesSlider extends StatelessWidget {
  final HomeProvider provider;
  final bool isWeb;
  final VoidCallback onClearSearchSilently;

  const CategoriesSlider({
    super.key,
    required this.provider,
    required this.isWeb,
    required this.onClearSearchSilently,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: isWeb ? 140.h : 122.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isLast = index == provider.categories.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : (isWeb ? 16.w : 15.w)),
            child: FoodCategoryCard(
              category: category,
              onTap: () {
                onClearSearchSilently();
                context.push(AppRoutes.menu, extra: {'category': category.id});
              },
            ),
          );
        },
      ),
    );
  }
}
