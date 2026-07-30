import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/notification_provider.dart';
import 'package:Saborly/shared/models/notification_model.dart';
import 'notifications/widgets/clear_all_notifications_dialog.dart';
import 'notifications/widgets/notification_card.dart';
import 'notifications/widgets/notification_filter_chips.dart';
import 'notifications/widgets/notifications_app_bar.dart';
import 'notifications/widgets/notifications_empty_filter_state.dart';
import 'notifications/widgets/notifications_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    context.read<NotificationProvider>().markAsRead(notification.id);

    // Navigate based on notification type
    final type = notification.type;
    final data = notification.data;

    switch (type) {
      case 'order_update':
      case 'order_status':
        final orderId = data['orderId']?.toString();
        if (orderId != null) {
          context.push(
            AppRoutes.orderStatus.replaceFirst(':orderId', orderId)
          );
        }
        break;

      case 'new_order':
      case 'order_history':
        context.push(AppRoutes.orders);
        break;

      case 'promotion':
      case 'offer':
        context.push(AppRoutes.offer);
        break;

      case 'menu_update':
      case 'new_item':
        final categoryId = data['categoryId']?.toString();
        if (categoryId != null) {
          context.push(
            AppRoutes.menu,
            extra: {'category': categoryId}
          );
        } else {
          context.push(AppRoutes.menu);
        }
        break;

      case 'cart':
        context.push(AppRoutes.cart);
        break;

      case 'profile':
      case 'account':
        context.push(AppRoutes.profile);
        break;

      default:
        context.push(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: isWeb
          ? null
          : NotificationsAppBar(
              onClearAll: (context) => ClearAllNotificationsDialog.show(context),
            ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppStrings.get('loadingNotifications') ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasNotifications) {
            return const NotificationsEmptyState();
          }

          final filteredNotifications = _getFilteredNotifications(provider);

          return Column(
            children: [
              NotificationFilterChips(
                provider: provider,
                selectedFilter: _selectedFilter,
                onFilterSelected: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadNotifications();
                  },
                  color: AppColors.primary,
                  child: filteredNotifications.isEmpty
                      ? const NotificationsEmptyFilterState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return NotificationCard(
                              notification: notification,
                              onTap: _handleNotificationTap,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AppNotification> _getFilteredNotifications(NotificationProvider provider) {
    switch (_selectedFilter) {
      case 'unread':
        return provider.unreadNotifications;
      case 'orders':
        return provider.getNotificationsByType('order_update') +
               provider.getNotificationsByType('order_status') +
               provider.getNotificationsByType('new_order');
      case 'offers':
        return provider.getNotificationsByType('promotion') +
               provider.getNotificationsByType('offer');
      default:
        return provider.notifications;
    }
  }
}
