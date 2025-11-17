// lib/shared/widgets/download_app_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadAppModal extends StatefulWidget {
  const DownloadAppModal({super.key});

  @override
  State<DownloadAppModal> createState() => _DownloadAppModalState();
}

class _DownloadAppModalState extends State<DownloadAppModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeModal() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _launchStore(String store) async {
    final urls = {
      'ios': 'https://apps.apple.com/app/saborly',
      'android': 'https://play.google.com/store/apps/details?id=com.saborly.app',
    };

    final url = urls[store];
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final modalWidth = isSmallScreen ? screenWidth * 0.9 : 500.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: modalWidth,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative gradient background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 180.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: IconButton(
                      onPressed: _closeModal,
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(32.w, 40.h, 32.w, 32.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App icon/image
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Image.asset(
                              'assets/images/logo3.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.restaurant_menu,
                                size: 50.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 100.h),

                        // Discount badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF6B6B),
                                const Color(0xFFFF8E53),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Get 20% OFF',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Title
                        Text(
                          'Download Saborly App',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Description
                        Text(
                          'Order from our mobile app and enjoy an exclusive 20% discount on your first order!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMedium,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Store buttons
                        Row(
                          children: [
                            Expanded(
                              child: _StoreButton(
                                onTap: () => _launchStore('ios'),
                                icon: Icons.apple,
                                storeName: 'App Store',
                                tagline: 'Download on the',
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _StoreButton(
                                onTap: () => _launchStore('android'),
                                icon: Icons.play_arrow_rounded,
                                storeName: 'Google Play',
                                tagline: 'Get it on',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Features
                        _buildFeature(Icons.delivery_dining, 'Fast Delivery'),
                        SizedBox(height: 12.h),
                        _buildFeature(Icons.percent, 'Exclusive Deals'),
                        SizedBox(height: 12.h),
                        _buildFeature(Icons.notifications_active, 'Order Tracking'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColors.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }
}

class _StoreButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String storeName;
  final String tagline;

  const _StoreButton({
    required this.onTap,
    required this.icon,
    required this.storeName,
    required this.tagline,
  });

  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.textDark : Colors.black,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tagline,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    widget.storeName,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show modal
Future<void> showDownloadAppModal(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => const DownloadAppModal(),
  );
}