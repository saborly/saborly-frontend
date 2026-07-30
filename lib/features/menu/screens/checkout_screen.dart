import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import '../../../shared/models/order.dart';
import 'checkout/widgets/address_selection_dialog.dart';
import 'checkout/widgets/bottom_bar.dart';
import 'checkout/widgets/branch_info.dart';
import 'checkout/widgets/cart_summary.dart';
import 'checkout/widgets/checkout_app_bar.dart';
import 'checkout/widgets/delivery_address_section.dart';
import 'checkout/widgets/delivery_type_selector.dart';
import 'checkout/widgets/pickup_time_preference.dart';
import 'checkout/widgets/restaurant_closed_banner.dart';
import 'checkout/widgets/web_checkout_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _firstOrderDiscountEligible = false;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final checkoutProvider = context.read<CheckoutProvider>();
    final cartProvider = context.read<CartProvider>();

    // Link CartProvider to CheckoutProvider
    checkoutProvider.setCartProvider(cartProvider);

    // ✅ CRITICAL: Check delivery availability AND restaurant hours FIRST
    await checkoutProvider.checkDeliveryAvailability();

    // ✅ NEW: Start monitoring restaurant hours
    checkoutProvider.startHoursMonitoring();

    // Load branches and addresses
    checkoutProvider.loadBranches();
    await checkoutProvider.loadCurrentBranchCoords();
    await checkoutProvider.loadSavedAddresses();

    // If the user hasn't picked/saved an address yet, prefill from the
    // location they confirmed on the branch-selection screen.
    checkoutProvider.seedFromDetectedLocation();

    // Update delivery fee based on current state
    checkoutProvider.updateDeliveryFee(cartProvider.subtotal);

    // Check first-order mobile discount eligibility (skip on web)
    if (!kIsWeb) {
      final deviceId = context.read<OffersProvider>().deviceId;
      if (deviceId != null && deviceId.isNotEmpty) {
        final result = await ApiService().checkFirstOrderDiscount(deviceId);
        if (mounted) {
          setState(() {
            _firstOrderDiscountEligible = result['eligible'] == true;
          });
        }
      }
    }
  });
}

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
 Widget build(BuildContext context) {
    final paymentProvider = context.read<PaymentProvider>();
    paymentProvider.initialize(
      orderProvider: context.read<OrderProvider>(),
      cartProvider: context.read<CartProvider>(),
      checkoutProvider: context.read<CheckoutProvider>(),
      offersProvider: context.read<OffersProvider>(),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final maxWidth = isWeb ? 1400.0 : double.infinity;

    return Scaffold(
      backgroundColor: kIsWeb ? const Color(0xFFF8F9FA) : AppColors.background,
      appBar: const CheckoutAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
        ),
      ),
      bottomNavigationBar: isWeb ? null : const BottomBar(),
    );
  }

Widget _buildWebLayout() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        children: [
          // ✅ NEW: Restaurant closed banner
          const RestaurantClosedBanner(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    const DeliveryTypeSelector(),
                    const SizedBox(height: 24),
                    Consumer<CheckoutProvider>(
                      builder: (context, checkoutProvider, child) {
                        if (checkoutProvider.deliveryType == DeliveryType.delivery &&
                            checkoutProvider.isDeliveryEnabled) {
                          return Column(
                            children: [
                              DeliveryAddressSection(
                                onShowAddressSelectionDialog: () =>
                                    showAddressSelectionDialog(context),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }
                        return const Column(
                          children: [
                            BranchInfo(),
                            SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                    const PickupTimePreference(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              SizedBox(
                width: 420,
                child: Column(
                  children: [
                    CartSummary(firstOrderDiscountEligible: _firstOrderDiscountEligible),
                    const SizedBox(height: 24),
                    const WebCheckoutButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


Widget _buildMobileLayout() {
  return SingleChildScrollView(
    child: Column(
      children: [
        // ✅ NEW: Restaurant closed banner
        const RestaurantClosedBanner(),

        const DeliveryTypeSelector(),
        Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            if (checkoutProvider.deliveryType == DeliveryType.delivery &&
                checkoutProvider.isDeliveryEnabled) {
              return DeliveryAddressSection(
                onShowAddressSelectionDialog: () =>
                    showAddressSelectionDialog(context),
              );
            }
            return const BranchInfo();
          },
        ),
        const PickupTimePreference(),
        CartSummary(firstOrderDiscountEligible: _firstOrderDiscountEligible),
        SizedBox(height: 100.h),
      ],
    ),
  );
}
}
