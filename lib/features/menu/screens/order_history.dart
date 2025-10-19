import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders(limit: 50);
      _scrollController.addListener(_onScroll);
      _animationController.forward();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      context.read<OrderProvider>().loadMoreOrders();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isWeb),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.error != null && provider.orders.isEmpty) {
            return _buildErrorState(provider.error!, provider);
          }

          if (provider.orders.isEmpty) {
            return _buildEmptyState();
          }

          return _buildOrdersList(provider.orders, isWeb, provider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWeb) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go(AppRoutes.profile),
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 18.sp,
          ),
        ),
      ),
      title: Text(
        AppStrings.get('orderHistory'),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          color: Colors.grey.shade200,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            AppStrings.get('loadingYourOrders'),
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please wait a moment...',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, OrderProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (AppColors.error ?? Colors.red).withOpacity(0.1),
                    (AppColors.error ?? Colors.red).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 72.sp,
                color: AppColors.error ?? Colors.red,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              AppStrings.get('oopsSomethingWrong'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => provider.loadOrders(limit: 50),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                AppStrings.get('retry'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
                shadowColor: AppColors.primary?.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    AppColors.primary?.withOpacity(0.05) ?? Colors.blue.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 100.sp,
                color: AppColors.primary?.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 36.h),
            Text(
              AppStrings.get('noOrdersYet'),
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Start your culinary journey today!\nYour order history will appear here',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textLight,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.h),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
                shadowColor: AppColors.primary?.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text(
                    AppStrings.get('startOrdering'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, bool isWeb, OrderProvider provider) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isWeb ? 920 : double.infinity),
        child: RefreshIndicator(
          onRefresh: () => provider.loadOrders(limit: 50),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 48.w : 16.w,
              vertical: 24.h,
            ),
            itemCount: orders.length + (provider.hasMoreOrders ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              if (index == orders.length) {
                return _buildLoadMoreIndicator();
              }
              return _buildOrderCard(orders[index], isWeb, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Loading more orders...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isWeb, int index) {
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
                      _buildStatusBadge(order.status),
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
                        _buildInfoRow(
                          Icons.shopping_bag_outlined,
                          'Items',
                          '${order.items.length} ${order.items.length == 1 ? "item" : "items"}',
                        ),
                        SizedBox(height: 12.h),
                        _buildInfoRow(
                          Icons.store_outlined,
                          'Branch',
                          order.branchName ?? 'Main Store',
                        ),
                        SizedBox(height: 12.h),
                        _buildInfoRow(
                          _getDeliveryIcon(order.deliveryType),
                          'Type',
                          _getDeliveryTypeText(order.deliveryType),
                        ),
                        SizedBox(height: 12.h),
                        _buildInfoRow(
                          _getPaymentIcon(order.paymentMethod),
                          'Payment',
                          _getPaymentMethodText(order.paymentMethod),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
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