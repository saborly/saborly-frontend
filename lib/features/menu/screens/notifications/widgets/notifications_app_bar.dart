import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/providers/notification_provider.dart';

/// App bar for the notifications screen, including the "mark all as read" /
/// "clear all" popup menu.
class NotificationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationsAppBar({super.key, required this.onClearAll});

  final void Function(BuildContext context) onClearAll;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go(AppRoutes.home),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textDark,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppStrings.get('notifications'),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.hasNotifications) {
              return PopupMenuButton<String>(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                offset: const Offset(0, 50),
                elevation: 8,
                onSelected: (value) async {
                  if (value == 'mark_all_read') {
                    await provider.markAllAsRead();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  AppStrings.get('allNotificationsMarkedAsRead'),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          margin: EdgeInsets.all(16.w),
                        ),
                      );
                    }
                  } else if (value == 'clear_all') {
                    onClearAll(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.done_all_rounded,
                            size: 18.sp,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          AppStrings.get('markAllAsRead'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.delete_sweep_rounded,
                            size: 18.sp,
                            color: Colors.red.shade700,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          AppStrings.get('clearAll'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
