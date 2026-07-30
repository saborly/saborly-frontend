import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import '../../../../../shared/widgets/custom_button.dart';

class ConfirmButton extends StatelessWidget {
  final PaymentProvider provider;
  final Future<void> Function(PaymentProvider provider) onConfirm;

  const ConfirmButton({
    super.key,
    required this.provider,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: AppStrings.confirm,
      isLoading: provider.isProcessing,
      onPressed: () => onConfirm(provider),
    );
  }
}
