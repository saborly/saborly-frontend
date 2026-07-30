import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/order.dart';
import 'order_status_helpers.dart';

/// Extracted from order_status.dart `_buildDeliveryTime`.
class OrderDeliveryTimeCard extends StatelessWidget {
  final Order order;
  final DateTime currentTime;
  final bool isDesktop;
  final bool isTablet;

  const OrderDeliveryTimeCard({
    super.key,
    required this.order,
    required this.currentTime,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPickupOrder = order.deliveryType == DeliveryType.pickup;
    final timeRemaining = calculateTimeRemaining(order, currentTime);
    final isDelivered = order.status == OrderStatus.delivered;
    final isPickedUp = (order.status == OrderStatus.pickup ||
            order.status == OrderStatus.driverpickup ||
            order.status == OrderStatus.shop) &&
        isPickupOrder;
    final isCancelled = order.status == OrderStatus.cancelled;
    final isOutForDelivery = order.status == OrderStatus.outForDelivery;
    final isReadyForPickup = isPickupOrder && order.status == OrderStatus.ready;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 40 : 32)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDelivered
              ? [Colors.green, Colors.green.shade700]
              : isCancelled
                  ? [const Color(0xFFC62828), const Color(0xFFB71C1C)]
                  : isPickedUp
                      ? [const Color(0xFF388E3C), const Color(0xFF2E7D32)]
                      : isOutForDelivery
                          ? [const Color(0xFF303F9F), const Color(0xFF1A237E)]
                          : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDelivered
                    ? Colors.green
                    : isCancelled
                        ? const Color(0xFFC62828)
                        : isOutForDelivery
                            ? const Color(0xFF303F9F)
                            : AppColors.primary)
                .withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isDelivered
                ? AppStrings.get('delivered')
                : isCancelled
                    ? AppStrings.get('cancelled')
                    : isPickedUp
                        ? AppStrings.get('pickedUp')
                        : isOutForDelivery
                            ? AppStrings.get('outForDelivery')
                            : isReadyForPickup
                                ? AppStrings.get('readyForPickup')
                                : (isPickupOrder
                                    ? AppStrings.get("readyIn")
                                    : AppStrings.estimatedDelivery),
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (isDelivered || isPickedUp)
                ? '✓'
                : isCancelled
                    ? '✗'
                    : isOutForDelivery
                        ? '🚚'
                        : '$timeRemaining min',
            style: TextStyle(
              fontSize: isDesktop ? 64 : (isTablet ? 56 : 48),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  (isDelivered || isPickedUp)
                      ? Icons.check_circle_rounded
                      : isCancelled
                          ? Icons.cancel_rounded
                          : isOutForDelivery
                              ? Icons.local_shipping_rounded
                              : (isPickupOrder
                                  ? Icons.shopping_bag_rounded
                                  : Icons.schedule_rounded),
                  color: Colors.white,
                  size: isDesktop ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  (isDelivered)
                      ? AppStrings.get('orderCompleted')
                      : isCancelled
                          ? AppStrings.get('orderCancelled')
                          : isOutForDelivery
                              ? AppStrings.get('driverOnTheWay')
                              : (isPickupOrder
                                  ? AppStrings.get("readyIn")
                                  : AppStrings.getYourOrder),
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
