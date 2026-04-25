import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/banner_service.dart';

/// KFC-style full-width promotional banner carousel.
/// • Edge-to-edge, zero border radius
/// • Slide indicators at the TOP (white rectangles)
/// • Minimal left/right edge arrows
/// • No gradient scrim, no text overlay
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
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  bool _hovering = false;
  Timer? _timer;

  /// Actual aspect ratio of the first banner image (width ÷ height).
  /// Null until the image resolves. Used on mobile to set the exact height
  /// so BoxFit.cover fills the banner with zero black bars and zero cropping.
  double? _imageAspectRatio;

  static const String _proxyBase = 'https://api.saborly.es/api/proxy';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DynamicPromotionalBanner old) {
    super.didUpdateWidget(old);
    if (old.category != widget.category) _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _currentPage = 0; _imageAspectRatio = null; });
    _timer?.cancel();
    final banners = await BannerService.getActiveBanners(category: widget.category);
    if (!mounted) return;
    setState(() { _banners = banners; _isLoading = false; });
    if (widget.autoPlay && _banners.length > 1) _startTimer();
    // Resolve the first image to learn its real aspect ratio.
    // Once known, the banner height snaps to the image ratio → zero black bars.
    if (_banners.isNotEmpty) _resolveImageRatio(_imageUrl(_banners[0].imageUrl));
  }

  void _resolveImageRatio(String url) {
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener((info, _) {
        if (!mounted) return;
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (h > 0 && w > 0) {
          setState(() => _imageAspectRatio = w / h);
        }
      }, onError: (_, __) {}),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!mounted || _banners.isEmpty || !_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
        (_currentPage + 1) % _banners.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _prev() {
    if (!_pageCtrl.hasClients || _banners.isEmpty) return;
    _pageCtrl.animateToPage(
      (_currentPage - 1 + _banners.length) % _banners.length,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (!_pageCtrl.hasClients || _banners.isEmpty) return;
    _pageCtrl.animateToPage(
      (_currentPage + 1) % _banners.length,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  String _imageUrl(String raw) {
    if (kIsWeb && raw.startsWith('http')) {
      return '$_proxyBase/image?url=${Uri.encodeComponent(raw)}';
    }
    return raw;
  }

  double _bannerHeight(double w) {
    if (widget.height != null) return widget.height!;

    final isMobile = w < 768;

    if (!isMobile) {
      // Web / tablet — fixed impactful heights
      if (w >= 1400) return (w * 0.36).clamp(460.0, 580.0);
      if (w >= 1024) return (w * 0.38).clamp(380.0, 480.0);
      return (w * 0.40).clamp(300.0, 380.0);
    }

    // Mobile — use the image's REAL aspect ratio so BoxFit.cover fills the
    // banner perfectly: zero black bars at top/bottom, zero side cropping.
    // Falls back to 2.6:1 until the image resolves (first frame only).
    final ratio = _imageAspectRatio ?? 2.6;
    return (w / ratio).clamp(100.0, 260.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = _bannerHeight(w);
        final isMobile = w < 768;

        if (_isLoading) {
          return _Shimmer(height: h);
        }
        if (_banners.isEmpty) return const SizedBox.shrink();

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit:  (_) => setState(() => _hovering = false),
          child: SizedBox(
            width: double.infinity,
            height: h,
            child: Stack(
              fit: StackFit.expand,
              children: [

                // ── PAGE VIEW (no clip needed — no border radius) ────────────
                PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _banners.length,
                  onPageChanged: (i) {
                    setState(() => _currentPage = i);
                    widget.onSlideChanged?.call();
                  },
                  itemBuilder: (_, i) => _Slide(
                    key: ValueKey(_banners[i].id),
                    imageUrl: _imageUrl(_banners[i].imageUrl),
                    isMobile: isMobile,
                    index: i,
                    onTap: () => widget.onBannerTap?.call(_banners[i].link),
                  ),
                ),

                // ── TOP INDICATOR PILLS (KFC style) ──────────────────────────
                if (_banners.length > 1)
                  Positioned(
                    left: 0, right: 0, top: 12,
                    child: _TopIndicators(
                      total: _banners.length,
                      current: _currentPage,
                      onTap: (i) {
                        if (_pageCtrl.hasClients) {
                          _pageCtrl.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),

                // ── LEFT ARROW ────────────────────────────────────────────────
                if (_banners.length > 1)
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: _EdgeArrow(
                      icon: Icons.chevron_left_rounded,
                      hovering: _hovering,
                      isMobile: isMobile,
                      onTap: _prev,
                    ),
                  ),

                // ── RIGHT ARROW ───────────────────────────────────────────────
                if (_banners.length > 1)
                  Positioned(
                    right: 0, top: 0, bottom: 0,
                    child: _EdgeArrow(
                      icon: Icons.chevron_right_rounded,
                      hovering: _hovering,
                      isMobile: isMobile,
                      onTap: _next,
                    ),
                  ),

              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single full-cover slide
// ─────────────────────────────────────────────────────────────────────────────
class _Slide extends StatefulWidget {
  final String imageUrl;
  final bool isMobile;
  final int index;
  final VoidCallback? onTap;
  const _Slide({
    super.key,
    required this.imageUrl,
    required this.isMobile,
    required this.index,
    this.onTap,
  });
  @override State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: const Color(0xFFF0F0F0),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: Color(0xFFBDBDBD), size: 52),
          ),
        ),
      );
    }
    // BoxFit.cover on ALL platforms.
    // On mobile the banner height is set to exactly match the image's real
    // aspect ratio (detected via _resolveImageRatio), so cover fills the
    // container with zero black bars AND zero side-cropping.
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _error = true);
              });
              return const ColoredBox(color: Color(0xFFF0F0F0));
            },
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xFFEEEEEE),
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top indicator pills — exactly like KFC (white rectangles at top-center)
// ─────────────────────────────────────────────────────────────────────────────
class _TopIndicators extends StatelessWidget {
  final int total;
  final int current;
  final ValueChanged<int> onTap;

  const _TopIndicators({
    required this.total,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 40.0 : 32.0,
            height: 5.0,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimal edge arrow — like KFC's `<` `>` at banner sides
// ─────────────────────────────────────────────────────────────────────────────
class _EdgeArrow extends StatelessWidget {
  final IconData icon;
  final bool hovering;
  final bool isMobile;
  final VoidCallback onTap;

  const _EdgeArrow({
    required this.icon,
    required this.hovering,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mobile: always 75% visible (user confirmed looks nice — don't change)
    // Web: invisible at rest, fully visible on hover
    final opacity = isMobile ? 0.75 : (hovering ? 1.0 : 0.0);
    // Web arrows are larger and more prominent
    final size       = isMobile ? 32.0 : 48.0;
    final iconSize   = isMobile ? 16.0 : 22.0;
    final inset      = isMobile ?  0.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Center(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isMobile ? 0.18 : 0.25),
                    blurRadius: isMobile ? 8 : 16,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.textDark,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final double height;
  const _Shimmer({required this.height});
  @override State<_Shimmer> createState() => _ShimmerState();
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = _ctrl.value;
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Color(0xFFEEEEEE),
                  Color(0xFFE4E4E4),
                  Color(0xFFD8D8D8),
                  Color(0xFFE4E4E4),
                  Color(0xFFEEEEEE),
                ],
                stops: [
                  (v - 0.50).clamp(0.0, 1.0),
                  (v - 0.25).clamp(0.0, 1.0),
                  v.clamp(0.0, 1.0),
                  (v + 0.25).clamp(0.0, 1.0),
                  (v + 0.50).clamp(0.0, 1.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
