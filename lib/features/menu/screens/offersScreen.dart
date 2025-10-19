import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/features/providers/offer_provider.dart';
import 'package:soely/shared/models/food_item.dart';
import 'package:soely/shared/models/offer.dart';
import 'package:soely/shared/widgets/food_item_card4.dart';
import 'package:soely/shared/widgets/ooter.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  DateTime? _lastPressedAt;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoadingForLanguageChange = false; // ✅ Track language change loading

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOffersWithCurrentLanguage();
    });

    _setupLanguageListener();
  }

  /// ✅ Load offers with current language
  void _loadOffersWithCurrentLanguage() {
    if (mounted) {
      final languageService = context.read<LanguageService>();
      final offersProvider = context.read<OffersProvider>();
      final currentLanguage = languageService.currentLanguage;
      
      
      offersProvider.setLanguage(currentLanguage).then((_) {
        offersProvider.loadOffers();
      });
    }
  }

  void _setupLanguageListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LanguageService>().addListener(_onLanguageChanged);
      }
    });
  }

  /// ✅ Reload data when language changes - show loading
  void _onLanguageChanged() {
    if (mounted) {
      
      // Show loading indicator
      setState(() {
        _isLoadingForLanguageChange = true;
      });

      final languageService = context.read<LanguageService>();
      final offersProvider = context.read<OffersProvider>();
      final currentLanguage = languageService.currentLanguage;
      
      // Reload with new language
      offersProvider.setLanguage(currentLanguage).then((_) {
        return offersProvider.loadOffers();
      }).then((_) {
        // Hide loading when done
        if (mounted) {
          setState(() {
            _isLoadingForLanguageChange = false;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _isLoadingForLanguageChange = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    try {
      context.read<LanguageService>().removeListener(_onLanguageChanged);
    } catch (e) {
    }
    
    _animationController.dispose();
    super.dispose();
  }

  // Responsive breakpoints
  bool _isMobile(double width) => width < 600;
  bool _isTablet(double width) => width >= 600 && width < 1000;
  bool _isDesktop(double width) => width >= 1000;

  double _getMaxContentWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1280;
    if (screenWidth >= 1000) return screenWidth * 0.88;
    return screenWidth;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (_isMobile(screenWidth)) return 16.w;
    if (_isTablet(screenWidth)) return 32.w;
    return 48.w;
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 500) return 2;
    if (screenWidth < 800) return 3;
    if (screenWidth < 1200) return 4;
    return 5;
  }

  double _getChildAspectRatio(double screenWidth) {
    if (_isMobile(screenWidth)) return 0.72;
    if (_isTablet(screenWidth)) return 0.75;
    return 0.78;
  }

  FoodItem _convertToFoodItem(FoodItemWithOffer item) {
    return FoodItem(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      imageUrl: item.imageUrl,
      category: item.category.id,
      isVeg: false,
      offer: item.offer,
      isFeatured: false,
      isPopular: false,
      rating: 0.0,
      reviewCount: 0,
      tags: [],
      mealSizes: [],
      extras: [],
      addons: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;

            final now = DateTime.now();
            final maxDuration = const Duration(seconds: 2);
            final isWarning = _lastPressedAt == null ||
                now.difference(_lastPressedAt!) > maxDuration;

            if (isWarning) {
              _lastPressedAt = now;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.get('pressBackAgain'),
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.textDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  margin: EdgeInsets.all(16.r),
                ),
              );
              return;
            }
            SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            body: Stack(
              children: [
                Consumer<OffersProvider>(
                  builder: (context, provider, child) {
                    // ✅ Show loading if initial load or language change loading
                    if ((provider.isLoading && provider.itemsWithOffers.isEmpty) ||
                        _isLoadingForLanguageChange) {
                      return _buildLoadingState();
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;
                        final isWeb = ResponsiveUtils.isWeb(context);
                        final maxContentWidth = _getMaxContentWidth(screenWidth);
                        final horizontalPadding = _getHorizontalPadding(screenWidth);

                        return RefreshIndicator(
                          onRefresh: () async {
                            final currentLanguage = languageService.currentLanguage;
                            await provider.setLanguage(currentLanguage);
                            await provider.loadOffers();
                          },
                          color: AppColors.primary,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              if (!isWeb) _buildSliverAppBar(screenWidth),
                              SliverToBoxAdapter(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white,
                                        Colors.grey[50]!,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: _isMobile(screenWidth) ? 20.h : 40.h),
                                            _buildHeader(screenWidth, provider),
                                            SizedBox(height: _isMobile(screenWidth) ? 24.h : 40.h),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                      child: FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: _buildContent(provider, screenWidth),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (isWeb)
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FoodKingFooter(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                
                // ✅ Show overlay loading during language change
                if (_isLoadingForLanguageChange)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Changing language...',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.get('loadingOffers'),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(double screenWidth) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      surfaceTintColor: Colors.white,
      leading: Container(
        margin: EdgeInsets.all(8.r),
        child: Material(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 20.sp,
            ),
          ),
        ),
      ),
      title: Text(
        AppStrings.get('specialOffers'),
        style: GoogleFonts.poppins(
          fontSize: _isMobile(screenWidth) ? 18.sp : 22.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey[200]!,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, OffersProvider provider) {
    final isMobile = _isMobile(screenWidth);
    final isTablet = _isTablet(screenWidth);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20.r : 32.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            AppStrings.get('hotDeals'),
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  AppStrings.get('exclusiveOffers'),
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 24.sp : (isTablet ? 32.sp : 40.sp),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppStrings.get('saveUpTo'),
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 14.sp : (isTablet ? 16.sp : 18.sp),
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
                if (provider.itemsWithOffers.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${provider.itemsWithOffers.length} ${AppStrings.get('itemsOnOffer')}',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isMobile) ...[
            SizedBox(width: 24.w),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_offer_rounded,
                color: AppColors.primary,
                size: 48.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(OffersProvider provider, double screenWidth) {
    if (provider.itemsWithOffers.isEmpty) {
      return _buildEmptyState(screenWidth);
    }

    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final isMobile = _isMobile(screenWidth);
    final childAspectRatio = _getChildAspectRatio(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: isMobile ? 12.h : 20.h,
        bottom: isMobile ? 100.h : 120.h,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 12.w : (_isTablet(screenWidth) ? 16.w : 20.w),
        mainAxisSpacing: isMobile ? 12.h : (_isTablet(screenWidth) ? 16.h : 20.h),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: provider.itemsWithOffers.length,
      itemBuilder: (context, index) {
        final item = provider.itemsWithOffers[index];
        final foodItem = _convertToFoodItem(item);
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: FoodItemCard(
            foodItem: foodItem,
            onTap: () {
              context.push(AppRoutes.foodDetail, extra: foodItem);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    final isMobile = _isMobile(screenWidth);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 24.w : 48.w,
          vertical: 60.h,
        ),
        padding: EdgeInsets.all(isMobile ? 40.r : 60.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: isMobile ? 64.sp : 80.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: isMobile ? 24.h : 32.h),
            Text(
              AppStrings.get('noOffersAvailable'),
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 20.sp : 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.get('checkBackLaterOffers'),
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14.sp : 16.sp,
                color: AppColors.textLight,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                context.go(AppRoutes.home);
              },
              icon: Icon(Icons.home_rounded, size: 20.sp),
              label: Text(
                AppStrings.get('browseMenu'),
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 16.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}