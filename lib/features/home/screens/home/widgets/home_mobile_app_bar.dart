import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/notification_provider.dart';
import 'package:Saborly/shared/widgets/language_selector.dart';

/// Mobile-only app bar: logo + selected location on the left (title area),
/// language selector and a notifications bell with unread badge on actions.
class HomeMobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearSearchSilently;
  final VoidCallback onClearSearch;

  const HomeMobileAppBar({
    super.key,
    required this.onClearSearchSilently,
    required this.onClearSearch,
  });

  @override
  Size get preferredSize => Size.fromHeight(78.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 78.h,
      automaticallyImplyLeading: false,
      title: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, _) {
          final locationText = _getLocationLabel(checkoutProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(context),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () => context.go(AppRoutes.checkout),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.secondary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: LanguageSelector(showLabel: false, isCompact: true),
        ),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final unreadCount = notificationProvider.unreadCount;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    onClearSearchSilently();
                    context.push(AppRoutes.notifications);
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textDark,
                    size: 24.sp,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints:
                          BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getLocationLabel(CheckoutProvider checkoutProvider) {
    final selectedAddress = checkoutProvider.selectedAddress;
    if (selectedAddress != null) {
      final label = selectedAddress.type?.trim();
      final address = selectedAddress.address.trim();

      if (label != null && label.isNotEmpty && address.isNotEmpty) {
        return '$label • $address';
      }
      if (address.isNotEmpty) {
        return address;
      }
      if (label != null && label.isNotEmpty) {
        return label;
      }
    }

    final selectedBranch = checkoutProvider.selectedBranch;
    if (selectedBranch != null) {
      return '${AppStrings.pickupLocation}: ${selectedBranch.name}';
    }

    return '${AppStrings.pickupLocation}: Saborly Barcelona';
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClearSearch();
        context.go(AppRoutes.home);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        child: Hero(
          tag: 'app_logo',
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 140.w),
            child: AspectRatio(
              aspectRatio: 3,
              child: Image.asset(
                'assets/images/logo3.png',
                fit: BoxFit.contain,
                semanticLabel: AppStrings.get('appLogo'),
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error_outline,
                  size: 24.sp,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
