import 'package:flutter/material.dart';
import 'package:soely/core/services/banner_service.dart';

class DynamicPromotionalBanner extends StatefulWidget {
  final String? category;
  final double? height;
  final Duration autoPlayDuration;
  final bool autoPlay;
  final VoidCallback? onSlideChanged;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const DynamicPromotionalBanner({
    Key? key,
    this.category,
    this.height,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.autoPlay = true,
    this.onSlideChanged,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<DynamicPromotionalBanner> createState() => _DynamicPromotionalBannerState();
}

class _DynamicPromotionalBannerState extends State<DynamicPromotionalBanner> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

      if (widget.autoPlay && mounted) {
        _startAutoPlay();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load banners';
        _isLoading = false;
      });
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayDuration, () {
      if (mounted && widget.autoPlay && _banners.isNotEmpty) {
        _nextSlide();
        _startAutoPlay();
      }
    });
  }

  void _nextSlide() {
    if (!mounted) return;
    
    if (_currentIndex < _banners.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    
    _pageController.jumpToPage(_currentIndex);
    
    if (mounted) {
      setState(() {});
    }
  }

  void _previousSlide() {
    if (!mounted) return;
    
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _banners.length - 1;
    }
    
    _pageController.jumpToPage(_currentIndex);
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_banners.isEmpty) {
      return _buildEmptyWidget();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isLargeDesktop = screenWidth >= 1440;
        final isDesktop = screenWidth >= 1024;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isMobile = screenWidth < 600;
        
        double bannerHeight = widget.height ?? _calculateHeight(screenWidth);
        
        return Container(
          height: bannerHeight,
          margin: EdgeInsets.symmetric(
            horizontal: isLargeDesktop ? 40 : (isDesktop ? 30 : (isTablet ? 20 : 16)),
            vertical: isDesktop ? 16 : 12,
          ),
          child: Stack(
            children: [
              // Main image slider
              Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(isLargeDesktop ? 32 : (isDesktop ? 28 : 24)),
                  boxShadow: widget.boxShadow ?? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(isLargeDesktop ? 32 : (isDesktop ? 28 : 24)),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (mounted) {
                        setState(() {
                          _currentIndex = index;
                        });
                        widget.onSlideChanged?.call();
                      }
                    },
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      return _buildImageSlide(
                        _banners[index],
                        bannerHeight,
                      );
                    },
                  ),
                ),
              ),
              
              // Navigation arrows (hidden on mobile)
              if (!isMobile) ...[
                _buildNavigationArrow(
                  isLeft: true,
                  onTap: _previousSlide,
                  isDesktop: isDesktop,
                  isLargeDesktop: isLargeDesktop,
                ),
                _buildNavigationArrow(
                  isLeft: false,
                  onTap: _nextSlide,
                  isDesktop: isDesktop,
                  isLargeDesktop: isLargeDesktop,
                ),
              ],
              
              // Page indicators
              _buildPageIndicators(bannerHeight, isDesktop, isTablet, isLargeDesktop),
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
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
            const SizedBox(height: 8),
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
      child: const Center(
        child: Text('No banners available'),
      ),
    );
  }

  Widget _buildImageSlide(BannerModel banner, double bannerHeight) {
    final imageUrlWithProxy = "https://corsproxy.io/?" + Uri.encodeComponent(banner.imageUrl);

    return GestureDetector(
      onTap: banner.link != null ? () {
      } : null,
      child: Container(
        width: double.infinity,
        height: bannerHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrlWithProxy,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 64, color: Colors.white),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required bool isLeft,
    required VoidCallback onTap,
    required bool isDesktop,
    required bool isLargeDesktop,
  }) {
    return Positioned(
      left: isLeft ? (isLargeDesktop ? 30 : 20) : null,
      right: isLeft ? null : (isLargeDesktop ? 30 : 20),
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isLargeDesktop ? 20 : (isDesktop ? 16 : 12)),
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
              color: Colors.grey[700],
              size: isLargeDesktop ? 32 : (isDesktop ? 28 : 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(double bannerHeight, bool isDesktop, bool isTablet, bool isLargeDesktop) {
    return Positioned(
      bottom: isLargeDesktop ? 30 : (isDesktop ? 25 : 15),
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _banners.length,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: isLargeDesktop ? 6 : 4),
            width: _currentIndex == index ? (isLargeDesktop ? 32 : 24) : (isLargeDesktop ? 12 : 8),
            height: isLargeDesktop ? 12 : 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isLargeDesktop ? 6 : 4),
              boxShadow: _currentIndex == index
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );}

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
    _pageController.dispose();
    super.dispose();}}