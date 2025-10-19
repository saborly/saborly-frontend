import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/order_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.orderId.isNotEmpty) {
        context.read<OrderProvider>().loadOrder(widget.orderId);
      } else {
        context.read<OrderProvider>().notifyListeners();
      }
    });
  }

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null || provider.currentOrder == null) {
return _buildErrorState(provider.error ?? AppStrings.get('orderNotFound'));

          }

          final order = provider.currentOrder!;
          
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: isDesktop 
                    ? _buildDesktopLayout(order) 
                    : _buildMobileTabletLayout(order),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: isMobile ? _buildBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.go(AppRoutes.orders),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textDark,
          size: 20,
        ),
      ),
      title: Text(
        AppStrings.orderStatus,
        style: TextStyle(
          fontSize: isDesktop ? 24 : 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
      ),
      actions: isDesktop ? [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined, size: 20),
            label: Text(
              AppStrings.home,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ] : null,
    );
  }

  Widget _buildDesktopLayout(Order order) {
    return Column(
      children: [
        // Header section
        _buildOrderHeader(order),
        const SizedBox(height: 40),
        
        // Main content in two columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Progress and delivery info
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
            
            // Right column: Restaurant, payment, and order details
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
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
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
  final bool isPickupOrder = order.deliveryType == DeliveryType.pickup || 
                             order.deliveryType == DeliveryType.delivery;
  
  return Container(
    padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 40 : 32)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          isPickupOrder ?  AppStrings.get("readyIn"): AppStrings.estimatedDelivery,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
         AppStrings.get('estimatedTime'),
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
                isPickupOrder ? Icons.shopping_bag_rounded : Icons.schedule_rounded,
                color: Colors.white,
                size: isDesktop ? 20 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                isPickupOrder ? AppStrings.get("readyIn") : AppStrings.getYourOrder,
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
  // Determine if this is a pickup/shop order or delivery order
  final bool isPickupOrder = order.deliveryType == DeliveryType.pickup || 
                             order.deliveryType == DeliveryType.delivery;
  
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
        
        // Common steps for all orders
        _buildProgressStep(
          AppStrings.orderPlaced,
          true,
          isFirst: true,
        ),
        _buildProgressStep(
          AppStrings.orderConfirmed,
          order.status.index >= OrderStatus.confirmed.index,
        ),
        _buildProgressStep(
          AppStrings.preparing,
          order.status.index >= OrderStatus.preparing.index,
        ),
        _buildProgressStep(
          AppStrings.ready,
          order.status.index >= OrderStatus.ready.index,
        ),
        
        // Conditional steps based on order type
        if (isPickupOrder) ...[
          // For pickup orders: show "Ready for Pickup" or "Picked Up"
          _buildProgressStep(
             order.status == OrderStatus.shop ? AppStrings.get('collected') : AppStrings.get('readyForPickup'),
    order.status == OrderStatus.pickup || order.status == OrderStatus.shop,
    isLast: true,
          ),
        ] else ...[
          // For delivery orders: show "Out for Delivery" and "Delivered"
          _buildProgressStep(
            AppStrings.get('outForDelivery'),
    order.status.index >= OrderStatus.outForDelivery.index,
          ),
          _buildProgressStep(
    AppStrings.get('delivered'),
            order.status == OrderStatus.delivered,
            isLast: true,
          ),
        ],
      ],
    ),
  );
}

  Widget _buildProgressStep(String title, bool isCompleted, {bool isFirst = false, bool isLast = false}) {
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
                          colors: [AppColors.primary, AppColors.primaryDark],
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
                        colors: [AppColors.primary, AppColors.primaryDark],
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
                    color: AppColors.primary.withOpacity(0.3),
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
                          colors: [AppColors.primary, AppColors.primaryDark],
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
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '40 ${AppStrings.minutes}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delivery_dining_rounded,
                              size: 16,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.deliveryType.name=='delivery'?AppStrings.get('delivery'):AppStrings.get('pickup'),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
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
              label:  Text(
  AppStrings.get('callRestaurant'),
                style: TextStyle(
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
_buildInfoRow(AppStrings.get('paymentStatus'), _getPaymentStatusText(order.paymentStatus)),

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
          
          if (order.items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fastfood_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
  AppStrings.get('emptyOrderItems'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
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
}
