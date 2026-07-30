import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/order.dart';
import 'order_info_row.dart';
import 'order_status_helpers.dart';

/// Extracted from order_status.dart `_buildPaymentInfo`.
class OrderPaymentInfoCard extends StatelessWidget {
  final Order order;
  final bool isDesktop;
  final bool isTablet;

  const OrderPaymentInfoCard({
    super.key,
    required this.order,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.get('paymentInfo'),
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OrderInfoRow(
            AppStrings.get('paymentMethod'),
            getPaymentMethodText(order.paymentMethod),
          ),
          const SizedBox(height: 12),
          OrderInfoRow(
            AppStrings.get('paymentStatus'),
            getPaymentStatusText(
              order.status == OrderStatus.delivered
                  ? PaymentStatus.paid
                  : isCancelled
                      ? PaymentStatus.refunded
                      : order.paymentStatus,
            ),
          ),
          if (isCancelled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF6F00).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: const Color(0xFFFF6F00),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get('refundProcessing'),
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
