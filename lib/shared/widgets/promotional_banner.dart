import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Saborly/core/services/banner_service.dart';

class DynamicPromotionalBanner extends StatefulWidget {
  final String? category;
  final double? height;
  final Duration autoPlayDuration;
  final bool autoPlay;
  final VoidCallback? onSlideChanged;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Function(String? link)? onBannerTap;

  const DynamicPromotionalBanner({
    super.key,
    this.category,
    this.height,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.autoPlay = true,
    this.onSlideChanged,
    this.borderRadius,
    this.boxShadow,
    this.onBannerTap,
  });

  @override
  State<DynamicPromotionalBanner> createState() => _DynamicPromotionalBannerState();
}

class _DynamicPromotionalBannerState extends State<DynamicPromotionalBanner> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _autoPlayTimer;

  // Your deployed API endpoint (migrated from Vercel to api.saborly.es)
  static const String _proxyBaseUrl = 'https://api.saborly.es/api/proxy';
  
  final Map<int, bool> _imageLoadErrors = {};
  final Map<int, int> _imageRetryCount = {};
  static const int _maxRetries = 2;

  // Transparent 1x1 pixel PNG as Uint8List
  static final Uint8List _kTransparentImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBanners();
  }

  @override
  void didUpdateWidget(DynamicPromotionalBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _loadBanners();
    }
  }

  Future<void> _loadBanners() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageLoadErrors.clear();
      _imageRetryCount.clear();
    });

    _stopAutoPlay();

    try {
      final banners = await BannerService.getActiveBanners(category: widget.category);

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

      if (widget.autoPlay && mounted && _banners.length > 1) {
        _startAutoPlay();
      }
    } catch (e) {
      debugPrint('Banner load error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load banners';
        _isLoading = false;
      });
    }
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (!mounted || !widget.autoPlay || _banners.isEmpty) return;
      _nextSlide();
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _nextSlide() {
    if (!mounted || _banners.isEmpty) return;

    final nextIndex = (_currentIndex + 1) % _banners.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousSlide() {
    if (!mounted || _banners.isEmpty) return;

    final prevIndex = (_currentIndex - 1 + _banners.length) % _banners.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Use the proxy for ALL platforms (both mobile and web)
  String _getProxiedUrl(String originalUrl) {
    // For Vercel Blob URLs, always use the proxy
    if (originalUrl.contains('vercel-storage.com') || originalUrl.contains('blob.vercel-storage.com')) {
      return '$_proxyBaseUrl/image?url=${Uri.encodeComponent(originalUrl)}';
    }
    
    // For other URLs, you can still use them directly
    return originalUrl;
  }

  void _handleImageError(int index, dynamic error) {
    debugPrint('Image load failed for index $index: $error');
    
    if (!mounted) return;

    final retryCount = _imageRetryCount[index] ?? 0;
    
    if (retryCount < _maxRetries) {
      // Simple retry without changing proxy since we're using our own
      setState(() {
        _imageRetryCount[index] = retryCount + 1;
        debugPrint('Retrying image $index (attempt ${retryCount + 1})');
      });
    } else {
      // Mark as failed after max retries
      setState(() {
        _imageLoadErrors[index] = true;
      });
    }
  }

  void _resetForIndex(int index) {
    setState(() {
      _imageLoadErrors.remove(index);
      _imageRetryCount.remove(index);
    });
  }

  void _resetAll() {
    setState(() {
      _imageLoadErrors.clear();
      _imageRetryCount.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingWidget();
    if (_errorMessage != null) return _buildErrorWidget();
    if (_banners.isEmpty) return _buildEmptyWidget();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final isLargeDesktop = screenWidth >= 1440;
        final isDesktop = screenWidth >= 1024;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isMobile = screenWidth < 600;

        final bannerHeight = widget.height ?? _calculateHeight(screenWidth);

        return Container(
          height: bannerHeight,
          margin: EdgeInsets.symmetric(
            horizontal: isLargeDesktop
                ? 40
                : isDesktop
                    ? 30
                    : isTablet
                        ? 20
                        : 4,
            vertical: isDesktop ? 16 : 12,
          ),
          child: Stack(
            children: [
              // Main slider container
              Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(isLargeDesktop ? 32 : isDesktop ? 28 : 24),
                  boxShadow: widget.boxShadow ??
                      [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(isLargeDesktop ? 32 : isDesktop ? 28 : 24),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() => _currentIndex = index);
                      widget.onSlideChanged?.call();
                    },
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      return _buildImageSlide(_banners[index], index);
                    },
                  ),
                ),
              ),

              // Navigation arrows
              if (!isMobile && _banners.length > 1) ...[
                _buildNavigationArrow(true, _previousSlide, isDesktop, isLargeDesktop),
                _buildNavigationArrow(false, _nextSlide, isDesktop, isLargeDesktop),
              ],

              // Dots / indicators
              if (_banners.length > 1)
                _buildPageIndicators(bannerHeight, isDesktop, isTablet, isLargeDesktop),

              // Reset button (show on all platforms when there are errors)
              if (_imageLoadErrors.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      onPressed: _resetAll,
                      tooltip: 'Retry loading images',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'Error loading banners'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBanners,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: Text('No banners available')),
    );
  }

  Widget _buildImageSlide(BannerModel banner, int index) {
    if (_imageLoadErrors.containsKey(index)) {
      return _buildErrorImageSlide(index);
    }

    return GestureDetector(
      onTap: () {
        if (widget.onBannerTap != null) {
          widget.onBannerTap!(banner.link);
        } else if (banner.link != null) {
          debugPrint('Banner tapped: ${banner.link}');
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Use FadeInImage for better loading experience - NO TEXT OVERLAY
          FadeInImage(
            placeholder: MemoryImage(_kTransparentImage),
            image: NetworkImage(_getProxiedUrl(banner.imageUrl)),
            fit: BoxFit.cover,
            imageErrorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleImageError(index, error);
              });
              return _buildErrorImageSlide(index);
            },
            placeholderErrorBuilder: (context, error, stackTrace) => 
                const SizedBox.shrink(),
          ),

          // Loading indicator (shown while image loads)
          Positioned.fill(
            child: _ImageLoadingBuilder(
              imageUrl: _getProxiedUrl(banner.imageUrl),
            ),
          ),

          // NO BANNER CONTENT OVERLAY - REMOVED
          // The text overlay has been completely removed
        ],
      ),
    );
  }

  Widget _buildErrorImageSlide(int index) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'Image unavailable',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _resetForIndex(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrow(
    bool isLeft,
    VoidCallback onTap,
    bool isDesktop,
    bool isLargeDesktop,
  ) {
    return Positioned(
      left: isLeft ? (isLargeDesktop ? 30 : 20) : null,
      right: isLeft ? null : (isLargeDesktop ? 30 : 20),
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: EdgeInsets.all(isLargeDesktop ? 20 : isDesktop ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isLeft ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.grey[800],
                size: isLargeDesktop ? 32 : isDesktop ? 28 : 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(
    double bannerHeight,
    bool isDesktop,
    bool isTablet,
    bool isLargeDesktop,
  ) {
    return Positioned(
      bottom: isLargeDesktop ? 30 : isDesktop ? 25 : 15,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_banners.length, (index) {
          final isActive = _currentIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: isLargeDesktop ? 6 : 4),
            width: isActive ? (isLargeDesktop ? 32 : 24) : (isLargeDesktop ? 12 : 8),
            height: isLargeDesktop ? 12 : 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isLargeDesktop ? 6 : 4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  double _calculateHeight(double screenWidth) {
    if (screenWidth >= 1440) return 433;
    if (screenWidth >= 1024) return 400;
    if (screenWidth >= 768) return 350;
    if (screenWidth >= 600) return 200;
    if (screenWidth >= 480) return 180;
    if (screenWidth >= 400) return 160;
    return 140;
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }
}

// Custom loading builder to show/hide loading indicator
class _ImageLoadingBuilder extends StatefulWidget {
  final String imageUrl;

  const _ImageLoadingBuilder({required this.imageUrl});

  @override
  State<_ImageLoadingBuilder> createState() => _ImageLoadingBuilderState();
}

class _ImageLoadingBuilderState extends State<_ImageLoadingBuilder> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    // Simulate loading - in reality, the FadeInImage handles this
    // This is just a fallback
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : const SizedBox.shrink();
  }
}