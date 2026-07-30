import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import '../../../../../shared/models/order.dart';
import 'order_status_helpers.dart';

/// Extracted from order_status.dart `_buildOrderHeader`.
class OrderHeader extends StatelessWidget {
  final Order order;
  final bool isDesktop;
  final bool isTablet;

  const OrderHeader({
    super.key,
    required this.order,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getStatusIcon(order.status),
                  color: getStatusColor(order.status),
                  size: isDesktop ? 32 : 28,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  'Order #${order.id.toUpperCase()}',
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatDate(order.createdAt),
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
