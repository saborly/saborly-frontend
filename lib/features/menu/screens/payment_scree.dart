import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/checkout_provider.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:soely/features/providers/payment_provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.initialize(
        orderProvider: context.read<OrderProvider>(),
        cartProvider: context.read<CartProvider>(),
        checkoutProvider: context.read<CheckoutProvider>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    return Consumer<LanguageService>(builder: (context, languageService, _) {
      return Scaffold(
        backgroundColor: AppColors.background ?? const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: Consumer2<PaymentProvider, CheckoutProvider>(
          builder: (context, paymentProvider, checkoutProvider, child) {
            return Center(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: isWeb ? 900 : double.infinity),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 48.w : 16.w,
                    vertical: isWeb ? 48.h : 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Delivery Type Info Banner
                      _buildDeliveryTypeBanner(checkoutProvider),
                      SizedBox(height: 24.h),

                      // Main Content
                      isWeb
                          ? _buildWebLayout(paymentProvider, checkoutProvider)
                          : _buildMobileLayout(
                              paymentProvider, checkoutProvider),

                      if (!isWeb) SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: !isWeb ? _buildBottomBar() : null,
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppStrings.selectPaymentMethod,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDeliveryTypeBanner(CheckoutProvider checkoutProvider) {
    final isPickup = checkoutProvider.deliveryType == DeliveryType.pickup;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPickup
              ? [
                  AppColors.success?.withOpacity(0.15) ??
                      Colors.green.withOpacity(0.15),
                  AppColors.success?.withOpacity(0.05) ??
                      Colors.green.withOpacity(0.05),
                ]
              : [
                  AppColors.primary?.withOpacity(0.15) ??
                      Colors.blue.withOpacity(0.15),
                  AppColors.primary?.withOpacity(0.05) ??
                      Colors.blue.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPickup
              ? AppColors.success?.withOpacity(0.3) ??
                  Colors.green.withOpacity(0.3)
              : AppColors.primary?.withOpacity(0.3) ??
                  Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isPickup ? AppColors.success : AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isPickup ? Icons.store : Icons.delivery_dining,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPickup
                      ? AppStrings.get('pickupOrder')
                      : AppStrings.get('deliveryOrder'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isPickup
                      ? AppStrings.get('payAtShopDescription')
                      : AppStrings.get('choosePaymentDelivery'),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(
      PaymentProvider provider, CheckoutProvider checkoutProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Methods Section
        Expanded(
          flex: 2,
          child: _buildPaymentCard(provider, checkoutProvider, true),
        ),

        SizedBox(width: 32.w),

        // Summary Section
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildPaymentSummaryCard(provider, checkoutProvider),
              SizedBox(height: 24.h),
              _buildConfirmButton(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      PaymentProvider provider, CheckoutProvider checkoutProvider) {
    return _buildPaymentCard(provider, checkoutProvider, false);
  }

  Widget _buildPaymentSummaryCard(
      PaymentProvider provider, CheckoutProvider checkoutProvider) {
    final selectedMethod = provider.selectedPaymentMethod;
    final isPickup = checkoutProvider.deliveryType == DeliveryType.pickup;
    final codType = provider.codPaymentType;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('paymentSummary'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 24.h),

          _buildSummaryRow(
            AppStrings.get('orderType'),
            isPickup ? AppStrings.get('pickup') : AppStrings.get('delivery'),
          ),

          SizedBox(height: 12.h),

          _buildSummaryRow(
            AppStrings.get('paymentMethod'),
            _getPaymentMethodName(selectedMethod),
            isHighlighted: true,
          ),

          // Show COD payment type if applicable
          if (selectedMethod == PaymentMethod.cashOnDelivery &&
              codType != null) ...[
            SizedBox(height: 12.h),
            _buildSummaryRow(
              AppStrings.get('paymentType'),
              codType == CodPaymentType.cash
                  ? AppStrings.get('cash')
                  : AppStrings.get('card'),
              isHighlighted: true,
            ),
          ],
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (isPickup ? AppColors.success : AppColors.primary)
                      ?.withOpacity(0.05) ??
                  Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isPickup ? AppColors.success : AppColors.primary)
                        ?.withOpacity(0.2) ??
                    Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20.sp,
                  color: isPickup ? AppColors.success : AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isPickup
                        ? AppStrings.get('payAtShopCounter')
                        : codType == CodPaymentType.cash
                            ? AppStrings.get('payWithCashOnDelivery')
                            : AppStrings.get('payWithCardOnDelivery'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isPickup ? AppColors.success : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName(PaymentMethod? method) {
    if (method == null) return 'None Selected';
    switch (method) {
      case PaymentMethod.shop:
        return 'Shop Payment';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.card:
        return 'Card';
      default:
        return 'None Selected';
    }
  }

  Widget _buildPaymentCard(
      PaymentProvider provider, CheckoutProvider checkoutProvider, bool isWeb) {
    final isPickup = checkoutProvider.deliveryType == DeliveryType.pickup;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              isPickup
                  ? AppStrings.get('shopPayment')
                  : AppStrings.get('deliveryPayment'),
              isPickup ? AppColors.success : AppColors.primary,
            ),
            SizedBox(height: 20.h),
            if (isPickup)
              _buildPaymentMethodCard(
                AppStrings.get('payAtShop'),
                Icons.store_outlined,
                AppColors.success ?? Colors.green,
                PaymentMethod.shop,
                provider,
                isAvailable: true,
                description: AppStrings.get('payAtShopDescription'),
              )
            else ...[
              // COD Payment Type Selection for Delivery
              _buildSectionHeader(
                  AppStrings.get('choosePaymentType'), AppColors.primary),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildCodTypeCard(
                      AppStrings.get('cash'),
                      Icons.payments_outlined,
                      CodPaymentType.cash,
                      provider,
                      AppStrings.get('payWithCash'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildCodTypeCard(
                      AppStrings.get('card'),
                      Icons.credit_card,
                      CodPaymentType.card,
                      provider,
                      AppStrings.get('payWithCard'),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 32.h),
            Divider(
              color: AppColors.border?.withOpacity(0.3) ??
                  Colors.grey.withOpacity(0.2),
              height: 1,
            ),
            SizedBox(height: 32.h),
            _buildSectionHeader(
                AppStrings.get('otherOptionsComingSoon'), AppColors.textLight),
            SizedBox(height: 20.h),
            _buildPaymentMethodCard(
              AppStrings.get('paypal'),
              Icons.account_balance_wallet_outlined,
              const Color(0xFF0070BA),
              PaymentMethod.paypal,
              provider,
              isAvailable: false,
              description: AppStrings.get('paypalDescription'),
            ),
            SizedBox(height: 16.h),
            _buildPaymentMethodCard(
              AppStrings.get('stripe'),
              Icons.credit_card_outlined,
              const Color(0xFF635BFF),
              PaymentMethod.stripe,
              provider,
              isAvailable: false,
              description: AppStrings.get('stripeDescription'),
            ),
            SizedBox(height: 16.h),
            _buildPaymentMethodCard(
              AppStrings.get('card'),
              Icons.credit_card,
              const Color(0xFF1A1F71),
              PaymentMethod.card,
              provider,
              isAvailable: false,
              description: AppStrings.get('cardDescription'),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: COD Payment Type Card
  Widget _buildCodTypeCard(
    String name,
    IconData icon,
    CodPaymentType type,
    PaymentProvider provider,
    String description,
  ) {
    final isSelected = provider.codPaymentType == type;
    final color = AppColors.primary ?? Colors.blue;

    return GestureDetector(
      onTap: () => provider.setCodPaymentType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : Colors.grey.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? color
                : (AppColors.border?.withOpacity(0.3) ??
                    Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(isSelected ? 0.2 : 0.1),
                    color.withOpacity(isSelected ? 0.1 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textLight?.withOpacity(0.8) ??
                    Colors.grey.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String name,
    IconData icon,
    Color color,
    PaymentMethod method,
    PaymentProvider provider, {
    required bool isAvailable,
    String? description,
  }) {
    final isSelected = provider.selectedPaymentMethod == method && isAvailable;

    return GestureDetector(
      onTap: isAvailable ? () => provider.selectPaymentMethod(method) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : (isAvailable
                  ? Colors.grey.withOpacity(0.02)
                  : Colors.grey.withOpacity(0.01)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? color
                : (AppColors.border?.withOpacity(0.3) ??
                    Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.4,
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30.sp,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? AppColors.textDark
                                : AppColors.textLight,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.textLight?.withOpacity(0.12) ??
                                  Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              AppStrings.get('comingSoon'),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textLight?.withOpacity(0.8) ??
                              Colors.grey.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(PaymentProvider provider) {
    return CustomButton(
      text: AppStrings.confirm,
      isLoading: provider.isProcessing,
      onPressed: () => _processPayment(provider),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            return CustomButton(
              text: AppStrings.confirm,
              isLoading: provider.isProcessing,
              onPressed: () => _processPayment(provider),
            );
          },
        ),
      ),
    );
  }

  Future<void> _processPayment(PaymentProvider provider) async {
    final success = await provider.processPayment();

    if (success && mounted) {
      if (provider.orderId != null) {
        context.goNamed(
          'order-status',
          pathParameters: {'orderId': provider.orderId!},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('errorFailedToLoadOrder'))),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppStrings.get('paymentFailed')
                .replaceAll('{error}', provider.error ?? ''))),
      );
    }
  }
}
