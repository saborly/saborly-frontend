import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';

import 'cart/widgets/cart_app_bar.dart';
import 'cart/widgets/cart_bottom_bar.dart';
import 'cart/widgets/cart_items_list.dart';
import 'cart/widgets/delivery_toggle.dart';
import 'cart/widgets/empty_cart_view.dart';
import 'cart/widgets/frequently_bought_section.dart';
import 'cart/widgets/order_summary_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _specialInstructionsController = TextEditingController();
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final checkoutProvider = context.read<CheckoutProvider>();


    // ✅ CRITICAL: Check delivery availability FIRST before loading anything else
    await checkoutProvider.checkDeliveryAvailability();

  });
}
  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && screenWidth > 600;
      DateTime? _lastPressedAt;
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
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

          // Show toast message
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

        // Exit app
        SystemNavigator.pop();
      },

      child: Scaffold(
        backgroundColor: isWeb ? const Color(0xFFF8F9FA) : (AppColors.background ?? Colors.white),
        appBar: const CartAppBar(),
        body:  Consumer2<CheckoutProvider, CartProvider>(
    builder: (context, checkoutProvider, cartProvider, child) {
            if (cartProvider.isEmpty) {
              return const EmptyCartView();
            }

            return isWeb ? _buildWebLayout(context, cartProvider,checkoutProvider) : _buildMobileLayout(context, cartProvider,checkoutProvider);
          },
        ),
      ),
    );
      },
    );
  }

  Widget _buildWebLayout(BuildContext context, CartProvider cartProvider,CheckoutProvider checkoutProvider) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildWebHeader(),
              // const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        DeliveryToggle(true),
                        const SizedBox(height: 24),
                        CartItemsList(cartProvider, true),
                        const SizedBox(height: 24),
                        // _buildSpecialInstructions(true),
                        const SizedBox(height: 24),
                        FrequentlyBoughtSection(cartProvider, true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 420,
                    child: OrderSummaryCard(
                      cartProvider,
                      true,
                      getSpecialInstructions: () => _specialInstructionsController.text.trim(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CartProvider cartProvider,CheckoutProvider checkoutProvider) {
    return Column(
      children: [
        DeliveryToggle(false),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CartItemsList(cartProvider, false),
                SizedBox(height: 16.h),
                // _buildSpecialInstructions(false),
                SizedBox(height: 16.h),
                FrequentlyBoughtSection(cartProvider, false),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
        CartBottomBar(
          cartProvider,
          getSpecialInstructions: () => _specialInstructionsController.text.trim(),
        ),
      ],
    );
  }
}
