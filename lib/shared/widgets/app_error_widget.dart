import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';

/// Replaces Flutter's default red/gray "exception" screen with something a
/// real user should ever see: a calm, on-brand message instead of a stack
/// trace. Used as [ErrorWidget.builder] — see main.dart.
///
/// In debug mode we still show the underlying error text (developers need
/// it); in release, only the friendly message is shown.
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const AppErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'This part of the app hit a snag. Please go back and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 13, color: AppColors.textMedium),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    details.exceptionAsString(),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.robotoMono(fontSize: 11, color: AppColors.textLight),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
