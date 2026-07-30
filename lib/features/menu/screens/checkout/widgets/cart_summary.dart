import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/shared/models/cart_item.dart';
import 'package:Saborly/shared/models/order.dart';

class CartSummary extends StatelessWidget {
  final bool firstOrderDiscountEligible;

  const CartSummary({super.key, required this.firstOrderDiscountEligible});

  @override
  Widget build(BuildContext context) {
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
                // First-order 20% discount banner (mobile only)
                if (firstOrderDiscountEligible && !isWeb) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_rounded,
                            color: Color(0xFF2E7D32), size: 18),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '20% first-order discount will be applied!',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        Text(
                          '-€${(cartProvider.subtotal * 0.20).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isWeb ? 12 : 10.h),
                ],
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
                // First-order discount row
                if (firstOrderDiscountEligible && !isWeb) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'First-order discount (20%)',
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        '-€${(cartProvider.subtotal * 0.20).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isWeb ? 15 : 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 12 : 10.h),
                ],
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
                    firstOrderDiscountEligible && !isWeb
                        ? Row(
                            children: [
                              Text(
                                '€${cartProvider.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: isWeb ? 14 : 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMedium,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '€${(cartProvider.total - cartProvider.subtotal * 0.20).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: isWeb ? 16 : 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          )
                        : Text(
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
