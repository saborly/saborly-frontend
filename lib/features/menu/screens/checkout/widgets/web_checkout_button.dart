import 'package:Saborly/core/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/shared/widgets/custom_button.dart';

class WebCheckoutButton extends StatelessWidget {
  const WebCheckoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        final canProceed = checkoutProvider.isReadyForOrder &&
            checkoutProvider.canPlaceOrder; // ✅ NEW: Also check if restaurant is open

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ✅ NEW: Show closing soon warning if within 30 minutes
              if (checkoutProvider.isRestaurantOpen &&
                  TimeUtils.getTimeUntilClosing() != null) ...[
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange.shade700, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Closing in ${TimeUtils.getTimeUntilClosing()} - ${AppStrings.orderBeforeClosing}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(
                height: 56,
                child: CustomButton(
                  text: AppStrings.placeOrder,
                  onPressed: canProceed ? () => context.push(AppRoutes.payment) : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
