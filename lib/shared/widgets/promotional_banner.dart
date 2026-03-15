import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Saborly/core/services/banner_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DynamicPromotionalBanner — Premium hero carousel
//
//  • Cinematic 800 ms crossfade between slides (no page-swipe)
//  • Ken Burns subtle zoom (1.0 → 1.05) on the active slide
//  • Dual gradient overlay: soft top + rich bottom vignette
//  • Thin animated autoplay progress bar (fills across slide duration)
//  • Slide counter "01 / 03" (bottom-left, desktop/tablet)
//  • Pill dot indicators (clickable, animated)
//  • Reveal-on-hover glass arrow buttons with scale + opacity animation
//  • Warm shimmer skeleton while loading
//  • Hover-pause autoplay
//  • Full-width edge-to-edge; supports borderRadius
//  • Responsive heights: mobile 200–260 px · tablet 360–480 px · desktop 540–680 px
// ─────────────────────────────────────────────────────────────────────────────

class DynamicPromotionalBanner extends StatefulWidget {
  final String? category;
  final double? height;
  final Duration autoPlayDuration;
  final bool autoPlay;
  final VoidCallback? onSlideChanged;
  final BorderRadius? borderRadius;
  final Function(String? link)? onBannerTap;

  const DynamicPromotionalBanner({
    super.key,
    this.category,
    this.height,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.autoPlay = true,
    this.onSlideChanged,
    this.borderRadius,
    this.onBannerTap,
  });

  @override
  State<DynamicPromotionalBanner> createState() =>
      _DynamicPromotionalBannerState();
}

class _DynamicPromotionalBannerState extends State<DynamicPromotionalBanner>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _autoPlayTimer;
  bool _isHovered = false;
  bool _isFading = false;

  // Autoplay progress bar
  AnimationController? _progressCtrl;
  Animation<double>? _progressAnim;

  static const String _proxyBaseUrl = 'https://api.saborly.es/api/proxy';
  final Map<int, bool> _imageLoadErrors = {};

  /// Transparent 1×1 PNG placeholder for FadeInImage.
  static final Uint8List _kTransparentImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: widget.autoPlayDuration,
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl!,
      curve: Curves.linear,
    );
    _loadBanners();
  }

  @override
  void didUpdateWidget(DynamicPromotionalBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) _loadBanners();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _progressCtrl?.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────
  Future<void> _loadBanners() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageLoadErrors.clear();
      _currentIndex = 0;
    });
    _stopAutoPlay();

    try {
      final banners =
          await BannerService.getActiveBanners(category: widget.category);
      if (!mounted) return;

      if (banners.isEmpty) {
        setState(() {
          _errorMessage = 'No banners available';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _banners = banners;
        _isLoading = false;
      });

      if (widget.autoPlay && mounted && _banners.length > 1) _startAutoPlay();
    } catch (e) {
      debugPrint('Banner load error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load banners';
        _isLoading = false;
      });
    }
  }

  // ── Autoplay ─────────────────────────────────────────────────────────────────
  void _startAutoPlay() {
    _stopAutoPlay();
    if (_isHovered) return;
    _progressCtrl?.forward(from: 0);
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!mounted || _isHovered || _banners.isEmpty) return;
      _goToSlide((_currentIndex + 1) % _banners.length);
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _progressCtrl?.stop();
  }

  void _goToSlide(int index) {
    if (!mounted || _isFading || index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _isFading = true;
    });
    widget.onSlideChanged?.call();

    // Restart progress bar
    if (widget.autoPlay && !_isHovered && _banners.length > 1) {
      _progressCtrl?.forward(from: 0);
    }

    // Let the AnimatedSwitcher finish its 800 ms fade
    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => _isFading = false);
    });
  }

  // ── URL proxy ────────────────────────────────────────────────────────────────
  String _getProxiedUrl(String url) {
    if (url.contains('vercel-storage.com') ||
        url.contains('blob.vercel-storage.com')) {
      return '$_proxyBaseUrl/image?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  // ── Responsive height ────────────────────────────────────────────────────────
  double _calculateHeight(double w, double h) {
    if (w >= 1200) return (h * 0.65).clamp(540.0, 680.0);
    if (w >= 1024) return (h * 0.60).clamp(480.0, 600.0);
    if (w >= 768)  return (h * 0.52).clamp(360.0, 480.0);
    if (w >= 480)  return (h * 0.42).clamp(240.0, 300.0);
    return (h * 0.38).clamp(200.0, 260.0);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildShimmer(context);
    if (_errorMessage != null || _banners.isEmpty) return const SizedBox.shrink();

    final mq    = MediaQuery.of(context);
    final sw    = mq.size.width;
    final sh    = mq.size.height;
    final bannerH = widget.height ?? _calculateHeight(sw, sh);
    final isMobile = sw < 768;
    final br = widget.borderRadius ?? BorderRadius.zero;

    return MouseRegion(
      onEnter: (_) {
        if (!_isHovered) {
          setState(() => _isHovered = true);
          _stopAutoPlay();
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() => _isHovered = false);
          if (widget.autoPlay && _banners.length > 1) _startAutoPlay();
        }
      },
      child: SizedBox(
        height: bannerH,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: br,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Slide images (crossfade via AnimatedSwitcher) ────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _buildSlide(_currentIndex, bannerH),
              ),

              // ── 2. Dual gradient overlay ─────────────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15), // soft top for nav
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.60), // rich bottom
                      ],
                      stops: const [0.0, 0.18, 0.52, 1.0],
                    ),
                  ),
                ),
              ),

              // ── 3. Bottom info bar: counter + dots ──────────────────────────
              if (_banners.length > 1)
                Positioned(
                  bottom: 6,   // sits just above the 2.5 px progress strip
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : 28.0,
                      vertical:   isMobile ? 10.0 : 14.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Slide counter (desktop / tablet only)
                        if (!isMobile) _buildSlideCounter(),
                        const Spacer(),
                        _buildDots(isMobile),
                        const Spacer(),
                        // Mirror element so dots stay perfectly centred
                        if (!isMobile) const SizedBox(width: 52),
                      ],
                    ),
                  ),
                ),

              // ── 4. Autoplay progress bar (very bottom strip) ────────────────
              if (widget.autoPlay && _banners.length > 1 && _progressAnim != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _progressAnim!,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progressAnim!.value,
                      minHeight: 3,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ),
                ),

              // ── 5. Left / right arrows (desktop & tablet, reveal on hover) ─
              if (!isMobile && _banners.length > 1) ...[
                _buildArrow(isLeft: true),
                _buildArrow(isLeft: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Slide ────────────────────────────────────────────────────────────────────
  Widget _buildSlide(int index, double height) {
    return GestureDetector(
      key: ValueKey<int>(index),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final link = _banners[index].link;
        if (widget.onBannerTap != null) {
          widget.onBannerTap!(link);
        }
      },
      child: _imageLoadErrors.containsKey(index)
          ? _buildBrokenSlide()
          : _KenBurnsSlide(
              key: ValueKey('kb_$index'),
              imageUrl: _getProxiedUrl(_banners[index].imageUrl),
              isActive: index == _currentIndex,
              placeholder: MemoryImage(_kTransparentImage),
              onError: (_) {
                if (mounted) setState(() => _imageLoadErrors[index] = true);
              },
            ),
    );
  }

  Widget _buildBrokenSlide() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 44, color: Colors.white24),
      ),
    );
  }

  // ── Slide counter ─────────────────────────────────────────────────────────────
  Widget _buildSlideCounter() {
    final current = (_currentIndex + 1).toString().padLeft(2, '0');
    final total   = _banners.length.toString().padLeft(2, '0');
    return Text(
      '$current / $total',
      style: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.50),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  // ── Navigation arrows ─────────────────────────────────────────────────────────
  Widget _buildArrow({required bool isLeft}) {
    return Positioned(
      left:   isLeft ? 20 : null,
      right:  isLeft ? null : 20,
      top: 0,
      bottom: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: _isHovered ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 220),
          child: AnimatedScale(
            scale: _isHovered ? 1.0 : 0.80,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: !_isHovered,
              child: GestureDetector(
                onTap: isLeft
                    ? () => _goToSlide(
                        (_currentIndex - 1 + _banners.length) % _banners.length)
                    : () => _goToSlide((_currentIndex + 1) % _banners.length),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      isLeft
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 30,
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

  // ── Dot indicators ────────────────────────────────────────────────────────────
  Widget _buildDots(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_banners.length, (i) {
        final isActive = i == _currentIndex;
        return GestureDetector(
          onTap: () => _goToSlide(i),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInOut,
                width:  isActive ? 28 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(3.5),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.35),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────────
  Widget _buildShimmer(BuildContext context) {
    final mq = MediaQuery.of(context);
    final h  = _calculateHeight(mq.size.width, mq.size.height);
    return _ShimmerBox(height: h);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KenBurnsSlide — Subtle zoom 1.0 → 1.05 while active, resets on deactivate
// ─────────────────────────────────────────────────────────────────────────────
class _KenBurnsSlide extends StatefulWidget {
  final String imageUrl;
  final bool isActive;
  final ImageProvider placeholder;
  final void Function(Object error)? onError;

  const _KenBurnsSlide({
    super.key,
    required this.imageUrl,
    required this.isActive,
    required this.placeholder,
    this.onError,
  });

  @override
  State<_KenBurnsSlide> createState() => _KenBurnsSlideState();
}

class _KenBurnsSlideState extends State<_KenBurnsSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_KenBurnsSlide old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl
        ..reset()
        ..forward();
    } else if (!widget.isActive && old.isActive) {
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: SizedBox.expand(
        child: FadeInImage(
          placeholder: widget.placeholder,
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 700),
          fadeInCurve: Curves.easeIn,
          imageErrorBuilder: (_, error, __) {
            widget.onError?.call(error);
            return const ColoredBox(color: Color(0xFF1A1A1A));
          },
          placeholderErrorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerBox — Warm animated skeleton placeholder while banners load
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double height;
  const _ShimmerBox({required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);
    _anim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Color(0xFF1C1C1C),
                  Color(0xFF2A2A2A),
                  Color(0xFF323232),
                  Color(0xFF2A2A2A),
                  Color(0xFF1C1C1C),
                ],
                stops: [
                  (_anim.value - 0.5).clamp(0.0, 1.0),
                  (_anim.value - 0.25).clamp(0.0, 1.0),
                  _anim.value.clamp(0.0, 1.0),
                  (_anim.value + 0.25).clamp(0.0, 1.0),
                  (_anim.value + 0.5).clamp(0.0, 1.0),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white.withOpacity(0.06),
                size: 64,
              ),
            ),
          ),
        );
      },
    );
  }
}
