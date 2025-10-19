import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/features/providers/auth_proveder.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/checkout_provider.dart';
import 'package:soely/shared/models/order.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _specialInstructionsController = TextEditingController();

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
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
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
        appBar: _buildAppBar(context),
        body: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isEmpty) {
              return _buildEmptyCart(context);
            }
      
            return isWeb ? _buildWebLayout(context, cartProvider) : _buildMobileLayout(context, cartProvider);
          },
        ),
      ),
    );
  });}

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
onPressed: () {
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home); // Fallback to home route
        }
      },
              icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppStrings.myCart,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && screenWidth > 600;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(isWeb ? 48 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 48 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: isWeb ? 80 : 60,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: isWeb ? 32 : 24),
            Text(
  AppStrings.get('emptyCart'),
              style: TextStyle(
                fontSize: isWeb ? 28 : 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
  AppStrings.get('addFoodToStart'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            SizedBox(height: isWeb ? 40 : 32),
            SizedBox(
              width: isWeb ? 240 : 200,
              height: isWeb ? 54 : 59,
              child: CustomButton(
  text: AppStrings.get('browseMenu'),
                onPressed: () => context.go(AppRoutes.menu),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, CartProvider cartProvider) {
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
                        _buildDeliveryToggle(true),
                        const SizedBox(height: 24),
                        _buildCartItems(cartProvider, true),
                        const SizedBox(height: 24),
                        // _buildSpecialInstructions(true),
                        const SizedBox(height: 24),
                        _buildFrequentlyBought(cartProvider, true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 420,
                    child: _buildOrderSummaryCard(context, cartProvider, true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        _buildDeliveryToggle(false),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCartItems(cartProvider, false),
                SizedBox(height: 16.h),
                // _buildSpecialInstructions(false),
                SizedBox(height: 16.h),
                _buildFrequentlyBought(cartProvider, false),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
        _buildBottomSection(context, cartProvider),
      ],
    );
  }
// Add this to your _buildDeliveryToggle method in CartScreen

Widget _buildDeliveryToggle(bool isWeb) {
  return Consumer<CheckoutProvider>(
    builder: (context, checkoutProvider, child) {
      final isDelivery = checkoutProvider.deliveryType == DeliveryType.delivery;
      
      return Container(
        padding: isWeb ? const EdgeInsets.all(6) : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: isWeb ? BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ) : null,
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                AppStrings.delivery,
                isDelivery,
                isWeb,
                onTap: () {
                  checkoutProvider.setDeliveryType(DeliveryType.delivery);
                },
              ),
            ),
            SizedBox(width: isWeb ? 8 : 12.w),
            Expanded(
              child: _buildToggleButton(
                AppStrings.takeaway,
                !isDelivery,
                isWeb,
                onTap: () {
                  checkoutProvider.setDeliveryType(DeliveryType.pickup);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildToggleButton(
  String text,
  bool isSelected,
  bool isWeb, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: isWeb ? 18 : 12.h),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : (isWeb ? Colors.grey.shade50 : Colors.white),
        borderRadius: BorderRadius.circular(isWeb ? 12 : 8.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          width: isWeb ? 0 : 1,
        ),
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isWeb ? 16 : 14.sp,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textMedium,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
  Widget _buildSpecialInstructions(bool isWeb) {
    return Container(
      padding: isWeb ? null : EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(isWeb ? 28 : 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 20 : 12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: isWeb ? 16 : 8,
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
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: isWeb ? 24 : 20.sp,
                  ),
                ),
                SizedBox(width: isWeb ? 14 : 8.w),
                Text(
  AppStrings.get('specialInstructions'),
                  style: TextStyle(
                    fontSize: isWeb ? 19 : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: isWeb ? 20 : 12.h),
            TextField(
              controller: _specialInstructionsController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
hintText: AppStrings.get('specialInstructionsHint'),

                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: isWeb ? 15 : 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.all(isWeb ? 18 : 12.w),
              ),
              style: TextStyle(
                fontSize: isWeb ? 15 : 14.sp,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(CartProvider cartProvider, bool isWeb) {
    return Container(
      padding: isWeb ? null : EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 20 : 12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: isWeb ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ...cartProvider.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == cartProvider.items.length - 1;
              
              return Column(
                children: [
                  _buildCartItem(item, cartProvider, isWeb),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade200,
                      indent: isWeb ? 28 : 16.w,
                      endIndent: isWeb ? 28 : 16.w,
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, CartProvider cartProvider, bool isWeb) {
    return Padding(
      padding: EdgeInsets.all(isWeb ? 28 : 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isWeb ? 18 : 12.r),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.network(
                cartItem.foodItem.imageUrl,
                width: isWeb ? 130 : 80.w,
                height: isWeb ? 130 : 80.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: isWeb ? 130 : 80.w,
                  height: isWeb ? 130 : 80.h,
                  color: Colors.grey.shade100,
                  child: Icon(Icons.fastfood, size: isWeb ? 44 : 30.sp, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),

          SizedBox(width: isWeb ? 24 : 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isWeb ? 11 : 8.w,
                      height: isWeb ? 11 : 8.h,
                      decoration: BoxDecoration(
                        color: cartItem.foodItem.isVeg ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isWeb ? 10 : 6.w),
                    Expanded(
                      child: Text(
                        cartItem.foodItem.name,
                        style: TextStyle(
                          fontSize: isWeb ? 19 : 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isWeb ? 10 : 6.h),

                if (cartItem.selectedMealSize != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: isWeb ? 6 : 2.h),
                    child: Text(
      '${AppStrings.get('sizeLabel')} ${cartItem.selectedMealSize?.name}',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),

                if (cartItem.selectedExtras.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: isWeb ? 6 : 2.h),
                    child: Text(
      '${AppStrings.get('extrasLabel')} ${cartItem.selectedExtras.map((e) => e.name).join(', ')}',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),

                if (cartItem.selectedAddons.isNotEmpty)
                  Text(
    '${AppStrings.get('addonsLabel')} ${cartItem.selectedAddons.map((a) => a.name).join(', ')}',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 12.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                SizedBox(height: isWeb ? 14 : 8.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppStrings.currency}${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isWeb ? 22 : 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(isWeb ? 14 : 10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: EdgeInsets.all(isWeb ? 6 : 2.w),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (cartItem.quantity > 1) {
                                cartProvider.updateItemQuantity(
                                  cartItem.id,
                                  cartItem.quantity - 1,
                                );
                              } else {
                                cartProvider.removeItem(cartItem.id);
                              }
                            },
                            borderRadius: BorderRadius.circular(isWeb ? 12 : 8.r),
                            child: Container(
                              width: isWeb ? 40 : 30.w,
                              height: isWeb ? 40 : 30.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(isWeb ? 12 : 8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                cartItem.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                color: Colors.white,
                                size: isWeb ? 20 : 16.sp,
                              ),
                            ),
                          ),

                          Container(
                            width: isWeb ? 52 : 42.w,
                            alignment: Alignment.center,
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: isWeb ? 18 : 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              cartProvider.updateItemQuantity(
                                cartItem.id,
                                cartItem.quantity + 1,
                              );
                            },
                            borderRadius: BorderRadius.circular(isWeb ? 12 : 8.r),
                            child: Container(
                              width: isWeb ? 40 : 30.w,
                              height: isWeb ? 40 : 30.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(isWeb ? 12 : 8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: isWeb ? 20 : 16.sp,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildFrequentlyBought(CartProvider cartProvider, bool isWeb) {
    final suggestedItems = cartProvider.getFrequentlyBoughtTogether();
    if (suggestedItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: isWeb ? null : EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(isWeb ? 28 : 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 20 : 12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: isWeb ? 16 : 8,
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
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: isWeb ? 24 : 20.sp,
                  ),
                ),
                SizedBox(width: isWeb ? 12 : 8.w),
                Text(
                  AppStrings.frequentlyBoughtTogether,
                  style: TextStyle(
                    fontSize: isWeb ? 19 : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: isWeb ? 20 : 12.h),
            SizedBox(
              height: isWeb ? 170 : 110.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestedItems.length,
                itemBuilder: (context, index) {
                  final item = suggestedItems[index];
                  return Container(
                    width: isWeb ? 140 : 90.w,
                    margin: EdgeInsets.only(right: isWeb ? 20 : 12.w),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(isWeb ? 16 : 8.r),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.network(
                              item.imageUrl,
                              width: isWeb ? 110 : 70.w,
                              height: isWeb ? 110 : 70.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: isWeb ? 110 : 70.w,
                                height: isWeb ? 110 : 70.h,
                                color: Colors.grey.shade100,
                                child: Icon(Icons.fastfood, size: isWeb ? 36 : 24.sp, color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isWeb ? 10 : 6.h),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: isWeb ? 4 : 2.h),
                        Text(
                          '${AppStrings.currency}${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, CartProvider cartProvider, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: isWeb ? 24 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
  AppStrings.get('orderSummary'),
            style: TextStyle(
              fontSize: isWeb ? 24 : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: isWeb ? 28 : 20.h),
          
          _buildPriceRow(AppStrings.subtotal, cartProvider.subtotal),
          if (cartProvider.deliveryFee > 0)
            _buildPriceRow(AppStrings.deliveryFee, cartProvider.deliveryFee),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: isWeb ? 20 : 12.h),
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
          
          _buildPriceRow(AppStrings.total, cartProvider.total, isTotal: true),
          
          SizedBox(height: isWeb ? 32 : 24),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: isWeb ? 56 : 48,
                child: CustomButton(
                  text: AppStrings.proceedToCheckout,
                  onPressed: () {
                    if (!authProvider.isAuthenticated) {
                      _showLoginDialog(context);
                    } else {
                      context.push(AppRoutes.checkout, extra: {
                        'specialInstructions': _specialInstructionsController.text.trim(),
                      });
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CartProvider cartProvider) {
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
        child: Column(
          children: [
            _buildPriceRow(AppStrings.subtotal, cartProvider.subtotal),
            if (cartProvider.deliveryFee > 0)
              _buildPriceRow(AppStrings.deliveryFee, cartProvider.deliveryFee),
            Divider(color: AppColors.divider),
            _buildPriceRow(AppStrings.total, cartProvider.total, isTotal: true),

            SizedBox(height: 16.h),

            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CustomButton(
                  text: AppStrings.proceedToCheckout,
                  onPressed: () {
                    if (!authProvider.isAuthenticated) {
                      _showLoginDialog(context);
                    } else {
                      context.push(AppRoutes.checkout, extra: {
                        'specialInstructions': _specialInstructionsController.text.trim(),
                      });
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    final isWeb = kIsWeb;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? (isTotal ? 17 : 15) : (isTotal ? 16 : 14),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          Text(
            '${AppStrings.currency}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isWeb ? (isTotal ? 17 : 15) : (isTotal ? 16 : 14),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final isWeb = kIsWeb;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
          ),
          contentPadding: EdgeInsets.all(isWeb ? 32 : 24),
          title: Text(
            AppStrings.loginRequired,
            style: TextStyle(
              fontSize: isWeb ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          content: Text(
            'Please login to continue with your takeaway order.',
            style: TextStyle(
              fontSize: isWeb ? 16 : 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20,
                  vertical: isWeb ? 14 : 12,
                ),
              ),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 28 : 24,
                  vertical: isWeb ? 14 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
                ),
              ),
              child: Text(
                AppStrings.signIn,
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}