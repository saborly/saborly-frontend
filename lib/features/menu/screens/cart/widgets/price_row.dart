import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const PriceRow(this.label, this.amount, {super.key, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? (isTotal ? 17 : 15) : (isTotal ? 16 : 14),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          Text(
            '${AppStrings.currency}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isWeb ? (isTotal ? 17 : 15) : (isTotal ? 16 : 14),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
