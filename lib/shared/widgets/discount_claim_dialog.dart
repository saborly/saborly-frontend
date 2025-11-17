// lib/shared/widgets/discount_claim_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/shared/models/offer.dart';

/// Show dialog to claim a discount (one per device limit)
Future<bool?> showDiscountClaimDialog(
  BuildContext context, {
  required String offerId,
  required String offerTitle,
  required String offerType,
  required double discountValue,
  DateTime? expiryDate,
  String? itemId,
  String? itemName,
}) async {
  final offersProvider = context.read<OffersProvider>();

  // Check if device already has an active discount
  final canClaim = await offersProvider.canClaimDiscount();

  if (!canClaim) {
    // Show error dialog
    return await showDialog<bool>(
      context: context,
      builder: (context) => _AlreadyHasDiscountDialog(
        activeDiscount: offersProvider.activeDeviceDiscount!,
      ),
    );
  }

  // Show claim confirmation dialog
  return await showDialog<bool>(
    context: context,
    builder: (context) => _ClaimDiscountDialog(
      offerId: offerId,
      offerTitle: offerTitle,
      offerType: offerType,
      discountValue: discountValue,
      expiryDate: expiryDate,
      itemId: itemId,
      itemName: itemName,
    ),
  );
}

class _ClaimDiscountDialog extends StatefulWidget {
  final String offerId;
  final String offerTitle;
  final String offerType;
  final double discountValue;
  final DateTime? expiryDate;
  final String? itemId;
  final String? itemName;

  const _ClaimDiscountDialog({
    required this.offerId,
    required this.offerTitle,
    required this.offerType,
    required this.discountValue,
    this.expiryDate,
    this.itemId,
    this.itemName,
  });

  @override
  State<_ClaimDiscountDialog> createState() => _ClaimDiscountDialogState();
}

class _ClaimDiscountDialogState extends State<_ClaimDiscountDialog> {
  bool _isClaiming = false;

  String _getDiscountText() {
    switch (widget.offerType) {
      case 'percentage':
        return '${widget.discountValue.toInt()}% OFF';
      case 'fixed-amount':
        return '\$${widget.discountValue.toStringAsFixed(2)} OFF';
      case 'buy-one-get-one':
        return 'Buy 1 Get 1 Free';
      case 'free-delivery':
        return 'Free Delivery';
      default:
        return 'Special Offer';
    }
  }

  Future<void> _claimDiscount() async {
    setState(() => _isClaiming = true);

    try {
      final success = await context.read<OffersProvider>().claimDiscount(
        offerId: widget.offerId,
        offerTitle: widget.offerTitle,
        offerType: widget.offerType,
        discountValue: widget.discountValue,
        expiryDate: widget.expiryDate,
        itemId: widget.itemId,
        itemName: widget.itemName,
      );

      if (mounted) {
        Navigator.of(context).pop(success);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Discount claimed successfully!',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isClaiming = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to claim discount',
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer,
                size: 40.sp,
                color: AppColors.primary,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Title
            Text(
              'Claim This Discount?',
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            // Offer details
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.offerTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _getDiscountText(),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  if (widget.itemName != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'For: ${widget.itemName}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  if (widget.expiryDate != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: AppColors.textMedium,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Expires: ${_formatDate(widget.expiryDate!)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Warning message
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[700],
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'You can only claim ONE discount per device at a time.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isClaiming ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: AppColors.textLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isClaiming ? null : _claimDiscount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isClaiming
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Claim Now',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AlreadyHasDiscountDialog extends StatelessWidget {
  final Map<String, dynamic> activeDiscount;

  const _AlreadyHasDiscountDialog({required this.activeDiscount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 40.sp,
                color: Colors.orange,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            Text(
              'Discount Already Active',
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            Text(
              'You already have an active discount on this device:',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16.h),
            
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    activeDiscount['offerTitle'] ?? 'Active Discount',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (activeDiscount['itemName'] != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'For: ${activeDiscount['itemName']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Text(
              'Complete your current order or wait for the discount to expire before claiming a new one.',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 24.h),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}