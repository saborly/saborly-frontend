import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/core/utils/responsive_utils.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/shared/widgets/ooter.dart';

import 'offers/widgets/language_change_overlay.dart';
import 'offers/widgets/offers_content.dart';
import 'offers/widgets/offers_header_badge.dart';
import 'offers/widgets/offers_loading_state.dart';
import 'offers/widgets/offers_responsive.dart';
import 'offers/widgets/offers_sliver_app_bar.dart';

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


      offersProvider.setLanguage(currentLanguage);
      offersProvider.loadOffers();
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
      offersProvider.setLanguage(currentLanguage);
      offersProvider.loadOffers().then((_) {
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
  bool _isMobile(double width) => OffersResponsive.isMobile(width);

  double _getMaxContentWidth(double screenWidth) => OffersResponsive.getMaxContentWidth(screenWidth);

  double _getHorizontalPadding(double screenWidth) => OffersResponsive.getHorizontalPadding(screenWidth);

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
                      return const OffersLoadingState();
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
                            provider.setLanguage(currentLanguage); // void — no await
                            await provider.loadOffers();
                          },
                          color: AppColors.primary,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              if (!isWeb) OffersSliverAppBar(screenWidth: screenWidth),
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
                                            OffersHeaderBadge(screenWidth: screenWidth),
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
                                        child: OffersContent(provider: provider, screenWidth: screenWidth),
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
                  const LanguageChangeOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }
}
