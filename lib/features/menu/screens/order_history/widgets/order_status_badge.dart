import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/models/order.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData statusIcon;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFFB8860B);
        statusIcon = Icons.schedule_rounded;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        backgroundColor = const Color(0xFFD1E7FF);
        textColor = const Color(0xFF0052CC);
        statusIcon = Icons.check_circle_rounded;
        text = 'Confirmed';
        break;
      case OrderStatus.preparing:
        backgroundColor = const Color(0xFFE8DAFF);
        textColor = const Color(0xFF5F2EEA);
        statusIcon = Icons.restaurant_rounded;
        text = 'Preparing';
        break;
      case OrderStatus.ready:
        backgroundColor = const Color(0xFFBFEBE5);
        textColor = const Color(0xFF00594F);
        statusIcon = Icons.done_all_rounded;
        text = 'Ready';
        break;
      case OrderStatus.pickup:
        backgroundColor = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1E40AF);
        statusIcon = Icons.shopping_bag_rounded;
        text = 'Pickup';
        break;
        case OrderStatus.driverpickup:
        backgroundColor = const Color(0xFFBFDBFE);
        textColor = const Color.fromARGB(255, 40, 147, 173);
        statusIcon = Icons.shopping_bag_rounded;
        text = 'Drive Pickup';
        break;
      case OrderStatus.shop:
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        statusIcon = Icons.storefront_rounded;
        text = 'Shop';
        break;
      case OrderStatus.outForDelivery:
        backgroundColor = const Color(0xFFFFDDB3);
        textColor = const Color(0xFF92400E);
        statusIcon = Icons.local_shipping_rounded;
        text = 'On the Way';
        break;
      case OrderStatus.delivered:
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        statusIcon = Icons.check_circle_rounded;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        statusIcon = Icons.cancel_rounded;
        text = 'Cancelled';
        break;
      case OrderStatus.refunded:
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
        statusIcon = Icons.money_off_rounded;
        text = 'Refunded';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
