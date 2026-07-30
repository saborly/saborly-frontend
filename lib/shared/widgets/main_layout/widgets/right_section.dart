import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/shared/widgets/language_selector.dart';
import 'package:Saborly/shared/widgets/search_bar_widget.dart';
import '../../../../core/routes/app_routes.dart';
import 'responsive_helper.dart';
import 'cart_button.dart';
import 'account_button.dart';

/// Extracted from MainLayout._buildRightSection.
class RightSectionWidget extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;
  final bool showLanguageSelector;

  const RightSectionWidget({
    super.key,
    required this.isDesktop,
    required this.isTablet,
    required this.showLanguageSelector,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 4.0,
      tablet: 6.0,
      desktop: 7.0
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isDesktop) ...[
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 289),
              child: GestureDetector(
                onTap: () {
                  // ✅ Navigate to search page when clicking search bar
                  context.push(AppRoutes.search);
                },
                child: AbsorbPointer(
                  child: SearchBarWidget(
                    onSearch: (query) {},
                    onSearchStarted: null,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
        ],
        if (showLanguageSelector) ...[
          LanguageSelector(
            showLabel: true,
            isCompact: true,
          ),
          SizedBox(width: spacing),
        ],
        CartButtonWidget(isTablet: isTablet),
        SizedBox(width: spacing),
        AccountButtonWidget(isTablet: isTablet),
      ],
    );
  }
}
