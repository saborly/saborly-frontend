import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import '../../../../../shared/models/order.dart';
import 'order_card.dart';
import 'order_load_more_indicator.dart';

class OrderHistoryOrdersList extends StatelessWidget {
  const OrderHistoryOrdersList({
    super.key,
    required this.orders,
    required this.isWeb,
    required this.provider,
    required this.scrollController,
  });

  final List<Order> orders;
  final bool isWeb;
  final OrderProvider provider;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isWeb ? 920 : double.infinity),
        child: RefreshIndicator(
          onRefresh: () => provider.loadOrders(limit: 50),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 48.w : 16.w,
              vertical: 24.h,
            ),
            itemCount: orders.length + (provider.hasMoreOrders ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              if (index == orders.length) {
                return const OrderLoadMoreIndicator();
              }
              return OrderCard(order: orders[index], isWeb: isWeb, index: index);
            },
          ),
        ),
      ),
    );
  }
}
