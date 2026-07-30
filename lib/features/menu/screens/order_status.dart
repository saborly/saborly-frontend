import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/order_provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/models/order.dart';
import 'order_status/widgets/order_error_state.dart';
import 'order_status/widgets/order_header.dart';
import 'order_status/widgets/order_delivery_time_card.dart';
import 'order_status/widgets/order_progress_card.dart';
import 'order_status/widgets/order_restaurant_info_card.dart';
import 'order_status/widgets/order_payment_info_card.dart';
import 'order_status/widgets/order_details_card.dart';
import 'order_status/widgets/order_bottom_bar.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  Timer? _pollingTimer;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  Order? _lastOrder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
      _startPolling();
      _startClock();
      _setupOrderListener();
    });
  }

  void _setupOrderListener() {
    // Listen to provider changes
    final provider = context.read<OrderProvider>();
    provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    final provider = context.read<OrderProvider>();
    final currentOrder = provider.currentOrder;

    // Check if order actually changed
    if (currentOrder != null && currentOrder != _lastOrder) {
      debugPrint('🔔 Provider changed - Order status: ${currentOrder.status}');
      _lastOrder = currentOrder;
      if (mounted) {
        setState(() {
          // Force rebuild
        });
      }
    }
  }

  @override
  void dispose() {
    final provider = context.read<OrderProvider>();
    provider.removeListener(_onProviderChanged);
    _pollingTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _loadOrder() {
    if (widget.orderId.isNotEmpty) {
      context.read<OrderProvider>().loadOrder(widget.orderId);
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel(); // Cancel any existing timer
    debugPrint('🔄 Starting order status polling (every 5 seconds)');
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        debugPrint('⚠️ Widget not mounted, stopping polling');
        timer.cancel();
        return;
      }

      final provider = context.read<OrderProvider>();
      final currentOrder = provider.currentOrder;

      debugPrint('⏰ Polling check - Current status: ${currentOrder?.status}');

      // Continue polling if order is active (not delivered/cancelled/refunded)
      if (currentOrder != null &&
          currentOrder.status != OrderStatus.delivered &&
          currentOrder.status != OrderStatus.cancelled &&
          currentOrder.status != OrderStatus.refunded) {
        // Load order in silent mode (won't show loading indicator)
        debugPrint('📡 Polling: Fetching order ${widget.orderId}...');
        provider.loadOrder(widget.orderId, silent: true).then((_) {
          debugPrint('✅ Polling: Order fetched successfully');
          // Force a rebuild after loading
          if (mounted) {
            setState(() {
              debugPrint('🔄 Polling: setState() called to force rebuild');
              // Trigger rebuild to show updated status
            });
          }
        }).catchError((error) {
          // Log error but don't stop polling
          debugPrint('⚠️ Error polling order status: $error');
        });
      } else {
        // Stop polling if order is in final state
        debugPrint(
            '✅ Order in final state (${currentOrder?.status}), stopping polling');
        timer.cancel();
      }
    });
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  // Responsive getters
  double get screenWidth => MediaQuery.of(context).size.width;
  bool get isMobile => screenWidth < mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
  bool get isDesktop => screenWidth >= desktopBreakpoint;

  double get contentMaxWidth {
    if (screenWidth >= 1400) return 1400;
    if (isDesktop) return 1200;
    return double.infinity;
  }

  double get horizontalPadding {
    if (screenWidth >= 1400) return 48;
    if (isDesktop) return 32;
    if (isTablet) return 24;
    return 16;
  }

  double get verticalPadding {
    if (isDesktop) return 40;
    if (isTablet) return 32;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? _lastPressedAt;

    return PopScope(
      canPop: kIsWeb,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || kIsWeb) return;

        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.get('pressBackAgain'),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.textDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: null,
        body: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            debugPrint(
                '🎨 Consumer rebuild - Status: ${provider.currentOrder?.status}, Loading: ${provider.isLoading}');

            if (provider.isLoading && provider.currentOrder == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null || provider.currentOrder == null) {
              return OrderErrorState(
                  error: provider.error ?? AppStrings.get('orderNotFound'));
            }

            final order = provider.currentOrder!;
            debugPrint(
                '📦 Building UI for order: ${order.id}, Status: ${order.status}');

            // Use order status and updatedAt as key to force rebuild when they change
            return RefreshIndicator(
              onRefresh: () async {
                debugPrint('🔄 Manual refresh triggered');
                await provider.loadOrder(widget.orderId);
              },
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: SingleChildScrollView(
                    key: ValueKey(
                        '${order.id}_${order.status}_${order.updatedAt.millisecondsSinceEpoch}'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout(order)
                        : _buildMobileTabletLayout(order),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: isMobile ? const OrderBottomBar() : null,
      ),
    );
  }

  Widget _buildDesktopLayout(Order order) {
    return Column(
      children: [
        OrderHeader(order: order, isDesktop: isDesktop, isTablet: isTablet),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  OrderDeliveryTimeCard(
                    order: order,
                    currentTime: _currentTime,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 32),
                  OrderProgressCard(
                      order: order, isDesktop: isDesktop, isTablet: isTablet),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  OrderRestaurantInfoCard(
                      order: order, isDesktop: isDesktop, isTablet: isTablet),
                  const SizedBox(height: 24),
                  OrderPaymentInfoCard(
                      order: order, isDesktop: isDesktop, isTablet: isTablet),
                  const SizedBox(height: 24),
                  OrderDetailsCard(
                      order: order, isDesktop: isDesktop, isTablet: isTablet),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: AppStrings.home,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMobileTabletLayout(Order order) {
    return Column(
      children: [
        OrderHeader(order: order, isDesktop: isDesktop, isTablet: isTablet),
        const SizedBox(height: 24),
        OrderDeliveryTimeCard(
          order: order,
          currentTime: _currentTime,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
        const SizedBox(height: 24),
        OrderProgressCard(
            order: order, isDesktop: isDesktop, isTablet: isTablet),
        const SizedBox(height: 24),
        OrderRestaurantInfoCard(
            order: order, isDesktop: isDesktop, isTablet: isTablet),
        const SizedBox(height: 24),
        OrderPaymentInfoCard(
            order: order, isDesktop: isDesktop, isTablet: isTablet),
        const SizedBox(height: 24),
        OrderDetailsCard(
            order: order, isDesktop: isDesktop, isTablet: isTablet),
        SizedBox(height: isMobile ? 100 : 40),
      ],
    );
  }
}
