import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import '../../../../core/routes/app_routes.dart';

/// Branch switcher chip for the desktop nav: shows the current branch and
/// opens the branch picker (with auto-skip disabled) on tap.
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

    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, _) {
        final selectedBranch = checkoutProvider.selectedBranch;

        final name = selectedBranch?.name ?? 'Saborly Barcelona';

        // Single compact line so the chip never squeezes the search field.
        return Tooltip(
          message: '${AppStrings.pickupLocation}: $name',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go(AppRoutes.branchChange),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
