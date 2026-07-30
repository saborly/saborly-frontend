import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../shared/widgets/custom_button.dart';

/// Extracted from order_status.dart `_buildBottomBar`.
class OrderBottomBar extends StatelessWidget {
  const OrderBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: AppStrings.home,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}
