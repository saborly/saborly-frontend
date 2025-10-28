import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/models/order.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
      _startPolling();
      _startClock();
    });
  }

  @override
  void dispose() {
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
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        final provider = context.read<OrderProvider>();
        if (provider.currentOrder != null &&
            provider.currentOrder!.status != OrderStatus.delivered &&
            provider.currentOrder!.status != OrderStatus.cancelled &&
            provider.currentOrder!.status != OrderStatus.refunded) {
          provider.loadOrder(widget.orderId, silent: true);
        } else {
          timer.cancel();
        }
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

  String _calculateTimeRemaining(Order order) {
    if (order.status == OrderStatus.delivered || 
        order.status == OrderStatus.cancelled) {
      return '0';
    }

    if (order.estimatedDeliveryTime == null) {
      return '30-40';
    }

    final difference = order.estimatedDeliveryTime!.difference(_currentTime);
    
    if (difference.isNegative) {
      return '0';
    }

    final minutes = difference.inMinutes;
    if (minutes <= 0) {
      return '0';
    } else if (minutes <= 5) {
      return '5';
    } else if (minutes <= 40) {
      return '$minutes';
    } else {
      return '30-40';
    }
  }

  // Responsive getters
  double get screenWidth => MediaQuery.of(context).size.width;
  bool get isMobile => screenWidth < mobileBreakpoint;
  bool get isTablet => screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
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
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
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
            if (provider.isLoading && provider.currentOrder == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null || provider.currentOrder == null) {
              return _buildErrorState(provider.error ?? AppStrings.get('orderNotFound'));
            }

            final order = provider.currentOrder!;
            
            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadOrder(widget.orderId);
              },
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: SingleChildScrollView(
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
        bottomNavigationBar: isMobile ? _buildBottomBar() : null,
      ),
    );
  }

  Widget _buildDesktopLayout(Order order) {
    return Column(
      children: [
        _buildOrderHeader(order),
        const SizedBox(height: 40),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildDeliveryTime(order),
                  const SizedBox(height: 32),
                  _buildOrderProgress(order),
                ],
              ),
            ),
            
            const SizedBox(width: 40),
            
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildRestaurantInfo(order),
                  const SizedBox(height: 24),
                  _buildPaymentInfo(order),
                  const SizedBox(height: 24),
                  _buildOrderDetails(order),
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
        _buildOrderHeader(order),
        const SizedBox(height: 24),
        _buildDeliveryTime(order),
        const SizedBox(height: 24),
        _buildOrderProgress(order),
        const SizedBox(height: 24),
        _buildRestaurantInfo(order),
        const SizedBox(height: 24),
        _buildPaymentInfo(order),
        const SizedBox(height: 24),
        _buildOrderDetails(order),
        SizedBox(height: isMobile ? 100 : 40),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: CustomButton(
                text: AppStrings.get('goBack'),
                onPressed: () => context.go(AppRoutes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
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
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
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
            _formatDate(order.createdAt),
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

  Widget _buildDeliveryTime(Order order) {
    final bool isPickupOrder = order.deliveryType == DeliveryType.pickup;
    final timeRemaining = _calculateTimeRemaining(order);
    final isDelivered = order.status == OrderStatus.delivered;
    final isPickedUp = order.status == OrderStatus.pickup || order.status == OrderStatus.shop;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 40 : 32)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDelivered 
              ? [Colors.green, Colors.green.shade700]
              : isPickedUp && isPickupOrder
                  ? [const Color(0xFF388E3C), const Color(0xFF2E7D32)]
                  : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDelivered ? Colors.green : AppColors.primary).withOpacity(0.4),
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
                : (isPickedUp && isPickupOrder)
                    ? AppStrings.get('pickedUp')
                    : (isPickupOrder ? AppStrings.get("readyIn") : AppStrings.estimatedDelivery),
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (isDelivered || (isPickedUp && isPickupOrder)) ? '✓' : '$timeRemaining min',
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
                  (isDelivered || (isPickedUp && isPickupOrder))
                      ? Icons.check_circle_rounded
                      : (isPickupOrder ? Icons.shopping_bag_rounded : Icons.schedule_rounded),
                  color: Colors.white,
                  size: isDesktop ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  (isDelivered )
                      ? AppStrings.get('orderCompleted')
                      : (isPickupOrder ? AppStrings.get("readyIn") : AppStrings.getYourOrder),
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

  Widget _buildOrderProgress(Order order) {
    final bool isPickupOrder = order.deliveryType == DeliveryType.pickup;
    
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPickupOrder ? Icons.shopping_bag_rounded : Icons.local_shipping_rounded,
                  color: AppColors.primary,
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
          
          if (isPickupOrder) ...[
            // Pickup order flow
            _buildProgressStep(
              AppStrings.orderPlaced,
              const Color(0xFFFF6F00),
              order.status.index >= OrderStatus.pending.index,
              isFirst: true,
            ),
            _buildProgressStep(
              AppStrings.get('orderConfirmed'),
              const Color(0xFF1976D2),
              order.status.index >= OrderStatus.confirmed.index,
            ),
            _buildProgressStep(
              AppStrings.get('preparing'),
              const Color(0xFF7B1FA2),
              order.status.index >= OrderStatus.preparing.index,
            ),
            _buildProgressStep(
              AppStrings.ready,
              const Color(0xFF0097A7),
              order.status.index >= OrderStatus.ready.index,
            ),
            _buildProgressStep(
              AppStrings.get('delivered'),
              const Color(0xFF388E3C),
              order.status == OrderStatus.delivered || order.status == OrderStatus.shop,
              isLast: true,
            ),
          ] else ...[
            // Delivery order flow
            _buildProgressStep(
              AppStrings.orderPlaced,
              const Color(0xFFFF6F00),
              order.status.index >= OrderStatus.pending.index,
              isFirst: true,
            ),
            _buildProgressStep(
              AppStrings.get('orderConfirmed'),
              const Color(0xFF1976D2),
              order.status.index >= OrderStatus.confirmed.index,
            ),
            _buildProgressStep(
              AppStrings.preparing,
              const Color(0xFF7B1FA2),
              order.status.index >= OrderStatus.preparing.index,
            ),
            _buildProgressStep(
              AppStrings.ready,
              const Color(0xFF0097A7),
              order.status.index >= OrderStatus.ready.index,
            ),
            _buildProgressStep(
              AppStrings.get('outForDelivery'),
              const Color(0xFF303F9F),
              order.status.index >= OrderStatus.outForDelivery.index,
            ),
            _buildProgressStep(
              AppStrings.get('delivered'),
              const Color(0xFF2E7D32),
              order.status == OrderStatus.delivered,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    String title, 
    Color statusColor,
    bool isCompleted, 
    {bool isFirst = false, bool isLast = false}
  ) {
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
                boxShadow: isCompleted ? [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
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

  Widget _buildRestaurantInfo(Order order) {
    const String phoneNumber = '+34932112072';

    Future<void> makePhoneCall(String phoneNumber) async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.get('callError').replaceAll('{phoneNumber}', phoneNumber)),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.get('callErrorGeneric').replaceAll('{error}', e.toString())),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isDesktop ? 80 : 70,
                height: isDesktop ? 80 : 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: isDesktop ? 36 : 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.branchName ?? AppStrings.boshundhoraRA,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.get('restaurantAddress'),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => makePhoneCall(phoneNumber),
              icon: const Icon(Icons.phone_rounded, size: 20),
              label: Text(
                AppStrings.get('callRestaurant'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(Order order) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.get('paymentInfo'),
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(AppStrings.get('paymentMethod'), _getPaymentMethodText(order.paymentMethod)),
          const SizedBox(height: 12),
_buildInfoRow(
  AppStrings.get('paymentStatus'),
  _getPaymentStatusText(
    order.status == OrderStatus.delivered
        ? PaymentStatus.paid
        : order.paymentStatus,
  ),
),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.orderDetails,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          ...order.items.map((cartItem) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cartItem.foodItem.isVeg ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.circle,
                    color: cartItem.foodItem.isVeg ? Colors.green : Colors.red,
                    size: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${cartItem.quantity}x ${cartItem.foodItem.name}',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${AppStrings.currency}${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 20),
          Divider(color: AppColors.divider, thickness: 1, height: 1),
          const SizedBox(height: 16),
          _buildInfoRow(AppStrings.get('subtotal'), '${AppStrings.get('currency')}${order.subtotal.toStringAsFixed(2)}'),
          if (order.deliveryFee > 0)
            _buildInfoRow(AppStrings.get('deliveryFee'), '${AppStrings.get('currency')}${order.deliveryFee.toStringAsFixed(2)}'),
          if (order.tax > 0)
            _buildInfoRow(AppStrings.get('tax'), '${AppStrings.get('currency')}${order.tax.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider, thickness: 2, height: 2),
          const SizedBox(height: 16),
          _buildInfoRow(
            AppStrings.get('total'),
            '${AppStrings.get('currency')}${order.total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textLight,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: AppStrings.home,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

  String _getPaymentMethodText(PaymentMethod method) {
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

  String _getPaymentStatusText(PaymentStatus status) {
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

  Color _getStatusColor(OrderStatus status) {
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
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32); // Forest Green - Delivered
      case OrderStatus.cancelled:
        return const Color(0xFFC62828); // Dark Red - Cancelled
      case OrderStatus.refunded:
        return const Color(0xFF616161); // Dark Grey - Refunded
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
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
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      case OrderStatus.refunded:
        return Icons.currency_exchange_rounded;
    }
  }
}