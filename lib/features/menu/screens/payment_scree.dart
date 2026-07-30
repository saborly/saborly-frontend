import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import 'payment/widgets/payment_app_bar.dart';
import 'payment/widgets/delivery_type_banner.dart';
import 'payment/widgets/payment_card.dart';
import 'payment/widgets/payment_summary_card.dart';
import 'payment/widgets/confirm_button.dart';
import 'payment/widgets/payment_bottom_bar.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    final paymentProvider = context.read<PaymentProvider>();
    paymentProvider.initialize(
      orderProvider: context.read<OrderProvider>(),
      cartProvider: context.read<CartProvider>(),
      checkoutProvider: context.read<CheckoutProvider>(),
      offersProvider: context.read<OffersProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    return Consumer<LanguageService>(builder: (context, languageService, _) {
      return Scaffold(
        backgroundColor: AppColors.background ?? const Color(0xFFF8F9FA),
        appBar: const PaymentAppBar(),
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
                      DeliveryTypeBanner(checkoutProvider: checkoutProvider),
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
        bottomNavigationBar:
            !isWeb ? PaymentBottomBar(onConfirm: _processPayment) : null,
      );
    });
  }

  Widget _buildWebLayout(
      PaymentProvider provider, CheckoutProvider checkoutProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Methods Section
        Expanded(
          flex: 2,
          child: PaymentCard(
            provider: provider,
            checkoutProvider: checkoutProvider,
            isWeb: true,
          ),
        ),

        SizedBox(width: 32.w),

        // Summary Section
        Expanded(
          flex: 1,
          child: Column(
            children: [
              PaymentSummaryCard(
                provider: provider,
                checkoutProvider: checkoutProvider,
              ),
              SizedBox(height: 24.h),
              ConfirmButton(provider: provider, onConfirm: _processPayment),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      PaymentProvider provider, CheckoutProvider checkoutProvider) {
    return PaymentCard(
      provider: provider,
      checkoutProvider: checkoutProvider,
      isWeb: false,
    );
  }

  Future<void> _processPayment(PaymentProvider provider) async {
    final success = await provider.processPayment();

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.get('orderPlacedSuccessfully'),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );

      // Navigate to order status
      if (provider.orderId != null) {
        // Small delay to allow snackbar to be seen
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.goNamed(
            'order-status',
            pathParameters: {'orderId': provider.orderId!},
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    AppStrings.get('errorFailedToLoadOrder') ??
                    'Failed to load order details',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  provider.error ??
                  AppStrings.get('paymentFailed') ??
                  'Payment failed. Please try again.',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }
}
