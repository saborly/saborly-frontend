import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/videos/data/saborly_videos.dart';
import 'package:Saborly/features/videos/screens/video_reels_viewer.dart';
import 'package:Saborly/features/videos/widgets/saborly_badge.dart';

/// Home-page strip of vertical (9:16) video cards that opens
/// [VideoReelsViewer].
///
/// Cards come alive with a silent, looping inline preview — at most one at a
/// time, so only a single decoder is ever running here:
/// * web/desktop: the card under the mouse (after a short hover delay);
/// * native app: the leading card, while the strip is actually on screen.
/// Mobile web gets posters only, to avoid spending visitors' data.
///
/// Previews stop whenever the strip scrolls out of view, another page covers
/// the home screen, the viewer opens, or the app goes to the background.
class VideoShowcaseSection extends StatefulWidget {
  final bool isWeb;
  final List<SaborlyVideo> videos;

  const VideoShowcaseSection({
    super.key,
    this.isWeb = false,
    this.videos = saborlyVideos,
  });

  @override
  State<VideoShowcaseSection> createState() => _VideoShowcaseSectionState();
}

class _VideoShowcaseSectionState extends State<VideoShowcaseSection> with WidgetsBindingObserver {
  // Room above/below the cards so the hover lift and shadow aren't clipped.
  static const double _verticalBleed = 12;
  static const Duration _hoverDelay = Duration(milliseconds: 350);

  /// Native apps preview automatically; the web previews on hover only.
  static const bool _autoPreview = !kIsWeb;

  final ScrollController _scrollController = ScrollController();
  bool _canScrollBack = false;
  bool _canScrollForward = false;
  double _cardStride = 1;

  VideoPlayerController? _preview;
  int? _previewIndex;
  Timer? _hoverTimer;
  Timer? _visibilityDebounce;
  ScrollPosition? _pagePosition;
  ValueListenable<TickerModeData>? _tickerMode;
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
    WidgetsBinding.instance.addObserver(this);
    VideoReelsViewer.isOpen.addListener(_onViewerOpenChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateArrows();
      _scheduleAutoPreview();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The page's own scroll view — used to know when the strip is on screen.
    final pagePosition = Scrollable.maybeOf(context)?.position;
    if (pagePosition != _pagePosition) {
      _pagePosition?.removeListener(_scheduleAutoPreview);
      _pagePosition = pagePosition?..addListener(_scheduleAutoPreview);
    }
    // Disabled when another opaque page is pushed over the home screen.
    final tickerMode = TickerMode.getValuesNotifier(context);
    if (tickerMode != _tickerMode) {
      _tickerMode?.removeListener(_onTickerModeChanged);
      _tickerMode = tickerMode..addListener(_onTickerModeChanged);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    VideoReelsViewer.isOpen.removeListener(_onViewerOpenChanged);
    _pagePosition?.removeListener(_scheduleAutoPreview);
    _tickerMode?.removeListener(_onTickerModeChanged);
    _hoverTimer?.cancel();
    _visibilityDebounce?.cancel();
    _preview?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    if (_appActive) {
      _scheduleAutoPreview();
    } else if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      _stopPreview();
    }
  }

  void _onViewerOpenChanged() {
    if (VideoReelsViewer.isOpen.value) {
      _stopPreview();
    } else {
      _scheduleAutoPreview();
    }
  }

  void _onTickerModeChanged() {
    // Notified while the navigator rebuilds; act once that build is done.
    scheduleMicrotask(() {
      if (!mounted) return;
      if (_tickerMode?.value.enabled ?? true) {
        _scheduleAutoPreview();
      } else {
        _stopPreview();
      }
    });
  }

  // ── Scroll arrows (web) ────────────────────────────────────────────────

  void _updateArrows() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final back = position.pixels > position.minScrollExtent + 4;
    final forward = position.pixels < position.maxScrollExtent - 4;
    if (back != _canScrollBack || forward != _canScrollForward) {
      setState(() {
        _canScrollBack = back;
        _canScrollForward = forward;
      });
    }
  }

  void _scrollByPage(int direction) {
    final position = _scrollController.position;
    final target = (position.pixels + direction * position.viewportDimension * 0.8)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Previews ───────────────────────────────────────────────────────────

  bool get _previewAllowed =>
      mounted && _appActive && !VideoReelsViewer.isOpen.value && (_tickerMode?.value.enabled ?? true);

  /// Debounced so page scrolling doesn't re-evaluate on every frame.
  void _scheduleAutoPreview() {
    if (!_autoPreview) return;
    _visibilityDebounce?.cancel();
    _visibilityDebounce = Timer(const Duration(milliseconds: 220), _evaluateAutoPreview);
  }

  void _evaluateAutoPreview() {
    if (!_autoPreview || !mounted) return;
    if (!_previewAllowed || !_isStripOnScreen()) {
      _stopPreview();
      return;
    }
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final leading = (offset / _cardStride).round().clamp(0, widget.videos.length - 1);
    if (leading != _previewIndex) _startPreview(leading);
  }

  /// True when at least 60% of the strip's height is inside the screen.
  bool _isStripOnScreen() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final visible = (bottom.clamp(0.0, screenHeight) - top.clamp(0.0, screenHeight));
    return visible >= box.size.height * 0.6;
  }

  Future<void> _startPreview(int index) async {
    _stopPreview();
    if (!_previewAllowed) return;

    final controller = VideoPlayerController.asset(
      widget.videos[index].videoAsset,
      // A silent preview must never interrupt the user's own music/podcast.
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    setState(() {
      _preview = controller;
      _previewIndex = index;
    });

    try {
      await controller.initialize();
    } catch (_) {
      // Previews are decorative; the poster simply stays.
      if (_preview == controller) _stopPreview();
      return;
    }
    if (!mounted || _preview != controller) return;
    await controller.setVolume(0);
    await controller.setLooping(true);
    await controller.play();
    if (mounted) setState(() {});
  }

  void _stopPreview() {
    _hoverTimer?.cancel();
    final controller = _preview;
    if (controller == null && _previewIndex == null) return;
    _preview = null;
    _previewIndex = null;
    controller?.dispose();
    if (mounted) setState(() {});
  }

  void _onCardHover(int index, bool hovering) {
    if (_autoPreview) return;
    _hoverTimer?.cancel();
    if (hovering) {
      _hoverTimer = Timer(_hoverDelay, () => _startPreview(index));
    } else if (_previewIndex == index) {
      _stopPreview();
    }
  }

  void _open(int index) {
    VideoReelsViewer.open(context, videos: widget.videos, initialIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Fractional counts leave the next card peeking in, which signals the
        // strip scrolls.
        final visibleCards = width < 600 ? 1.85 : (width < 1000 ? 3.2 : 5.2);
        final gap = width < 600 ? 12.0 : 18.0;
        final cardWidth = (width - gap * visibleCards.floor()) / visibleCards;
        final cardHeight = cardWidth * 16 / 9;
        _cardStride = cardWidth + gap;

        return SizedBox(
          height: cardHeight + _verticalBleed * 2,
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) _scheduleAutoPreview();
                  return false;
                },
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (_) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _updateArrows();
                    });
                    return false;
                  },
                  child: ScrollConfiguration(
                    // Let mouse users drag the strip on web, not just scroll.
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                      },
                    ),
                    child: ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: _verticalBleed),
                      itemCount: widget.videos.length,
                      separatorBuilder: (_, __) => SizedBox(width: gap),
                      itemBuilder: (context, index) => _VideoCard(
                        video: widget.videos[index],
                        width: cardWidth,
                        height: cardHeight,
                        preview: _previewIndex == index ? _preview : null,
                        onHover: (hovering) => _onCardHover(index, hovering),
                        onTap: () => _open(index),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.isWeb) ...[
                _ScrollArrow(
                  visible: _canScrollBack,
                  isStart: true,
                  tooltip: AppStrings.get('videoPrevious'),
                  onTap: () => _scrollByPage(-1),
                ),
                _ScrollArrow(
                  visible: _canScrollForward,
                  isStart: false,
                  tooltip: AppStrings.get('videoNext'),
                  onTap: () => _scrollByPage(1),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _VideoCard extends StatefulWidget {
  final SaborlyVideo video;
  final double width;
  final double height;
  final VideoPlayerController? preview;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _VideoCard({
    required this.video,
    required this.width,
    required this.height,
    required this.preview,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _hovered = false;

  void _setHovered(bool value) {
    setState(() => _hovered = value);
    widget.onHover(value);
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final width = widget.width;
    final preview = widget.preview;
    final radius = BorderRadius.circular((width * 0.1).clamp(16.0, 24.0));
    final playSize = (width * 0.26).clamp(42.0, 60.0);
    final titleSize = (width * 0.074).clamp(13.0, 16.0);
    final inset = (width * 0.065).clamp(10.0, 16.0);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Semantics(
      button: true,
      label: '${AppStrings.get('videoPlay')}: ${video.title}',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: width,
            height: widget.height,
            transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: _hovered ? 0.42 : 0.24),
                  blurRadius: _hovered ? 24 : 14,
                  offset: Offset(0, _hovered ? 14 : 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedScale(
                    scale: _hovered ? 1.05 : 1,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          video.posterAsset,
                          fit: BoxFit.cover,
                          cacheWidth: (width * dpr).round(),
                          errorBuilder: (_, __, ___) => const DecoratedBox(
                            decoration: BoxDecoration(gradient: AppColors.heroGradient),
                          ),
                        ),
                        if (preview != null) _InlinePreview(controller: preview),
                      ],
                    ),
                  ),
                  // Keeps the chips and caption legible on any frame.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x00000000),
                          Color(0x00000000),
                          Color(0xB3120906),
                          Color(0xF2120906),
                        ],
                        stops: [0, 0.2, 0.45, 0.78, 1],
                      ),
                    ),
                  ),
                  // Hairline inner border gives the card a finished edge.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                  ),
                  PositionedDirectional(
                    top: inset,
                    start: inset,
                    end: inset,
                    // No Spacer: with one the tag could only ever get half the
                    // row and was truncated ("ON THE…").
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: _TagChip(label: video.tag.label)),
                        if (preview != null) ...[
                          const SizedBox(width: 6),
                          const _MutedPreviewChip(),
                        ],
                      ],
                    ),
                  ),
                  Center(
                    child: _PlayButton(
                      size: playSize,
                      highlighted: _hovered,
                      // Step aside for the preview unless the pointer is on
                      // the card (where it doubles as the click affordance).
                      visible: preview == null || _hovered,
                    ),
                  ),
                  PositionedDirectional(
                    start: inset,
                    end: inset,
                    bottom: inset,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SaborlyBadge(size: 20, showName: true, nameSize: 11.5),
                        const SizedBox(height: 8),
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                            shadows: const [Shadow(color: Color(0x80000000), blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.play_circle_fill_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              formatVideoDuration(video.duration),
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (preview != null)
                    Positioned(left: 0, right: 0, bottom: 0, child: _PreviewProgress(controller: preview)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The preview video, cropped to fill the card, faded in over the poster
/// once its first frame is ready.
class _InlinePreview extends StatelessWidget {
  final VideoPlayerController controller;

  const _InlinePreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final ready = value.isInitialized && value.size.width > 0;
        return AnimatedOpacity(
          opacity: ready && value.isPlaying ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: ready
              ? FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: value.size.width,
                    height: value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              : const SizedBox.expand(),
        );
      },
    );
  }
}

class _PreviewProgress extends StatelessWidget {
  final VideoPlayerController controller;

  const _PreviewProgress({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final total = value.duration.inMilliseconds;
        final progress = total > 0 ? (value.position.inMilliseconds / total).clamp(0.0, 1.0) : 0.0;
        return Align(
          alignment: AlignmentDirectional.centerStart,
          heightFactor: 1, // hug the bar, don't stretch to the card height
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  final double size;
  final bool highlighted;
  final bool visible;

  const _PlayButton({required this.size, required this.highlighted, required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      child: AnimatedScale(
        scale: highlighted ? 1.1 : 1,
        duration: const Duration(milliseconds: 220),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlighted ? AppColors.primary : Colors.white.withValues(alpha: 0.92),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: size * 0.6,
            color: highlighted ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Signals that the moving card is a silent preview, not playing with sound.
class _MutedPreviewChip extends StatelessWidget {
  const _MutedPreviewChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.volume_off_rounded, size: 14, color: Colors.white),
    );
  }
}

/// Round prev/next control over the strip's edge (web only — touch users
/// swipe). Placed by text direction so it mirrors correctly in Arabic.
class _ScrollArrow extends StatelessWidget {
  final bool visible;
  final bool isStart;
  final String tooltip;
  final VoidCallback onTap;

  const _ScrollArrow({
    required this.visible,
    required this.isStart,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: isStart ? 6 : null,
      end: isStart ? null : 6,
      top: 0,
      bottom: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !visible,
            child: Tooltip(
              message: tooltip,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: AppColors.shadow,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  hoverColor: AppColors.premiumAccent,
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(
                      isStart ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                      size: 28,
                      color: AppColors.textDark,
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
}
