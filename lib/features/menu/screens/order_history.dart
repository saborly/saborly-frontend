import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import 'order_history/widgets/order_history_app_bar.dart';
import 'order_history/widgets/order_history_loading_state.dart';
import 'order_history/widgets/order_history_error_state.dart';
import 'order_history/widgets/order_history_empty_state.dart';
import 'order_history/widgets/order_history_orders_list.dart';

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
      appBar: OrderHistoryAppBar(isWeb: isWeb),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const OrderHistoryLoadingState();
          }

          if (provider.error != null && provider.orders.isEmpty) {
            return OrderHistoryErrorState(
              error: provider.error!,
              onRetry: () => provider.loadOrders(limit: 50),
            );
          }

          if (provider.orders.isEmpty) {
            return const OrderHistoryEmptyState();
          }

          return OrderHistoryOrdersList(
            orders: provider.orders,
            isWeb: isWeb,
            provider: provider,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
}
