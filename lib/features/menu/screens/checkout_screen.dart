import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/api_service.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/checkout_provider.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:soely/features/providers/payment_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checkoutProvider = context.read<CheckoutProvider>();
      final cartProvider = context.read<CartProvider>();

      // CRITICAL FIX: Link CartProvider to CheckoutProvider
      checkoutProvider.setCartProvider(cartProvider);

      // Load branches and addresses
      checkoutProvider.loadBranches();
      checkoutProvider.loadSavedAddresses();

      // CRITICAL FIX: Update delivery fee based on current state
      checkoutProvider.updateDeliveryFee(cartProvider.subtotal);
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.read<PaymentProvider>();
    paymentProvider.initialize(
      orderProvider: context.read<OrderProvider>(),
      cartProvider: context.read<CartProvider>(),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final maxWidth = isWeb ? 1400.0 : double.infinity;

    return Scaffold(
      backgroundColor: kIsWeb ? const Color(0xFFF8F9FA) : AppColors.background,
      appBar: _buildAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
        ),
      ),
      bottomNavigationBar: isWeb ? null : _buildBottomBar(),
    );
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
        AppStrings.checkout,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  _buildDeliveryTypeSelector(),
                  const SizedBox(height: 24),
                  Consumer<CheckoutProvider>(
                    builder: (context, checkoutProvider, child) {
                      if (checkoutProvider.deliveryType ==
                          DeliveryType.delivery) {
                        return Column(
                          children: [
                            _buildDeliveryAddressSection(),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildBranchInfo(),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  _buildPickupTimePreference(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            SizedBox(
              width: 420,
              child: Column(
                children: [
                  _buildCartSummary(),
                  const SizedBox(height: 24),
                  _buildWebCheckoutButton(),
                ],
              ),
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
          _buildDeliveryTypeSelector(),
          Consumer<CheckoutProvider>(
            builder: (context, checkoutProvider, child) {
              if (checkoutProvider.deliveryType == DeliveryType.delivery) {
                return _buildDeliveryAddressSection();
              }
              return _buildBranchInfo();
            },
          ),
          _buildPickupTimePreference(),
          _buildCartSummary(),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildDeliveryTypeSelector() {
    final isWeb = kIsWeb;
    return Consumer2<CheckoutProvider, CartProvider>(
      builder: (context, checkoutProvider, cartProvider, child) {
        final isDelivery =
            checkoutProvider.deliveryType == DeliveryType.delivery;

        return Container(
          margin: isWeb ? null : EdgeInsets.all(16.w),
          padding: isWeb ? const EdgeInsets.all(6) : EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 16 : 14.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: isWeb ? 16 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  AppStrings.delivery,
                  Icons.delivery_dining,
                  isDelivery,
                  isWeb,
                  () {
                    checkoutProvider.setDeliveryType(DeliveryType.delivery);
                    // CRITICAL FIX: Update delivery fee when switching to delivery
                    checkoutProvider.updateDeliveryFee(cartProvider.subtotal);
                  },
                ),
              ),
              SizedBox(width: isWeb ? 8 : 6.w),
              Expanded(
                child: _buildTypeButton(
                  AppStrings.takeaway,
                  Icons.shopping_bag,
                  !isDelivery,
                  isWeb,
                  () {
                    checkoutProvider.setDeliveryType(DeliveryType.pickup);
                    // Delivery fee is already set to 0 in setDeliveryType
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(
    String text,
    IconData icon,
    bool isSelected,
    bool isWeb,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 18 : 14.h,
          horizontal: isWeb ? 16 : 12.w,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(isWeb ? 12 : 10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textMedium,
              size: isWeb ? 22 : 20.sp,
            ),
            SizedBox(width: isWeb ? 10 : 8.w),
            Text(
              text,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMedium,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    final isWeb = kIsWeb;
    return Consumer2<CheckoutProvider, CartProvider>(
      builder: (context, checkoutProvider, cartProvider, child) {
        return Container(
          margin: isWeb ? null : EdgeInsets.all(16.w),
          padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 20.r : 16.r),
            border: isWeb
                ? Border.all(color: Colors.grey.shade100, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isWeb ? 0.03 : 0.04),
                blurRadius: isWeb ? 24 : 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: isWeb ? 24.sp : 22.sp,
                    ),
                  ),
                  SizedBox(width: isWeb ? 16.w : 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.delivery,
                          style: TextStyle(
                            fontSize: isWeb ? 20.sp : 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        if (checkoutProvider.selectedAddress == null)
                          Text(
                            AppStrings.get('chooseDeliveryAddress'),
                            style: TextStyle(
                              fontSize: isWeb ? 14.sp : 13.sp,
                              color: AppColors.textLight,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 24.h : 20.h),

              if (checkoutProvider.selectedAddress != null) ...[
                // Selected Address Card
                _buildAddressCard(checkoutProvider.selectedAddress!, isWeb),
                SizedBox(height: isWeb ? 20.h : 16.h),

                // Delivery Info Banner
                if (checkoutProvider.deliveryDistance != null)
                  _buildDeliveryInfoBanner(
                    checkoutProvider,
                    cartProvider,
                    isWeb,
                  ),

                SizedBox(height: isWeb ? 16.h : 12.h),

                // Change Address Button
                TextButton.icon(
                  onPressed: _showAddressSelectionDialog,
                  icon: Icon(
                    Icons.edit_location_alt_rounded,
                    size: isWeb ? 20.sp : 18.sp,
                  ),
                  label: Text(
                    AppStrings.get('changeAddress'),
                    style: TextStyle(
                      fontSize: isWeb ? 15.sp : 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 16.w : 12.w,
                      vertical: isWeb ? 12.h : 10.h,
                    ),
                  ),
                ),
              ] else
                _buildEmptyAddressState(isWeb),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(DeliveryAddress address, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 20.w : 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.03),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: isWeb ? 24.sp : 22.sp,
            ),
          ),
          SizedBox(width: isWeb ? 16.w : 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.get('addressType') ?? AppStrings.get('home'),
                      style: TextStyle(
                        fontSize: isWeb ? 16.sp : 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (address.isDefault ?? false) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          AppStrings.get('default'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  address.address,
                  style: TextStyle(
                    fontSize: isWeb ? 14.sp : 13.sp,
                    color: AppColors.textMedium,
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoBanner(
    CheckoutProvider checkoutProvider,
    CartProvider cartProvider,
    bool isWeb,
  ) {
    final canDeliver = checkoutProvider.canDeliver;
    final primaryColor = canDeliver ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(isWeb ? 20.w : 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.08),
            primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 10.w : 8.w),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(isWeb ? 10.r : 8.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  canDeliver ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: Colors.white,
                  size: isWeb ? 22.sp : 20.sp,
                ),
              ),
              SizedBox(width: isWeb ? 16.w : 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canDeliver
                          ? '${AppStrings.get('deliveryAvailable')}'
                          : '${AppStrings.get('deliveryNotAvailable')}',
                      style: TextStyle(
                        fontSize: isWeb ? 16.sp : 15.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor.shade800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      canDeliver
                          ? '${AppStrings.get('distance')}: ${checkoutProvider.getDeliveryDistanceText()}'
                          : '${AppStrings.get('addressBeyondRange')} ${CheckoutProvider.maxDeliveryDistance}${AppStrings.get('km')}${AppStrings.get('delivery')}${AppStrings.get('range')}',
                      style: TextStyle(
                        fontSize: isWeb ? 14.sp : 13.sp,
                        color: primaryColor.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canDeliver) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(isWeb ? 16.w : 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_rounded,
                            color: primaryColor.shade700,
                            size: isWeb ? 20.sp : 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            AppStrings.get('deliveryFee'),
                            style: TextStyle(
                              fontSize: isWeb ? 14.sp : 13.sp,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        checkoutProvider.getDeliveryFeeText() ??
                            AppStrings.get('calculating'),
                        style: TextStyle(
                          fontSize: isWeb ? 16.sp : 15.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor.shade800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  if (cartProvider.subtotal < 20 &&
                      checkoutProvider.deliveryDistance! <= 3) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(isWeb ? 10.r : 8.r),
                        border: Border.all(
                          color: Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.celebration_rounded,
                            color: Colors.orange.shade700,
                            size: isWeb ? 18.sp : 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${AppStrings.get('add')} €${(20 - cartProvider.subtotal).toStringAsFixed(2)} ${AppStrings.get('addMoreForFree')}}!',
                              style: TextStyle(
                                fontSize: isWeb ? 13.sp : 12.sp,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyAddressState(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 48.w : 32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isWeb ? 24.w : 20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade100,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_location_alt_rounded,
              size: isWeb ? 56.sp : 48.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: isWeb ? 24.h : 20.h),
          Text(
            AppStrings.get('noDeliveryAddress'),
            style: TextStyle(
              fontSize: isWeb ? 18.sp : 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.get('addDeliveryAddress'),
            style: TextStyle(
              fontSize: isWeb ? 14.sp : 13.sp,
              color: AppColors.textLight,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWeb ? 24.h : 20.h),
          ElevatedButton.icon(
            onPressed: _showAddressSelectionDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              AppStrings.get('addAddress'),
              style: TextStyle(
                fontSize: isWeb ? 15.sp : 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 32.w : 24.w,
                vertical: isWeb ? 16.h : 14.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Add this improved dialog to your CheckoutScreen class
// Replace the existing _showAddressSelectionDialog method

  void _showAddressSelectionDialog() {
    final isWeb = kIsWeb;
    final TextEditingController searchController = TextEditingController();
    final TextEditingController apartmentController = TextEditingController();
    final TextEditingController instructionsController =
        TextEditingController();

    List<Map<String, dynamic>> suggestions = [];
    String selectedAddressText = '';
    double? selectedLat;
    double? selectedLng;
    String addressType = AppStrings.get('home');

    bool showAddressForm = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 24.r : 20.r),
                  ),
                  elevation: 8,
                  child: Container(
                    width: isWeb ? 650 : double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                      maxWidth: isWeb ? 650 : double.infinity,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(isWeb ? 24.w : 20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.05),
                                Colors.white,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isWeb ? 24.r : 20.r),
                              topRight: Radius.circular(isWeb ? 24.r : 20.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: isWeb ? 24.sp : 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  showAddressForm
                                      ? AppStrings.get('completeAddressDetails')
                                      : AppStrings.get('selectAddress'),
                                  style: TextStyle(
                                    fontSize: isWeb ? 20.sp : 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textLight,
                                  size: isWeb ? 24.sp : 22.sp,
                                ),
                                onPressed: () => Navigator.pop(dialogContext),
                                splashRadius: 24,
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: Colors.grey.shade200),

                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isWeb ? 24.w : 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!showAddressForm) ...[
                                  // Saved Addresses Section
                                  if (checkoutProvider
                                      .savedAddresses.isNotEmpty) ...[
                                    _buildDialogSectionHeader(
                                      AppStrings.get('savedAddresses'),
                                      Icons.bookmark_rounded,
                                      isWeb,
                                    ),
                                    SizedBox(height: isWeb ? 16.h : 14.h),
                                    ...checkoutProvider.savedAddresses
                                        .map((address) {
                                      return _buildSavedAddressCard(
                                        address,
                                        isWeb,
                                        dialogContext,
                                      );
                                    }).toList(),
                                    SizedBox(height: isWeb ? 32.h : 24.h),
                                  ],

                                  // Add New Address Section
                                  _buildDialogSectionHeader(
                                    checkoutProvider.savedAddresses.isEmpty
                                        ? AppStrings.get('addYourFirstAddress')
                                        : AppStrings.get('addNewAddress'),
                                    Icons.add_location_alt_rounded,
                                    isWeb,
                                  ),
                                  SizedBox(height: isWeb ? 16.h : 14.h),

                                  // Search Field
                                  TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isWeb ? 15.sp : 14.sp,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText:
                                          AppStrings.get('searchAddress'),
                                      hintText:
                                          AppStrings.get('startTypingAddress'),
                                      hintStyle: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: isWeb ? 14.sp : 13.sp,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: AppColors.primary,
                                        size: isWeb ? 22.sp : 20.sp,
                                      ),
                                      suffixIcon:
                                          searchController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear_rounded,
                                                    color: AppColors.textLight,
                                                    size: isWeb ? 20.sp : 18.sp,
                                                  ),
                                                  onPressed: () {
                                                    searchController.clear();
                                                    dialogSetState(() {
                                                      suggestions = [];
                                                    });
                                                  },
                                                )
                                              : null,
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isWeb ? 20.w : 16.w,
                                        vertical: isWeb ? 18.h : 16.h,
                                      ),
                                    ),
                                    onChanged: (value) async {
                                      if (value.isNotEmpty) {
                                        final response = await ApiService()
                                            .getAddressAutocomplete(value);
                                        if (response.isSuccess &&
                                            response.data != null) {
                                          dialogSetState(() {
                                            suggestions = response.data!;
                                          });
                                        } else {
                                          dialogSetState(() {
                                            suggestions = [];
                                          });
                                        }
                                      } else {
                                        dialogSetState(() {
                                          suggestions = [];
                                        });
                                      }
                                    },
                                  ),

                                  SizedBox(height: isWeb ? 16.h : 14.h),

                                  // Suggestions List
                                  if (suggestions.isNotEmpty)
                                    Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 280.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: suggestions.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                          height: 1,
                                          color: Colors.grey.shade100,
                                        ),
                                        itemBuilder: (context, index) {
                                          final suggestion = suggestions[index];
                                          return ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: isWeb ? 20.w : 16.w,
                                              vertical: isWeb ? 8.h : 6.h,
                                            ),
                                            leading: Container(
                                              padding: EdgeInsets.all(
                                                  isWeb ? 10.w : 8.w),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.location_on_rounded,
                                                color: AppColors.primary,
                                                size: isWeb ? 22.sp : 20.sp,
                                              ),
                                            ),
                                            title: Text(
                                              suggestion['description']
                                                      ?.toString() ??
                                                  'No description',
                                              style: TextStyle(
                                                fontSize: isWeb ? 14.sp : 13.sp,
                                                color: AppColors.textDark,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: AppColors.textLight,
                                              size: isWeb ? 16.sp : 14.sp,
                                            ),
                                            onTap: () async {
                                              final placeId =
                                                  suggestion['place_id'];
                                              final placeDetailsResponse =
                                                  await ApiService()
                                                      .getPlaceDetails(placeId);

                                              if (placeDetailsResponse
                                                      .isSuccess &&
                                                  placeDetailsResponse.data !=
                                                      null) {
                                                final result =
                                                    placeDetailsResponse.data!;
                                                final lat = result['geometry']
                                                    ['location']['lat'];
                                                final lng = result['geometry']
                                                    ['location']['lng'];

                                                dialogSetState(() {
                                                  selectedAddressText =
                                                      suggestion[
                                                              'description'] ??
                                                          '';
                                                  selectedLat = lat;
                                                  selectedLng = lng;
                                                  showAddressForm = true;
                                                });
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  else if (searchController.text.isNotEmpty)
                                    _buildEmptySuggestionsState(isWeb),
                                ] else ...[
                                  // Address Form (Apartment & Instructions)
                                  Container(
                                    padding:
                                        EdgeInsets.all(isWeb ? 20.w : 16.w),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(
                                          isWeb ? 14.r : 12.r),
                                      border: Border.all(
                                        color:
                                            AppColors.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.primary,
                                              size: isWeb ? 20.sp : 18.sp,
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Text(
                                                selectedAddressText,
                                                style: TextStyle(
                                                  fontSize:
                                                      isWeb ? 14.sp : 13.sp,
                                                  color: AppColors.textDark,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            TextButton.icon(
                                              icon:
                                                  Icon(Icons.edit, size: 16.sp),
                                              label: Text('Change'),
                                              onPressed: () {
                                                dialogSetState(() {
                                                  showAddressForm = false;
                                                  apartmentController.clear();
                                                  instructionsController
                                                      .clear();
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.primary,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 6.h,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 24.h),

                                  // Address Type Selection
                                  Text(
                                    'Address Type *',
                                    style: TextStyle(
                                      fontSize: isWeb ? 15.sp : 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTypeChip(
                                          AppStrings.get('home'),
                                          Icons.home,
                                          addressType == AppStrings.get('home'),
                                          () => dialogSetState(() =>
                                              addressType =
                                                  AppStrings.get('home')),
                                          isWeb,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildTypeChip(
                                          AppStrings.get('office'),
                                          Icons.work,
                                          addressType ==
                                              AppStrings.get('office'),
                                          () => dialogSetState(() =>
                                              addressType =
                                                  AppStrings.get('office')),
                                          isWeb,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildTypeChip(
                                          AppStrings.get('other'),
                                          Icons.location_on,
                                          addressType ==
                                              AppStrings.get('other'),
                                          () => dialogSetState(() =>
                                              addressType =
                                                  AppStrings.get('other')),
                                          isWeb,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 24.h),

                                  // Apartment/House Number (Required)
                                  TextField(
                                    controller: apartmentController,
                                    style: TextStyle(
                                      fontSize: isWeb ? 15.sp : 14.sp,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText:
                                          AppStrings.get('apartmentNumber'),
                                      hintText: AppStrings.get(
                                          'apartmentPlaceholder'),
                                      prefixIcon: Icon(
                                        Icons.door_front_door,
                                        color: AppColors.primary,
                                        size: isWeb ? 22.sp : 20.sp,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20.h),

                                  // Delivery Instructions (Optional)
                                  TextField(
                                    controller: instructionsController,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: isWeb ? 15.sp : 14.sp,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: AppStrings.get(
                                          'deliveryInstructions'),
                                      hintText: AppStrings.get(
                                          'deliveryInstructionsPlaceholder'),
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(bottom: 50.h),
                                        child: Icon(
                                          Icons.notes,
                                          color: AppColors.primary,
                                          size: isWeb ? 22.sp : 20.sp,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            isWeb ? 14.r : 12.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 32.h),

                                  // Save Address Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Validate apartment field
                                        if (apartmentController.text
                                            .trim()
                                            .isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.warning_rounded,
                                                      color: Colors.white),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(AppStrings.get(
                                                        'pleaseEnterApartment')),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.orange,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final address = DeliveryAddress(
                                          id: DateTime.now().toString(),
                                          type: addressType,
                                          address: selectedAddressText,
                                          apartment:
                                              apartmentController.text.trim(),
                                          instructions: instructionsController
                                                  .text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : instructionsController.text
                                                  .trim(),
                                          latitude: selectedLat,
                                          longitude: selectedLng,
                                        );

                                        final checkoutProvider =
                                            context.read<CheckoutProvider>();
                                        final cartProvider =
                                            context.read<CartProvider>();

                                        await checkoutProvider.selectAddress(
                                          address,
                                          orderTotal: cartProvider.subtotal,
                                        );

                                        if (!checkoutProvider.canDeliver) {
                                          Navigator.pop(dialogContext);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.error_rounded,
                                                      color: Colors.white),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(
                                                      'Sorry, this address is beyond our ${CheckoutProvider.maxDeliveryDistance}km delivery range',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: Duration(seconds: 4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                          );
                                          checkoutProvider.clearAddress();
                                          return;
                                        }

                                        final saved = await checkoutProvider
                                            .saveAddress(address);
                                        Navigator.pop(dialogContext);

                                        if (saved) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Colors.white),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.get(
                                                              'addressSavedWithDistance')
                                                          .replaceAll(
                                                              '{distance}',
                                                              checkoutProvider
                                                                  .getDeliveryDistanceText()
                                                                  .toString()),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: isWeb ? 18.h : 16.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              isWeb ? 14.r : 12.r),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        AppStrings.get('saveAddress'),
                                        style: TextStyle(
                                          fontSize: isWeb ? 16.sp : 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(String label, IconData icon, bool isSelected,
      VoidCallback onTap, bool isWeb) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 14.h : 12.h,
          horizontal: isWeb ? 12.w : 10.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isWeb ? 18.sp : 16.sp,
              color: isSelected ? Colors.white : AppColors.textMedium,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 13.sp : 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogSectionHeader(String title, IconData icon, bool isWeb) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isWeb ? 8.w : 6.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: isWeb ? 18.sp : 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 16.sp : 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionTile(
    Map<String, dynamic> suggestion,
    bool isWeb,
    BuildContext dialogContext,
    TextEditingController searchController,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20.w : 16.w,
        vertical: isWeb ? 8.h : 6.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(isWeb ? 10.w : 8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.location_on_rounded,
          color: AppColors.primary,
          size: isWeb ? 22.sp : 20.sp,
        ),
      ),
      title: Text(
        suggestion['description']?.toString() ?? 'No description',
        style: TextStyle(
          fontSize: isWeb ? 14.sp : 13.sp,
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textLight,
        size: isWeb ? 16.sp : 14.sp,
      ),
      onTap: () async {
        final placeId = suggestion['place_id'];
        final placeDetailsResponse =
            await ApiService().getPlaceDetails(placeId);

        if (placeDetailsResponse.isSuccess &&
            placeDetailsResponse.data != null) {
          final result = placeDetailsResponse.data!;
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];

          final address = DeliveryAddress(
            id: DateTime.now().toString(),
            address: suggestion['description'] ?? '',
            type: AppStrings.get('home'),
            latitude: lat,
            longitude: lng,
          );

          final checkoutProvider = context.read<CheckoutProvider>();
          final cartProvider = context.read<CartProvider>();

          await checkoutProvider.selectAddress(
            address,
            orderTotal: cartProvider.subtotal,
          );

          if (!checkoutProvider.canDeliver) {
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.get('addressBeyondRangeWithLimit')
                            .replaceAll(
                                '{limit}',
                                CheckoutProvider.maxDeliveryDistance
                                    .toString()),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
            checkoutProvider.clearAddress();
            return;
          }

          final saved = await checkoutProvider.saveAddress(address);
          Navigator.pop(dialogContext);

          if (saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.get('addressSavedWithDistance').replaceAll(
                            '{distance}',
                            checkoutProvider
                                .getDeliveryDistanceText()
                                .toString()),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      placeDetailsResponse.error ??
                          placeDetailsResponse.error ??
                          AppStrings.get('failedToFetchPlaceDetails'),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildEmptySuggestionsState(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32.w : 24.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isWeb ? 14.r : 12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: isWeb ? 48.sp : 40.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'No addresses found',
            style: TextStyle(
              fontSize: isWeb ? 15.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: isWeb ? 13.sp : 12.sp,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAddressCard(
    DeliveryAddress address,
    bool isWeb,
    BuildContext dialogContext,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 14.h : 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final checkoutProvider = context.read<CheckoutProvider>();
            final cartProvider = context.read<CartProvider>();

            await checkoutProvider.selectAddress(
              address,
              orderTotal: cartProvider.subtotal,
            );

            Navigator.pop(dialogContext);

            if (!checkoutProvider.canDeliver) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This address is beyond our ${CheckoutProvider.maxDeliveryDistance}km delivery range',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
              checkoutProvider.clearAddress();
            }
          },
          borderRadius: BorderRadius.circular(isWeb ? 16.r : 14.r),
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 16.w : 14.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isWeb ? 12.w : 10.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                  ),
                  child: Icon(
                    _getAddressIcon(address.type),
                    color: AppColors.primary,
                    size: isWeb ? 22.sp : 20.sp,
                  ),
                ),
                SizedBox(width: isWeb ? 16.w : 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.type ?? AppStrings.get('home'),
                              style: TextStyle(
                                fontSize: isWeb ? 15.sp : 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (address.isDefault ?? false) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                AppStrings.get('default'),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        address.address,
                        style: TextStyle(
                          fontSize: isWeb ? 13.sp : 12.sp,
                          color: AppColors.textMedium,
                          height: 1.5,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textMedium,
                      size: isWeb ? 20.sp : 18.sp,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 8,
                  offset: const Offset(0, 8),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      _confirmDeleteAddress(address, dialogContext);
                    } else if (value == 'default') {
                      final provider = context.read<CheckoutProvider>();
                      final success =
                          await provider.setDefaultAddress(address.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                      AppStrings.get('defaultAddressUpdated')),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    if (!(address.isDefault ?? false))
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 20.sp,
                              color: Colors.orange.shade700,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              AppStrings.get('setAsDefault'),
                              style: TextStyle(
                                fontSize: isWeb ? 14.sp : 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 20.sp,
                            color: Colors.red.shade700,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            AppStrings.get('delete'),
                            style: TextStyle(
                              fontSize: isWeb ? 14.sp : 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAddress(
      DeliveryAddress address, BuildContext dialogContext) {
    final isWeb = kIsWeb;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 20.r : 16.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.red.shade700,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  AppStrings.get('deleteAddress'),
                  style: TextStyle(
                    fontSize: isWeb ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppStrings.get('confirmDeleteAddress'),
            style: TextStyle(
              fontSize: isWeb ? 14.sp : 13.sp,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMedium,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
              child: Text(
                AppStrings.get('cancel'),
                style: TextStyle(
                  fontSize: isWeb ? 15.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final provider = context.read<CheckoutProvider>();
                final success = await provider.deleteAddress(address.id);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                AppStrings.get('addressDeletedSuccessfully')),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                AppStrings.get('delete'),
                style: TextStyle(
                  fontSize: isWeb ? 15.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getAddressIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.business_rounded;
      case 'other':
        return Icons.location_on_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            final canProceed = checkoutProvider.isReadyForOrder;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show warning if delivery is selected but no valid address
                if (checkoutProvider.deliveryType == DeliveryType.delivery &&
                    (!canProceed || !checkoutProvider.canDeliver)) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            checkoutProvider.selectedAddress == null
                                ? AppStrings.get('pleaseSelectDeliveryAddress')
                                : AppStrings.get('addressBeyondDeliveryRange'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                CustomButton(
                  text: AppStrings.placeOrder,
                  onPressed:
                      canProceed ? () => context.push(AppRoutes.payment) : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWebCheckoutButton() {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        final canProceed =
            checkoutProvider.deliveryType == DeliveryType.pickup ||
                (checkoutProvider.selectedAddress != null &&
                    checkoutProvider.canDeliver);

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: CustomButton(
              text: AppStrings.placeOrder,
              onPressed:
                  canProceed ? () => context.push(AppRoutes.payment) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchInfo() {
    final isWeb = kIsWeb;
    return Consumer<CheckoutProvider>(
      builder: (context, provider, child) {
        final branch = provider.selectedBranch;

        return Container(
          margin: isWeb ? null : EdgeInsets.all(16.w),
          padding: EdgeInsets.all(isWeb ? 28 : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
            border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
                blurRadius: isWeb ? 16 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('pickupLocation'),
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isWeb ? 14 : 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(isWeb ? 14 : 12.r),
                    ),
                    child: Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: isWeb ? 26 : 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 24 : 20.h),
              if (branch != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: isWeb ? 22 : 20.sp,
                      ),
                    ),
                    SizedBox(width: isWeb ? 14 : 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: TextStyle(
                              fontSize: isWeb ? 17 : 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: isWeb ? 8 : 6.h),
                          Text(
                            branch.address,
                            style: TextStyle(
                              fontSize: isWeb ? 15 : 14.sp,
                              color: AppColors.textMedium,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isWeb ? 20 : 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Icon(
                        Icons.phone,
                        color: AppColors.textLight,
                        size: isWeb ? 20 : 18.sp,
                      ),
                    ),
                    SizedBox(width: isWeb ? 14 : 12.w),
                    Text(
                      branch.phone,
                      style: TextStyle(
                        fontSize: isWeb ? 15 : 14.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickupTimePreference() {
    final isWeb = kIsWeb;
    return Container(
      margin: isWeb ? null : EdgeInsets.all(16.w),
      padding: EdgeInsets.all(isWeb ? 28 : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
        border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
            blurRadius: isWeb ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: isWeb ? 22 : 20.sp,
                ),
              ),
              SizedBox(width: isWeb ? 14 : 8.w),
              Text(
                AppStrings.get('pickupTime'),
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 24 : 20.h),
          _buildTimeOption(AppStrings.today, true),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String text, bool isSelected) {
    final isWeb = kIsWeb;
    return GestureDetector(
      onTap: () {
        // TODO: Select time
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 16 : 14.h,
          horizontal: isWeb ? 20 : 16.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 14 : 12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isWeb ? 2 : 1.5,
          ),
          boxShadow: isWeb && isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: isWeb ? 10 : 8.w),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: isWeb ? 20 : 18.sp,
                ),
              ),
            Text(
              text,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMedium,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    final isWeb = kIsWeb;
    return Consumer2<CartProvider, CheckoutProvider>(
      builder: (context, cartProvider, checkoutProvider, child) {
        return Container(
          margin: isWeb ? null : EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(isWeb ? 28 : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
            border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
                blurRadius: isWeb ? 16 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.cartSummary,
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 14 : 12.w,
                      vertical: isWeb ? 7 : 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                    ),
                    child: Text(
                      checkoutProvider.deliveryType == DeliveryType.delivery
                          ? AppStrings.delivery
                          : AppStrings.takeaway,
                      style: TextStyle(
                        fontSize: isWeb ? 13 : 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 24 : 20.h),
              if (cartProvider.items.isNotEmpty) ...[
                ...cartProvider.items.take(3).map(
                      (item) => _buildCartSummaryItem(item),
                    ),
                if (cartProvider.items.length > 3)
                  Padding(
                    padding: EdgeInsets.only(top: isWeb ? 16 : 12.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isWeb ? 10 : 8.h,
                        horizontal: isWeb ? 14 : 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: isWeb ? 16 : 14.sp,
                            color: AppColors.textLight,
                          ),
                          SizedBox(width: isWeb ? 8 : 6.w),
                          Text(
                            AppStrings.get('moreItems').replaceAll('{count}',
                                (cartProvider.items.length - 3).toString()),
                            style: TextStyle(
                              fontSize: isWeb ? 13 : 12.sp,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: isWeb ? 24 : 20.h),
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('subtotal'),
                      style: TextStyle(
                        fontSize: isWeb ? 15 : 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Text(
                      '€${cartProvider.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isWeb ? 15 : 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isWeb ? 12 : 10.h),
                // Delivery Fee (only for delivery)
                if (checkoutProvider.deliveryType == DeliveryType.delivery)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get('deliveryfee'),
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                      Text(
                        checkoutProvider.getDeliveryFeeText() ??
                            AppStrings.get('calculating'),
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 14.sp,
                          fontWeight: FontWeight.w600,
                          color: checkoutProvider.canDeliver
                              ? AppColors.textDark
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                if (checkoutProvider.deliveryType == DeliveryType.delivery)
                  SizedBox(height: isWeb ? 12 : 10.h),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('total'),
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '€${cartProvider.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  AppStrings.get('cartEmpty'),
                  style: TextStyle(
                    fontSize: isWeb ? 15 : 14.sp,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartSummaryItem(CartItem cartItem) {
    final isWeb = kIsWeb;
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 10.h),
      padding: EdgeInsets.all(isWeb ? 14 : 12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(isWeb ? 12 : 10.r),
      ),
      child: Row(
        children: [
          Container(
            width: isWeb ? 11 : 10.w,
            height: isWeb ? 11 : 10.h,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isWeb ? 14 : 12.w),
          Expanded(
            child: Text(
              cartItem.foodItem.name,
              style: TextStyle(
                fontSize: isWeb ? 15 : 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            '${AppStrings.currency}${cartItem.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isWeb ? 15 : 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
