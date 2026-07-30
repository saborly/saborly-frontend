import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';

/// Extracted from order_status.dart `_buildInfoRow`.
class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const OrderInfoRow(
    this.label,
    this.value, {
    super.key,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textLight,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
