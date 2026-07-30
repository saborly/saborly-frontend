import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/main.dart' show scaffoldMessengerKey;

/// Shared, professional presentation for API failures — one place that
/// decides icon/color/copy per [ApiErrorType] so every screen shows
/// connection/server-down/timeout errors the same, calm way instead of
/// raw exception text or ad-hoc snackbars.
void showApiErrorSnackbar(ApiResponse response, {String? fallbackMessage}) {
  final message = response.error ?? fallbackMessage ?? 'Something went wrong. Please try again.';
  final (icon, color) = _iconAndColorFor(response.errorType);

  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return; // No mounted Scaffold yet — nothing to show, nothing to crash.

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Generic fallback for errors that aren't tied to a specific API call
/// (e.g. an uncaught error from the global zone handler in main.dart).
void showGenericErrorSnackbar([String? message]) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Something went wrong. Please try again.',
              style: GoogleFonts.manrope(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

(IconData, Color) _iconAndColorFor(ApiErrorType type) {
  switch (type) {
    case ApiErrorType.noConnection:
      return (Icons.wifi_off_rounded, AppColors.secondary);
    case ApiErrorType.timeout:
      return (Icons.hourglass_bottom_rounded, AppColors.secondary);
    case ApiErrorType.serverDown:
      return (Icons.cloud_off_rounded, AppColors.error);
    case ApiErrorType.clientError:
      return (Icons.error_outline_rounded, AppColors.error);
    case ApiErrorType.cancelled:
      return (Icons.block_rounded, Colors.white70);
    case ApiErrorType.unknown:
      return (Icons.error_outline_rounded, AppColors.error);
  }
}
