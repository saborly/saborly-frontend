import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/videos/data/saborly_videos.dart';
import 'package:Saborly/features/videos/widgets/saborly_badge.dart';

/// Immersive, Reels-style player for [SaborlyVideo]s.
///
/// * Phones: full screen, swipe up/down between videos.
/// * Wide screens (web/desktop/tablet): a centred 9:16 frame over a dimmed
///   backdrop, navigated with the side arrows, mouse wheel, drag, or keyboard
///   (↑/↓/←/→, Space, M, Esc).
///
/// Only the current video and its two neighbours hold a player at any time,
/// so swiping is instant without keeping a decoder per video alive.
class VideoReelsViewer extends StatefulWidget {
  final List<SaborlyVideo> videos;
  final int initialIndex;

  const VideoReelsViewer({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  /// True while the viewer is on screen, so inline previews elsewhere (the
  /// home strip) can stop and free their decoder. Set here rather than in
  /// the state's lifecycle so listeners never run in the middle of a build.
  static final ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);

  static Future<void> open(
    BuildContext context, {
    required List<SaborlyVideo> videos,
    int initialIndex = 0,
  }) async {
    isOpen.value = true;
    try {
      await Navigator.of(context, rootNavigator: true).push(_route(videos, initialIndex));
    } finally {
      isOpen.value = false;
    }
  }

  static Route<void> _route(List<SaborlyVideo> videos, int initialIndex) {
    return PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => VideoReelsViewer(videos: videos, initialIndex: initialIndex),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<VideoReelsViewer> createState() => _VideoReelsViewerState();
}

class _VideoReelsViewerState extends State<VideoReelsViewer> with WidgetsBindingObserver {
  /// Remembered for the rest of the session. Web starts muted: browsers only
  /// allow playback with sound after certain user gestures, and a rejected
  /// play() leaves the web player unusable.
  static bool _sessionMuted = kIsWeb;

  static const double _wideBreakpoint = 700;

  late final PageController _pageController;
  late int _index;
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _failed = {};
  bool _muted = _sessionMuted;
  bool _showSoundHint = kIsWeb && _sessionMuted;
  bool _resumeOnForeground = false;
  int _advancedFrom = -1;
  Timer? _wheelCooldown;

  List<SaborlyVideo> get _videos => widget.videos;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _videos.length - 1);
    _pageController = PageController(initialPage: _index);
    WidgetsBinding.instance.addObserver(this);
    _syncControllers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wheelCooldown?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final current = _controllers[_index];
    if (current == null) return;
    if (state == AppLifecycleState.resumed) {
      if (_resumeOnForeground) current.play();
      _resumeOnForeground = false;
    } else if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      // Not `inactive`: on web that fires whenever the window loses focus,
      // which would pause the video while it's still on screen.
      if (current.value.isPlaying) {
        _resumeOnForeground = true;
        current.pause();
      }
    }
  }

  // ── Player management ──────────────────────────────────────────────────

  void _syncControllers() {
    final keep = {_index - 1, _index, _index + 1}.where((i) => i >= 0 && i < _videos.length).toSet();

    for (final i in _controllers.keys.toList()) {
      if (!keep.contains(i)) _disposeController(i);
    }
    for (final i in keep) {
      if (!_controllers.containsKey(i) && !_failed.contains(i)) _createController(i);
    }

    final current = _controllers[_index];
    if (current != null && current.value.isInitialized && !current.value.isPlaying) {
      current
        ..setVolume(_muted ? 0 : 1)
        ..play();
    }
  }

  void _createController(int i) {
    final controller = VideoPlayerController.asset(_videos[i].videoAsset);
    _controllers[i] = controller;
    controller.addListener(() => _onControllerUpdate(i, controller));
    controller.initialize().then((_) async {
      if (!mounted || _controllers[i] != controller) return;
      await controller.setVolume(_muted ? 0 : 1);
      if (i == _index) await controller.play();
      if (mounted) setState(() {});
    }).catchError((Object _) {
      // Surfaced through value.hasError and handled in _onControllerUpdate.
    });
  }

  void _disposeController(int i) {
    _controllers.remove(i)?.dispose();
  }

  void _onControllerUpdate(int i, VideoPlayerController controller) {
    if (!mounted || _controllers[i] != controller) return;
    final value = controller.value;

    if (value.hasError) {
      // Deferred: disposing a controller while it notifies its listeners
      // trips a ChangeNotifier assertion.
      scheduleMicrotask(() => _handleError(i, controller));
      return;
    }

    if (i != _index) return;
    if (value.isPlaying && _advancedFrom == i) _advancedFrom = -1;

    final finished = value.isInitialized &&
        value.duration > Duration.zero &&
        !value.isPlaying &&
        value.position >= value.duration - const Duration(milliseconds: 300);
    if (finished && _advancedFrom != i && i < _videos.length - 1) {
      _advancedFrom = i;
      _goTo(i + 1);
    }
  }

  void _handleError(int i, VideoPlayerController controller) {
    if (!mounted || _controllers[i] != controller) return;
    _disposeController(i);

    // A web browser can reject playback with sound; retry once, muted.
    if (kIsWeb && !_muted) {
      _muted = _sessionMuted = true;
      _showSoundHint = true;
      if ((i - _index).abs() <= 1) _createController(i);
    } else {
      _failed.add(i);
    }
    setState(() {});
  }

  void _retry(int i) {
    setState(() => _failed.remove(i));
    _createController(i);
  }

  // ── User actions ───────────────────────────────────────────────────────

  void _onPageChanged(int i) {
    final previous = _controllers[_index];
    if (previous != null && previous.value.isInitialized) {
      previous
        ..pause()
        ..seekTo(Duration.zero);
    }
    setState(() => _index = i);
    _syncControllers();
  }

  void _goTo(int i) {
    if (i < 0 || i >= _videos.length || !_pageController.hasClients) return;
    // Far jumps (from "Up next") cut straight there instead of scrolling
    // through every video in between.
    if ((i - _index).abs() > 1) {
      _pageController.jumpToPage(i);
      return;
    }
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _togglePlay() {
    final current = _controllers[_index];
    if (current == null || !current.value.isInitialized) return;
    current.value.isPlaying ? current.pause() : current.play();
  }

  void _setMuted(bool muted) {
    setState(() {
      _muted = _sessionMuted = muted;
      _showSoundHint = false;
    });
    for (final controller in _controllers.values) {
      if (controller.value.isInitialized) controller.setVolume(muted ? 0 : 1);
    }
  }

  void _close() => Navigator.of(context).maybePop();

  void _orderNow() {
    final router = GoRouter.maybeOf(context);
    Navigator.of(context).pop();
    router?.go(AppRoutes.menu);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _close();
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowRight) {
      _goTo(_index + 1);
    } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowLeft) {
      _goTo(_index - 1);
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyK) {
      _togglePlay();
    } else if (key == LogicalKeyboardKey.keyM) {
      _setMuted(!_muted);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// One video per wheel gesture: navigate on the first event, then ignore
  /// the rest until the wheel/trackpad (including momentum) goes quiet.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final dy = event.scrollDelta.dy;
    if (dy.abs() < 8) return;
    final idle = _wheelCooldown == null;
    _wheelCooldown?.cancel();
    _wheelCooldown = Timer(const Duration(milliseconds: 260), () => _wheelCooldown = null);
    if (idle) _goTo(_index + (dy > 0 ? 1 : -1));
  }

  void _onFrameDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -250) _goTo(_index + 1);
    if (velocity > 250) _goTo(_index - 1);
  }

  // ── Layout ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= _wideBreakpoint;

    final pageView = PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // On wide web layouts the wheel/drag handlers below drive navigation;
      // letting PageView also consume wheel events would fight them.
      physics: wide && kIsWeb ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
      itemCount: _videos.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, i) => _ReelPage(
        key: ValueKey(_videos[i].id),
        video: _videos[i],
        controller: _controllers[i],
        failed: _failed.contains(i),
        isActive: i == _index,
        compact: !wide,
        onTap: _togglePlay,
        onRetry: () => _retry(i),
        onOrderNow: _orderNow,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Material(
          type: MaterialType.transparency,
          child: wide ? _buildWide(size, pageView) : _buildCompact(pageView),
        ),
      ),
    );
  }

  Widget _buildCompact(Widget pageView) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: pageView),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.close_rounded,
                    tooltip: AppStrings.get('close'),
                    onTap: _close,
                  ),
                  const Spacer(),
                  _CounterPill(index: _index, total: _videos.length),
                  const SizedBox(width: 8),
                  _muteButton(),
                ],
              ),
            ),
          ),
          _soundHint(topOffset: MediaQuery.paddingOf(context).top + 64),
        ],
      ),
    );
  }

  Widget _buildWide(Size size, Widget pageView) {
    const gutter = 24.0;
    const navWidth = 48.0;
    const upNextWidth = 290.0;
    final frameHeight = (size.height - 56).clamp(360.0, 900.0);
    final frameWidth = frameHeight * 9 / 16;
    // "Up next" only when there's room for it on both sides — the left side
    // gets an equal spacer so the frame stays centred.
    final showUpNext = size.width >= frameWidth + 2 * (gutter * 2 + navWidth + upNextWidth) + 48;
    final sideWidth = gutter + navWidth + (showUpNext ? gutter + upNextWidth : 0);

    return Listener(
      onPointerSignal: kIsWeb ? _onPointerSignal : null,
      child: Stack(
        children: [
          // Warm near-black backdrop from the brand palette; click to close.
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: ColoredBox(color: AppColors.accentNight.withValues(alpha: 0.94)),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: sideWidth),
                GestureDetector(
                  onVerticalDragEnd: kIsWeb ? _onFrameDragEnd : null,
                  child: Container(
                    width: frameWidth,
                    height: frameHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(color: Color(0x80000000), blurRadius: 60, offset: Offset(0, 24)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [
                          Positioned.fill(child: pageView),
                          PositionedDirectional(
                            top: 14,
                            end: 14,
                            child: Row(
                              children: [
                                _CounterPill(index: _index, total: _videos.length),
                                const SizedBox(width: 8),
                                _muteButton(),
                              ],
                            ),
                          ),
                          _soundHint(topOffset: 68),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: gutter),
                SizedBox(
                  width: navWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassIconButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        tooltip: AppStrings.get('videoPrevious'),
                        size: 48,
                        onTap: _index > 0 ? () => _goTo(_index - 1) : null,
                      ),
                      const SizedBox(height: 14),
                      _GlassIconButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        tooltip: AppStrings.get('videoNext'),
                        size: 48,
                        onTap: _index < _videos.length - 1 ? () => _goTo(_index + 1) : null,
                      ),
                    ],
                  ),
                ),
                if (showUpNext) ...[
                  const SizedBox(width: gutter),
                  _UpNextPanel(
                    videos: _videos,
                    currentIndex: _index,
                    width: upNextWidth,
                    onSelect: _goTo,
                  ),
                ],
              ],
            ),
          ),
          PositionedDirectional(
            top: 20,
            end: 20,
            child: _GlassIconButton(
              icon: Icons.close_rounded,
              tooltip: AppStrings.get('close'),
              size: 48,
              onTap: _close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _muteButton() {
    return _GlassIconButton(
      icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
      tooltip: AppStrings.get(_muted ? 'videoUnmute' : 'videoMute'),
      onTap: () => _setMuted(!_muted),
    );
  }

  Widget _soundHint({required double topOffset}) {
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _showSoundHint && _muted
              ? Material(
                  key: const ValueKey('sound-hint'),
                  color: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 6,
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => _setMuted(false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.get('videoTapForSound'),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-hint')),
        ),
      ),
    );
  }
}

/// One video: blurred poster backdrop, the video itself letterboxed (never
/// cropped — several clips have text burned in near the edges), and the
/// title / CTA / progress overlay.
class _ReelPage extends StatelessWidget {
  final SaborlyVideo video;
  final VideoPlayerController? controller;
  final bool failed;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onRetry;
  final VoidCallback onOrderNow;

  const _ReelPage({
    super.key,
    required this.video,
    required this.controller,
    required this.failed,
    required this.isActive,
    required this.compact,
    required this.onTap,
    required this.onRetry,
    required this.onOrderNow,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A tiny decode, blurred and dimmed, fills any letterbox space.
          RepaintBoundary(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Image.asset(video.posterAsset, fit: BoxFit.cover, cacheWidth: 96),
            ),
          ),
          const ColoredBox(color: Color(0x8C000000)),

          Center(
            child: controller == null
                ? _PosterPlaceholder(video: video, failed: failed, onRetry: onRetry)
                : ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: controller,
                    builder: (context, value, _) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: value.isInitialized
                          ? AspectRatio(
                              key: const ValueKey('video'),
                              aspectRatio: value.aspectRatio,
                              child: VideoPlayer(controller),
                            )
                          : _PosterPlaceholder(
                              key: const ValueKey('poster'),
                              video: video,
                              failed: false,
                              onRetry: onRetry,
                            ),
                    ),
                  ),
          ),

          // Neighbouring pages sit paused off-screen; showing the glyph there
          // would flash it on every swipe.
          if (controller != null && isActive) _PausedIndicator(controller: controller),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ReelInfo(
              video: video,
              controller: controller,
              compact: compact,
              onOrderNow: onOrderNow,
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  final SaborlyVideo video;
  final bool failed;
  final VoidCallback onRetry;

  const _PosterPlaceholder({
    super.key,
    required this.video,
    required this.failed,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Same box the letterboxed video will occupy, so nothing jumps
        // when the first frame replaces the poster.
        SizedBox.expand(child: Image.asset(video.posterAsset, fit: BoxFit.contain)),
        if (failed)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 30),
                const SizedBox(height: 10),
                Text(
                  AppStrings.get('videoLoadError'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                  child: Text(
                    AppStrings.get('retry'),
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.secondary),
          ),
      ],
    );
  }
}

/// Large play (or replay, at the end) glyph while the video is paused.
class _PausedIndicator extends StatelessWidget {
  final VideoPlayerController controller;

  const _PausedIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final ended = value.isInitialized && value.duration > Duration.zero && value.position >= value.duration;
          final visible = value.isInitialized && !value.isPlaying && !value.isBuffering;
          return Center(
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: AnimatedScale(
                scale: visible ? 1 : 0.8,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.45),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Icon(
                    ended ? Icons.replay_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReelInfo extends StatelessWidget {
  final SaborlyVideo video;
  final VideoPlayerController? controller;
  final bool compact;
  final VoidCallback onOrderNow;

  const _ReelInfo({
    required this.video,
    required this.controller,
    required this.compact,
    required this.onOrderNow,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final bottomInset = compact ? MediaQuery.paddingOf(context).bottom : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(18, 48, 18, 14 + bottomInset),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xB3000000), Color(0xE6120906)],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SaborlyBadge(size: 32, showName: true, nameSize: 15),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    video.tag.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.breeSerif(
              fontSize: compact ? 22 : 24,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          _OrderNowButton(onTap: onOrderNow),
          const SizedBox(height: 16),
          if (controller != null)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final position = value.position > value.duration ? value.duration : value.position;
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          colors: VideoProgressColors(
                            playedColor: AppColors.primary,
                            bufferedColor: Colors.white.withValues(alpha: 0.3),
                            backgroundColor: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${formatVideoDuration(position)} / ${formatVideoDuration(value.isInitialized ? value.duration : video.duration)}',
                      // Numeric "a / b": keep LTR so Arabic doesn't flip it.
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Desktop side panel listing the next few videos (wrapping around), each a
/// shortcut straight to that video.
class _UpNextPanel extends StatelessWidget {
  final List<SaborlyVideo> videos;
  final int currentIndex;
  final double width;
  final ValueChanged<int> onSelect;

  const _UpNextPanel({
    required this.videos,
    required this.currentIndex,
    required this.width,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = [
      for (var step = 1; step <= 3 && step < videos.length; step++) (currentIndex + step) % videos.length,
    ];

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              AppStrings.get('videoUpNext').toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final i in upcoming) _UpNextTile(video: videos[i], onTap: () => onSelect(i)),
        ],
      ),
    );
  }
}

class _UpNextTile extends StatelessWidget {
  final SaborlyVideo video;
  final VoidCallback onTap;

  const _UpNextTile({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: Colors.white.withValues(alpha: 0.07),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.asset(
                      video.posterAsset,
                      width: 58,
                      height: 103,
                      fit: BoxFit.cover,
                      cacheWidth: (58 * dpr).round(),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatVideoDuration(video.duration),
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.tag.label.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryLight,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderNowButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OrderNowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant_menu_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  AppStrings.get('videoOrderNow'),
                  style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  final int index;
  final int total;

  const _CounterPill({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        '${index + 1} / $total',
        // Numeric "a / b": keep LTR so Arabic doesn't show "12 / 6".
        textDirection: TextDirection.ltr,
        style: GoogleFonts.manrope(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Translucent round control that stays legible over any video frame.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.35,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: Colors.black.withValues(alpha: 0.4),
          shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.18))),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            hoverColor: Colors.white.withValues(alpha: 0.12),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: Colors.white, size: size * 0.52),
            ),
          ),
        ),
      ),
    );
  }
}
