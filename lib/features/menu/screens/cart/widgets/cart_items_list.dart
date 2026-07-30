import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/cart_provider.dart';

import '../../../../../shared/models/cart_item.dart';

class CartItemsList extends StatelessWidget {
  final CartProvider cartProvider;
  final bool isWeb;

  const CartItemsList(this.cartProvider, this.isWeb, {super.key});

  @override
  Widget build(BuildContext context) {
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
}
