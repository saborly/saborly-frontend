import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/order.dart';
import 'order_info_row.dart';

/// Extracted from order_status.dart `_buildOrderDetails`.
class OrderDetailsCard extends StatelessWidget {
  final Order order;
  final bool isDesktop;
  final bool isTablet;

  const OrderDetailsCard({
    super.key,
    required this.order,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icons.receipt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.orderDetails,
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
          ...order.items
              .map((cartItem) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: cartItem.foodItem.isVeg
                                  ? Colors.green
                                  : Colors.red,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.circle,
                            color: cartItem.foodItem.isVeg
                                ? Colors.green
                                : Colors.red,
                            size: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${cartItem.quantity}x ${cartItem.foodItem.name}',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${AppStrings.currency}${cartItem.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          const SizedBox(height: 20),
          Divider(color: AppColors.divider, thickness: 1, height: 1),
          const SizedBox(height: 16),
          OrderInfoRow(AppStrings.get('subtotal'),
              '${AppStrings.get('currency')}${order.subtotal.toStringAsFixed(2)}'),
          if (order.deliveryFee > 0)
            OrderInfoRow(AppStrings.get('deliveryFee'),
                '${AppStrings.get('currency')}${order.deliveryFee.toStringAsFixed(2)}'),
          if (order.tax > 0)
            OrderInfoRow(AppStrings.get('tax'),
                '${AppStrings.get('currency')}${order.tax.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider, thickness: 2, height: 2),
          const SizedBox(height: 16),
          OrderInfoRow(
            AppStrings.get('total'),
            '${AppStrings.get('currency')}${order.total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}
