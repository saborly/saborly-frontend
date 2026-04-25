import 'dart:async';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/banner_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DynamicPromotionalBanner extends StatefulWidget {
  final String? category;
  final double? height;
  final Duration autoPlayDuration;
  final bool autoPlay;
  final VoidCallback? onSlideChanged;
  final Function(String? link)? onBannerTap;

  const DynamicPromotionalBanner({
    super.key,
    this.category,
    this.height,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.autoPlay = true,
    this.onSlideChanged,
    this.onBannerTap,
  });

  @override
  State<DynamicPromotionalBanner> createState() =>
      _DynamicPromotionalBannerState();
}

class _DynamicPromotionalBannerState extends State<DynamicPromotionalBanner> {
  static const String _proxyBase = 'https://api.saborly.es/api/proxy';

  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  bool _hovering = false;
  Timer? _timer;
  double? _imageAspectRatio;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DynamicPromotionalBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _load();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _imageAspectRatio = null;
    });

    _timer?.cancel();
    final banners =
        await BannerService.getActiveBanners(category: widget.category);

    if (!mounted) return;
    setState(() {
      _banners = banners;
      _isLoading = false;
    });

    if (widget.autoPlay && _banners.length > 1) {
      _startTimer();
    }

    if (_banners.isNotEmpty) {
      _resolveImageRatio(_imageUrl(_banners.first.imageUrl));
    }
  }

  void _resolveImageRatio(String url) {
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (info, _) {
          if (!mounted) return;
          final width = info.image.width.toDouble();
          final height = info.image.height.toDouble();
          if (width > 0 && height > 0) {
            setState(() => _imageAspectRatio = width / height);
          }
        },
        onError: (_, __) {},
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!mounted || _banners.isEmpty || !_pageCtrl.hasClients || _hovering) {
        return;
      }

      _pageCtrl.animateToPage(
        (_currentPage + 1) % _banners.length,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _animateTo(int index) {
    if (!_pageCtrl.hasClients || _banners.isEmpty) return;
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _prev() {
    _animateTo((_currentPage - 1 + _banners.length) % _banners.length);
  }

  void _next() {
    _animateTo((_currentPage + 1) % _banners.length);
  }

  String _imageUrl(String raw) {
    if (kIsWeb && raw.startsWith('http')) {
      return '$_proxyBase/image?url=${Uri.encodeComponent(raw)}';
    }
    return raw;
  }

  double _bannerHeight(double width) {
    if (widget.height != null) return widget.height!;

    final isMobile = width < 768;
    if (!isMobile) {
      if (width >= 1400) return 500;
      if (width >= 1100) return 430;
      return 360;
    }

    final ratio = _imageAspectRatio ?? 2.15;
    return (width / ratio).clamp(220.0, 340.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 768;
        final height = _bannerHeight(width);
        final horizontalInset = isMobile ? 0.0 : (width >= 1280 ? 24.0 : 16.0);
        final radius = isMobile ? 0.0 : 30.0;

        if (_isLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalInset),
            child: _Shimmer(height: height, radius: radius),
          );
        }

        if (_banners.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF7EF),
                    Color(0xFFFFE6D1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(isMobile ? 0.12 : 0.22),
                    blurRadius: isMobile ? 18 : 34,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _banners.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        widget.onSlideChanged?.call();
                      },
                      itemBuilder: (_, index) {
                        final banner = _banners[index];
                        return _Slide(
                          key: ValueKey(banner.id),
                          banner: banner,
                          imageUrl: _imageUrl(banner.imageUrl),
                          isMobile: isMobile,
                          onTap: () => widget.onBannerTap?.call(banner.link),
                        );
                      },
                    ),
                    Positioned(
                      left: isMobile ? 14 : 24,
                      right: isMobile ? 14 : 24,
                      bottom: isMobile ? 12 : 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _BottomIndicators(
                              total: _banners.length,
                              current: _currentPage,
                              onTap: _animateTo,
                            ),
                          ),
                          if (_banners.length > 1 && !isMobile) ...[
                            const SizedBox(width: 16),
                            _ArrowButton(
                              icon: Icons.arrow_back_rounded,
                              visible: _hovering,
                              onTap: _prev,
                            ),
                            const SizedBox(width: 10),
                            _ArrowButton(
                              icon: Icons.arrow_forward_rounded,
                              visible: _hovering,
                              onTap: _next,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Slide extends StatefulWidget {
  final BannerModel banner;
  final String imageUrl;
  final bool isMobile;
  final VoidCallback? onTap;

  const _Slide({
    super.key,
    required this.banner,
    required this.imageUrl,
    required this.isMobile,
    this.onTap,
  });

  @override
  State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFF2E1CF)),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textLight.withOpacity(0.8),
            size: 52,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _error = true);
                });
                return const ColoredBox(color: Color(0xFFF3E6D7));
              },
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(color: Color(0xFFF4E7D9));
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: widget.isMobile ? -36 : -28,
              right: widget.isMobile ? -44 : 34,
              child: Container(
                width: widget.isMobile ? 120 : 156,
                height: widget.isMobile ? 120 : 156,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFE3C8).withOpacity(0.72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomIndicators extends StatelessWidget {
  final int total;
  final int current;
  final ValueChanged<int> onTap;

  const _BottomIndicators({
    required this.total,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (index) {
            final isActive = index == current;
            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primaryLight.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool visible;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Ink(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFE3C7)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.textDark, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double height;
  final double radius;

  const _Shimmer({
    required this.height,
    required this.radius,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final value = _ctrl.value;
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Color(0xFFEBD7C4),
                  Color(0xFFF3E5D7),
                  Color(0xFFFFF4EA),
                  Color(0xFFF3E5D7),
                  Color(0xFFEBD7C4),
                ],
                stops: [
                  (value - 0.50).clamp(0.0, 1.0),
                  (value - 0.25).clamp(0.0, 1.0),
                  value.clamp(0.0, 1.0),
                  (value + 0.25).clamp(0.0, 1.0),
                  (value + 0.50).clamp(0.0, 1.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
