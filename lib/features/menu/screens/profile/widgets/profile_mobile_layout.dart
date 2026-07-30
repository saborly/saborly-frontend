import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';

import 'profile_app_info.dart';
import 'profile_header.dart';
import 'profile_menu_options.dart';

/// Full mobile (narrow layout) body of the profile screen.
class ProfileMobileLayout extends StatelessWidget {
  final AuthProvider authProvider;

  const ProfileMobileLayout({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          ProfileHeader(authProvider: authProvider),
          SizedBox(height: 24.h),
          const ProfileMenuOptions(),
          SizedBox(height: 24.h),
          const ProfileAppInfo(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
