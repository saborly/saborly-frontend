import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import '../../../../../shared/widgets/custom_button.dart';

class PaymentBottomBar extends StatelessWidget {
  final Future<void> Function(PaymentProvider provider) onConfirm;

  const PaymentBottomBar({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => onConfirm(provider),
            );
          },
        ),
      ),
    );
  }
}
