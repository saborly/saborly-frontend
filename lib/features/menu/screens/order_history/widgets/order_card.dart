import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/models/order.dart';
import 'order_info_row.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.isWeb,
    required this.index,
  });

  final Order order;
  final bool isWeb;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.goNamed(
                'order-status',
                pathParameters: {'orderId': order.id},
              );
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary?.withOpacity(0.15) ?? Colors.blue.withOpacity(0.15),
                              AppColors.primary?.withOpacity(0.08) ?? Colors.blue.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8).toUpperCase()}',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14.sp,
                                  color: AppColors.textLight,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _formatDateTime(order.createdAt),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Order Details
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      children: [
                        OrderInfoRow(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Items',
                          value: '${order.items.length} ${order.items.length == 1 ? "item" : "items"}',
                        ),
                        SizedBox(height: 12.h),
                        OrderInfoRow(
                          icon: Icons.store_outlined,
                          label: 'Branch',
                          value: order.branchName ?? 'Main Store',
                        ),
                        SizedBox(height: 12.h),
                        OrderInfoRow(
                          icon: _getDeliveryIcon(order.deliveryType),
                          label: 'Type',
                          value: _getDeliveryTypeText(order.deliveryType),
                        ),
                        SizedBox(height: 12.h),
                        OrderInfoRow(
                          icon: _getPaymentIcon(order.paymentMethod),
                          label: 'Payment',
                          value: _getPaymentMethodText(order.paymentMethod),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Total and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary ?? Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.goNamed(
                                    'order-status',
                                    pathParameters: {'orderId': order.id},
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Details',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16.sp,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (order.status == OrderStatus.delivered) ...[
                            SizedBox(width: 10.w),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary ?? Colors.blue,
                                    (AppColors.primary ?? Colors.blue).withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: (AppColors.primary ?? Colors.blue).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.go(AppRoutes.menu),
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.repeat_rounded,
                                          size: 16.sp,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Reorder',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDeliveryIcon(DeliveryType type) {
    return type == DeliveryType.delivery
        ? Icons.delivery_dining_rounded
        : Icons.shopping_bag_outlined;
  }

  String _getDeliveryTypeText(DeliveryType type) {
    return type == DeliveryType.delivery ? 'Delivery' : 'Pickup';
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
      case PaymentMethod.shop:
        return Icons.payments_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.stripe:
        return Icons.credit_card_rounded;
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
      case PaymentMethod.shop:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    String timeStr = DateFormat('h:mm a').format(date);

    if (dateToCheck == today) {
      return 'Today at $timeStr';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday at $timeStr';
    } else if (now.difference(date).inDays < 7) {
      String dayName = DateFormat('EEEE').format(date);
      return '$dayName at $timeStr';
    } else {
      String dateStr = DateFormat('MMM d, yyyy').format(date);
      return '$dateStr at $timeStr';
    }
  }
}
