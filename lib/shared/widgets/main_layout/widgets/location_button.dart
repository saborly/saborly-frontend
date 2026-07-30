import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import '../../../../core/routes/app_routes.dart';
import 'responsive_helper.dart';

/// Extracted from MainLayout._buildLocationButton.
/// Note: this widget was unused (dead code) in the original main_layout.dart
/// body as well; kept as-is for exact structural preservation.
class LocationButtonWidget extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;

  const LocationButtonWidget({
    super.key,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 12.0,
      desktop: 14.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 18.0,
    );
    final titleSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 10.5,
      desktop: 11.0,
    );
    final subtitleSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 11.0,
      tablet: 11.5,
      desktop: 12.0,
    );

    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, _) {
        final selectedAddress = checkoutProvider.selectedAddress;
        final selectedBranch = checkoutProvider.selectedBranch;

        String title = AppStrings.pickupLocation;
        String subtitle = 'Saborly Barcelona';

        if (selectedAddress != null) {
          title = AppStrings.get('delivery');
          subtitle = selectedAddress.address;
        } else if (selectedBranch != null) {
          subtitle = selectedBranch.name;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go(AppRoutes.checkout),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isDesktop ? 9 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: iconSize,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
