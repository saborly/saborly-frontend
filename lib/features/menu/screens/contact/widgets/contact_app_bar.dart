import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';

class ContactAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ContactAppBar({super.key, required this.isWeb});

  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textDark, size: 24.sp),
        onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
      ),
      title: Text(
        AppStrings.get('contactUs'),
        style: TextStyle(
          fontSize: isWeb ? 24.sp : 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
