// lib/shared/widgets/download_app_modal.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadAppModal extends StatefulWidget {
  const DownloadAppModal({super.key});

  @override
  State<DownloadAppModal> createState() => _DownloadAppModalState();
}

class _DownloadAppModalState extends State<DownloadAppModal>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Auto-close countdown
  static const int _autoCloseSeconds = 20;
  late AnimationController _countdownCtrl;
  Timer? _autoCloseTimer;
  int _secondsLeft = _autoCloseSeconds;

  @override
  void initState() {
    super.initState();

    // Entry animation
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

    // Countdown ring animation (1.0 → 0.0 over 20 s)
    _countdownCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _autoCloseSeconds),
      value: 1.0,
    )..animateTo(0.0, curve: Curves.linear);

    // Tick every second to update the number label
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _closeModal();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    _countdownCtrl.dispose();
    super.dispose();
  }

  void _closeModal() {
    _autoCloseTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _launchStore(String store) async {
    final urls = {
      'ios': 'https://apps.apple.com/pk/app/saborly/id6761368370',
      'android': 'https://play.google.com/store/apps/details?id=com.saborly.soely',
    };

    final url = urls[store];
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }


  // Sizes are plain logical pixels rather than ScreenUtil units: the design
  // size switches at the 600/1200px web breakpoints, which made .w/.h values
  // jump and stretch the logo. A dialog reads better with fixed sizes plus a
  // compact variant for phones and short viewports.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 420 || size.height < 720;
    final radius = BorderRadius.circular(compact ? 20 : 24);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Scrolls when the viewport is too short for the card.
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(compact),
                              Padding(
                                padding: compact
                                    ? const EdgeInsets.fromLTRB(20, 20, 20, 20)
                                    : const EdgeInsets.fromLTRB(32, 28, 32, 30),
                                child: _buildBody(compact),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildCloseButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    final logoSize = compact ? 72.0 : 100.0;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: compact ? 20 : 34),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Container(
        width: logoSize,
        height: logoSize,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 20 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo3.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.restaurant_menu,
            size: logoSize / 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        onTap: _closeModal,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Countdown ring
                SizedBox.expand(
                  child: AnimatedBuilder(
                    animation: _countdownCtrl,
                    builder: (_, __) => CircularProgressIndicator(
                      value: _countdownCtrl.value,
                      strokeWidth: 2.5,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                // Inner circle + icon + seconds
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.close, color: Colors.white, size: 13),
                      Text(
                        '$_secondsLeft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Discount badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer, color: Colors.white, size: compact ? 16 : 18),
              const SizedBox(width: 8),
              Text(
                'Get 20% OFF',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: compact ? 16 : 20),

        // Title
        Text(
          'Download our app',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: compact ? 23 : 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),

        SizedBox(height: compact ? 8 : 12),

        // Description
        Text(
          'Order from our mobile app and save on your first order!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: compact ? 13.5 : 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textMedium,
            height: 1.5,
          ),
        ),

        SizedBox(height: compact ? 20 : 28),

        // Store buttons: side by side when there's room, stacked on phones.
        LayoutBuilder(
          builder: (context, constraints) {
            final appStore = _StoreButton(
              onTap: () => _launchStore('ios'),
              icon: Icons.apple,
              storeName: 'App Store',
              tagline: 'Download on the',
            );
            final googlePlay = _StoreButton(
              onTap: () => _launchStore('android'),
              icon: Icons.play_arrow_rounded,
              storeName: 'Google Play',
              tagline: 'Get it on',
            );

            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  appStore,
                  const SizedBox(height: 10),
                  googlePlay,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: appStore),
                const SizedBox(width: 14),
                Expanded(child: googlePlay),
              ],
            );
          },
        ),

        SizedBox(height: compact ? 20 : 24),

        // Features
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFeature(Icons.delivery_dining, 'Fast Delivery'),
            _buildFeature(Icons.percent, 'Exclusive Deals'),
            _buildFeature(Icons.notifications_active, 'Order Tracking'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
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
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.textDark : Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          // Scales the label down instead of overflowing on tight widths.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tagline,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        widget.storeName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
