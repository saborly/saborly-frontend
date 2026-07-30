import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/order.dart';

/// Pure helper functions shared by the order status widgets.
/// Extracted from order_status.dart without changing any logic.

String calculateTimeRemaining(Order order, DateTime currentTime) {
  if (order.status == OrderStatus.delivered ||
      order.status == OrderStatus.cancelled) {
    return '0';
  }

  final branchName = order.branchName?.toLowerCase() ?? '';
  final isSabadell = branchName.contains('sabadell');
  final defaultTime = isSabadell ? '45' : '30';

  // For Sabadell, we allow up to 60 mins before falling back to default
  // For others (Barcelona), we allow up to 40 mins
  final maxDisplayTime = isSabadell ? 60 : 40;

  if (order.estimatedDeliveryTime == null) {
    return defaultTime;
  }

  final difference = order.estimatedDeliveryTime!.difference(currentTime);

  if (difference.isNegative) {
    return '0';
  }

  final minutes = difference.inMinutes;
  if (minutes <= 0) {
    return '0';
  } else if (minutes <= 5) {
    return '5';
  } else if (minutes <= maxDisplayTime) {
    return '$minutes';
  } else {
    return defaultTime;
  }
}

// Add this helper method to check if a status is completed
bool isStatusCompleted(OrderStatus currentStatus, OrderStatus checkStatus) {
  // Define the order of statuses for delivery
  const deliveryFlow = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.pickup, // or driverpickup
    OrderStatus.driverpickup,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  // Define the order of statuses for pickup
  const pickupFlow = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.pickup,
    OrderStatus.shop,
    OrderStatus.delivered,
  ];

  // Get the index of current status and check status
  int currentIndex = deliveryFlow.indexOf(currentStatus);
  int checkIndex = deliveryFlow.indexOf(checkStatus);

  // If not found in delivery flow, try pickup flow
  if (currentIndex == -1) {
    currentIndex = pickupFlow.indexOf(currentStatus);
    checkIndex = pickupFlow.indexOf(checkStatus);
  }

  // Special handling for pickup/driverpickup equivalence
  if (checkStatus == OrderStatus.pickup &&
      (currentStatus == OrderStatus.driverpickup ||
          currentStatus == OrderStatus.shop ||
          currentStatus == OrderStatus.outForDelivery ||
          currentStatus == OrderStatus.delivered)) {
    return true;
  }
  if (checkStatus == OrderStatus.driverpickup &&
      (currentStatus == OrderStatus.pickup ||
          currentStatus == OrderStatus.outForDelivery ||
          currentStatus == OrderStatus.delivered)) {
    return true;
  }
  // Special handling for shop status (pickup orders)
  if (checkStatus == OrderStatus.shop &&
      (currentStatus == OrderStatus.pickup ||
          currentStatus == OrderStatus.delivered)) {
    return true;
  }
  // Special handling for ready status - if current is pickup/shop, ready is completed
  if (checkStatus == OrderStatus.ready &&
      (currentStatus == OrderStatus.pickup ||
          currentStatus == OrderStatus.shop ||
          currentStatus == OrderStatus.driverpickup ||
          currentStatus == OrderStatus.outForDelivery ||
          currentStatus == OrderStatus.delivered)) {
    return true;
  }

  // If status not found in either flow, return false
  if (currentIndex == -1 || checkIndex == -1) {
    return false;
  }

  return currentIndex >= checkIndex;
}

String formatDate(DateTime date) {
  final months = [
    AppStrings.get('jan'),
    AppStrings.get('feb'),
    AppStrings.get('mar'),
    AppStrings.get('apr'),
    AppStrings.get('may'),
    AppStrings.get('jun'),
    AppStrings.get('jul'),
    AppStrings.get('aug'),
    AppStrings.get('sep'),
    AppStrings.get('oct'),
    AppStrings.get('nov'),
    AppStrings.get('dec'),
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final period = date.hour >= 12 ? AppStrings.get('pm') : AppStrings.get('am');
  return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:${date.minute.toString().padLeft(2, '0')} $period';
}

String getPaymentMethodText(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cashOnDelivery:
      return AppStrings.cashOnDelivery;
    case PaymentMethod.shop:
      return AppStrings.cashOnDelivery;
    case PaymentMethod.card:
      return 'Card';
    case PaymentMethod.paypal:
      return 'PayPal';
    case PaymentMethod.stripe:
      return 'Stripe';
  }
}

String getPaymentStatusText(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return AppStrings.unpaid;
    case PaymentStatus.paid:
      return AppStrings.paid;
    case PaymentStatus.failed:
      return 'Failed';
    case PaymentStatus.refunded:
      return 'Refunded';
  }
}

Color getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return const Color(0xFFFF6F00); // Deep Orange - Order Placed
    case OrderStatus.confirmed:
      return const Color(0xFF1976D2); // Dark Blue - Accept Order
    case OrderStatus.preparing:
      return const Color(0xFF7B1FA2); // Deep Purple - Start Preparing
    case OrderStatus.ready:
      return const Color(0xFF0097A7); // Dark Cyan - Ready
    case OrderStatus.pickup:
      return const Color(0xFF388E3C); // Dark Green - Pickup by Customer
    case OrderStatus.shop:
      return const Color(0xFF689F38); // Olive Green - Shop/Collected
    case OrderStatus.outForDelivery:
      return const Color(0xFF303F9F); // Dark Indigo - Out for Delivery
    case OrderStatus.driverpickup:
      return const Color.fromARGB(255, 48, 159, 159);
    case OrderStatus.delivered:
      return const Color(0xFF2E7D32); // Forest Green - Delivered
    case OrderStatus.cancelled:
      return const Color(0xFFC62828); // Dark Red - Cancelled
    case OrderStatus.refunded:
      return const Color(0xFF616161); // Dark Grey - Refunded
  }
}

IconData getStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.schedule_rounded;
    case OrderStatus.confirmed:
      return Icons.check_circle_outline_rounded;
    case OrderStatus.preparing:
      return Icons.restaurant_rounded;
    case OrderStatus.ready:
      return Icons.shopping_bag_outlined;
    case OrderStatus.pickup:
    case OrderStatus.shop:
      return Icons.shopping_bag_rounded;
    case OrderStatus.outForDelivery:
      return Icons.local_shipping_rounded;
    case OrderStatus.driverpickup:
      return Icons.drive_eta_outlined;
    case OrderStatus.delivered:
      return Icons.check_circle_rounded;
    case OrderStatus.cancelled:
      return Icons.cancel_rounded;
    case OrderStatus.refunded:
      return Icons.currency_exchange_rounded;
  }
}
