import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import '../../../../../shared/models/order.dart';

/// Extracted from order_status.dart `_buildRestaurantInfo`.
class OrderRestaurantInfoCard extends StatelessWidget {
  final Order order;
  final bool isDesktop;
  final bool isTablet;

  const OrderRestaurantInfoCard({
    super.key,
    required this.order,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    const String phoneNumber = '+34932112072';

    Future<void> makePhoneCall(String phoneNumber) async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.get('callError')
                    .replaceAll('{phoneNumber}', phoneNumber)),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.get('callErrorGeneric')
                  .replaceAll('{error}', e.toString())),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isDesktop ? 80 : 70,
                height: isDesktop ? 80 : 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: isDesktop ? 36 : 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.branchName ?? AppStrings.boshundhoraRA,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.get('restaurantAddress'),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => makePhoneCall(phoneNumber),
              icon: const Icon(Icons.phone_rounded, size: 20),
              label: Text(
                AppStrings.get('callRestaurant'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
