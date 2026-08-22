import 'dart:async';
import 'dart:ui';

import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/banner_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutQuart,
      );
    });
  }

  void _animateTo(int index) {
    if (!_pageCtrl.hasClients || _banners.isEmpty) return;
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuart,
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
      if (width >= 1400) return 480;
      if (width >= 1100) return 400;
      return 340;
    }

    final ratio = _imageAspectRatio ?? 2.0;
    return (width / ratio).clamp(200.0, 320.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 768;
        final height = _bannerHeight(width);
        final radius = isMobile ? 16.0 : 32.0;

        if (_isLoading) {
          return _Shimmer(height: height, radius: radius);
        }

        if (_banners.isEmpty) return const SizedBox.shrink();

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedScale(
            scale: _hovering && !isMobile ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.primary.withOpacity(isMobile ? 0.05 : 0.15),
                    blurRadius: isMobile ? 20 : 45,
                    offset: const Offset(0, 20),
                    spreadRadius: -10,
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

                    // Gradient Overlay for readability
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4],
                          ),
                        ),
                      ),
                    ),

                    // Navigation Controls
                    if (_banners.length > 1)
                      Positioned(
                        left: isMobile ? 16 : 24,
                        right: isMobile ? 16 : 24,
                        bottom: isMobile ? 16 : 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _BottomIndicators(
                              total: _banners.length,
                              current: _currentPage,
                              onTap: _animateTo,
                            ),
                            if (!isMobile)
                              Row(
                                children: [
                                  _GlassButton(
                                    icon: Icons.chevron_left_rounded,
                                    visible: _hovering,
                                    onTap: _prev,
                                  ),
                                  const SizedBox(width: 12),
                                  _GlassButton(
                                    icon: Icons.chevron_right_rounded,
                                    visible: _hovering,
                                    onTap: _next,
                                  ),
                                ],
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
      return Container(
        color: const Color(0xFFF9F1EA),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: AppColors.textLight, size: 48),
            const SizedBox(height: 12),
            Text("Image unavailable",
                style: TextStyle(color: AppColors.textLight, fontSize: 14)),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dpr = MediaQuery.of(context).devicePixelRatio;
            final targetWidth = constraints.maxWidth.isFinite
                ? (constraints.maxWidth * dpr).round()
                : null;

            // CachedNetworkImage persists banner images to disk so
            // navigating back to Home doesn't re-download them every time.
            if (!kIsWeb) {
              return CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: targetWidth,
                errorWidget: (_, __, ___) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _error = true);
                  });
                  return const SizedBox.shrink();
                },
                placeholder: (_, __) => Container(color: const Color(0xFFFBF4EE)),
              );
            }

            return Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              cacheWidth: targetWidth,
              errorBuilder: (_, __, ___) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _error = true);
                });
                return const SizedBox.shrink();
              },
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(color: const Color(0xFFFBF4EE));
              },
            );
          },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (index) {
          final isActive = index == current;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final bool visible;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withOpacity(0.25),
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
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
      duration: const Duration(milliseconds: 1800),
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
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFF7EFE8),
                Color(0xFFFBF4EE),
                Color(0xFFFFF9F3),
                Color(0xFFFBF4EE),
                Color(0xFFF7EFE8),
              ],
              stops: [
                (_ctrl.value - 0.4).clamp(0.0, 1.0),
                (_ctrl.value - 0.2).clamp(0.0, 1.0),
                _ctrl.value.clamp(0.0, 1.0),
                (_ctrl.value + 0.2).clamp(0.0, 1.0),
                (_ctrl.value + 0.4).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
