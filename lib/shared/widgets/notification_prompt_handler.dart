// lib/shared/widgets/notification_prompt_handler.dart
import 'package:flutter/material.dart';
import 'package:Saborly/core/services/notification_service.dart';
import 'package:Saborly/shared/widgets/notification_permission_dialog.dart';

class NotificationPromptHandler extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const NotificationPromptHandler({
    super.key,
    required this.child,
    this.delay = const Duration(seconds: 3),
  });

  @override
  State<NotificationPromptHandler> createState() => _NotificationPromptHandlerState();
}

class _NotificationPromptHandlerState extends State<NotificationPromptHandler> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    // Schedule the permission dialog check after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _schedulePermissionDialog();
    });
  }

  Future<void> _schedulePermissionDialog() async {
    // Wait for the specified delay to ensure everything is loaded
    await Future.delayed(widget.delay);

    if (!mounted || _hasShownDialog) return;

    final notificationService = NotificationService();
    final shouldShow = await notificationService.shouldShowPermissionDialog();

    if (!mounted || !shouldShow || _hasShownDialog) return;

    _hasShownDialog = true;
    
    // Use WidgetsBinding to ensure we have a valid context with Navigator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showPermissionDialog();
      }
    });
  }

  void _showPermissionDialog() {
    // Make sure we have a valid context with Navigator
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => NotificationPermissionDialog(
        onAllow: () async {
          Navigator.of(dialogContext).pop();
          
          final notificationService = NotificationService();
          final granted = await notificationService.requestPermissionWithDialog();
          
          if (granted && mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Notifications enabled! You\'ll receive order updates.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        onDeny: () {
          Navigator.of(dialogContext).pop();
          
          // Optionally show a subtle message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You can enable notifications later in settings.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}