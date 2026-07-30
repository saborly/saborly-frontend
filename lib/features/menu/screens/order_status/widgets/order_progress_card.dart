import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/order.dart';
import 'order_status_helpers.dart';

/// Extracted from order_status.dart `_buildOrderProgress`.
class OrderProgressCard extends StatelessWidget {
  final Order order;
  final bool isDesktop;
  final bool isTablet;

  const OrderProgressCard({
    super.key,
    required this.order,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPickupOrder = order.deliveryType == DeliveryType.pickup;
    final bool isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 36 : (isTablet ? 32 : 28)),
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
                  color: isCancelled
                      ? const Color(0xFFC62828).withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCancelled
                      ? Icons.cancel_rounded
                      : (isPickupOrder
                          ? Icons.shopping_bag_rounded
                          : Icons.local_shipping_rounded),
                  color:
                      isCancelled ? const Color(0xFFC62828) : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.get('orderProgress'),
                style: TextStyle(
                  fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 36 : 32),
          if (isCancelled) ...[
            // Show cancelled status
            _CancelledProgress(isDesktop: isDesktop),
          ] else if (isPickupOrder) ...[
            // Pickup order flow: pending → confirmed → preparing → ready → delivered
            _ProgressStep(
              title: AppStrings.orderPlaced,
              statusColor: const Color(0xFFFF6F00),
              isCompleted: isStatusCompleted(order.status, OrderStatus.pending),
              isDesktop: isDesktop,
              isFirst: true,
            ),
            _ProgressStep(
              title: AppStrings.get('orderConfirmed'),
              statusColor: const Color(0xFF1976D2),
              isCompleted:
                  isStatusCompleted(order.status, OrderStatus.confirmed),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.get('preparing'),
              statusColor: const Color(0xFF7B1FA2),
              isCompleted:
                  isStatusCompleted(order.status, OrderStatus.preparing),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: isPickupOrder
                  ? AppStrings.get('readyForPickup')
                  : AppStrings.ready,
              statusColor: const Color(0xFF0097A7),
              isCompleted: isStatusCompleted(order.status, OrderStatus.ready),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.get('pickedUp'),
              statusColor: const Color(0xFF388E3C),
              isCompleted: order.status == OrderStatus.delivered ||
                  order.status == OrderStatus.shop ||
                  order.status == OrderStatus.pickup,
              isDesktop: isDesktop,
              isLast: true,
            ),
          ] else ...[
            // Delivery order flow: pending → confirmed → preparing → ready → pickup → out-for-delivery → delivered
            _ProgressStep(
              title: AppStrings.orderPlaced,
              statusColor: const Color(0xFFFF6F00),
              isCompleted: isStatusCompleted(order.status, OrderStatus.pending),
              isDesktop: isDesktop,
              isFirst: true,
            ),
            _ProgressStep(
              title: AppStrings.get('orderConfirmed'),
              statusColor: const Color(0xFF1976D2),
              isCompleted:
                  isStatusCompleted(order.status, OrderStatus.confirmed),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.preparing,
              statusColor: const Color(0xFF7B1FA2),
              isCompleted:
                  isStatusCompleted(order.status, OrderStatus.preparing),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.ready,
              statusColor: const Color(0xFF0097A7),
              isCompleted: isStatusCompleted(order.status, OrderStatus.ready),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.get('driverPickup'),
              statusColor: const Color(0xFFFF6F00),
              isCompleted:
                  isStatusCompleted(order.status, OrderStatus.pickup) ||
                      isStatusCompleted(order.status, OrderStatus.driverpickup),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.get('outForDelivery'),
              statusColor: const Color(0xFF303F9F),
              isCompleted:
                  isStatusCompleted(order.status, OrderStatus.outForDelivery),
              isDesktop: isDesktop,
            ),
            _ProgressStep(
              title: AppStrings.get('delivered'),
              statusColor: const Color(0xFF2E7D32),
              isCompleted: order.status == OrderStatus.delivered,
              isDesktop: isDesktop,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Extracted from order_status.dart `_buildCancelledProgress`.
class _CancelledProgress extends StatelessWidget {
  final bool isDesktop;

  const _CancelledProgress({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC62828).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('orderCancelled'),
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('orderCancelledMessage'),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.4,
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

/// Extracted from order_status.dart `_buildProgressStep`.
class _ProgressStep extends StatelessWidget {
  final String title;
  final Color statusColor;
  final bool isCompleted;
  final bool isDesktop;
  final bool isFirst;
  final bool isLast;

  const _ProgressStep({
    required this.title,
    required this.statusColor,
    required this.isCompleted,
    required this.isDesktop,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 32;
    const double lineHeight = 40;

    return Row(
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 3,
                height: lineHeight,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [statusColor.withOpacity(0.6), statusColor],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isCompleted ? null : AppColors.border,
                ),
              ),
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? LinearGradient(
                        colors: [statusColor.withOpacity(0.8), statusColor],
                      )
                    : null,
                color: isCompleted ? null : Colors.white,
                border: Border.all(
                  color: isCompleted ? Colors.transparent : AppColors.border,
                  width: 2.5,
                ),
                shape: BoxShape.circle,
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 3,
                height: lineHeight,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [statusColor, statusColor.withOpacity(0.6)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isCompleted ? null : AppColors.border,
                ),
              ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 15,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
              color: isCompleted ? AppColors.textDark : AppColors.textLight,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
