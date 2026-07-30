import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/shared/widgets/ooter.dart';

import 'profile/widgets/profile_app_bar.dart';
import 'profile/widgets/profile_login_prompt.dart';
import 'profile/widgets/profile_mobile_layout.dart';
import 'profile/widgets/profile_web_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? _lastPressedAt;
    return PopScope(
      canPop: kIsWeb,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || kIsWeb) return;

        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.get('pressBackAgain'),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.textDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: kIsWeb ? null : const ProfileAppBar(),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isAuthenticated) {
              return const ProfileLoginPrompt();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 768;

                if (isWeb) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ProfileWebLayout(
                          authProvider: authProvider,
                          constraints: constraints,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: FoodKingFooter(), // Full-width footer
                      ),
                    ],
                  );
                } else {
                  return ProfileMobileLayout(authProvider: authProvider);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
