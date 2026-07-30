import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/men_provider.dart';

import 'menu/widgets/menu_app_bar.dart';
import 'menu/widgets/menu_category_tabs_sliver.dart';
import 'menu/widgets/menu_empty_state.dart';
import 'menu/widgets/menu_error_state.dart';
import 'menu/widgets/menu_filter_options.dart';
import 'menu/widgets/menu_filter_section_sliver.dart';
import 'menu/widgets/menu_food_grid_sliver.dart';
import 'menu/widgets/menu_footer_sliver.dart';
import 'menu/widgets/menu_loading_state.dart';
import 'menu/widgets/menu_search_section_sliver.dart';
import 'menu/widgets/menu_web_header_sliver.dart';

class MenuScreen extends StatefulWidget {
  final String? categoryId;

  const MenuScreen({super.key, this.categoryId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  String? _selectedCategoryId;
  DateTime? _lastPressedAt;
  late AnimationController _filterAnimationController;
  bool _isInitialized = false; // ADD THIS FLAG

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeScreen());
  }

  Future<void> _initializeScreen() async {
    final provider = context.read<MenuProvider>();

    try {
      // ✅ Load BOTH categories and food items in parallel
      // Use force:true to bypass _isLoading guard — this screen MUST load data
      await Future.wait([
        if (provider.categories.isEmpty) provider.loadCategories(),
        provider.loadFoodItems(categoryId: _selectedCategoryId),
      ]);

      // Setup TabController after data is loaded
      if (mounted && provider.categories.isNotEmpty) {
        setState(() {
          _tabController = TabController(
            length: provider.categories.length + 1,
            vsync: this,
          );
          _tabController!.addListener(_onTabChanged);
        });

        // Set initial tab if category is specified
        if (_selectedCategoryId != null) {
          final index = provider.categories.indexWhere(
            (category) => category.id == _selectedCategoryId,
          );
          if (index != -1) {
            _tabController!.index = index + 1;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MenuScreen] _initializeScreen error: $e');
      }
    } finally {
      // Mark as initialized
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _onTabChanged() {
    if (_tabController == null) return;

    final provider = context.read<MenuProvider>();
    if (_tabController!.index == 0) {
      _selectedCategoryId = null;
      provider.loadFoodItems();
    } else {
      final categoryIndex = _tabController!.index - 1;
      if (categoryIndex < provider.categories.length) {
        _selectedCategoryId = provider.categories[categoryIndex].id;
        provider.loadFoodItems(categoryId: _selectedCategoryId);
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWeb = screenWidth >= 1200;

        return PopScope(
          canPop: kIsWeb, // ✅ On web, allow browser back; on mobile, double-tap to exit
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || kIsWeb) return;

            final now = DateTime.now();
            final isWarning = _lastPressedAt == null ||
                now.difference(_lastPressedAt!) > const Duration(seconds: 2);

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
            backgroundColor: AppColors.background,
            appBar: !isWeb ? MenuAppBar(onFilterTap: _showFilterBottomSheet) : null,
            body: Consumer<MenuProvider>(
              builder: (context, provider, child) {
                if (!_isInitialized && provider.isLoading) {
                  return const MenuLoadingState();
                }

                if (_isInitialized && provider.error != null) {
                  return MenuErrorState(
                    error: provider.error!,
                    onRetry: () => context.read<MenuProvider>().loadFoodItems(categoryId: _selectedCategoryId),
                  );
                }
                if (_isInitialized && provider.categories.isEmpty) {
                  return MenuEmptyState(
                    message: AppStrings.get('noCategoriesAvailable'),
                    onRetry: () => context.read<MenuProvider>().loadFoodItems(categoryId: _selectedCategoryId),
                  );
                }
                if (!_isInitialized) {
                  return const MenuLoadingState();
                }

                return CustomScrollView(
                  slivers: [
                    if (isWeb)
                      MenuWebHeaderSliver(
                        screenWidth: screenWidth,
                        onFilterTap: _showFilterDialog,
                      ),
                    if (!isWeb) MenuSearchSectionSliver(provider: provider),
                    MenuCategoryTabsSliver(
                      tabController: _tabController,
                      provider: provider,
                      screenWidth: screenWidth,
                      isWeb: isWeb,
                    ),
                    MenuFilterSectionSliver(provider: provider, screenWidth: screenWidth),
                    MenuFoodGridSliver(
                      provider: provider,
                      screenWidth: screenWidth,
                      onEmptyStateRetry: () => context.read<MenuProvider>().loadFoodItems(categoryId: _selectedCategoryId),
                    ),
                    if (isWeb) MenuFooterSliver(isDesktop: screenWidth >= 1200),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<MenuProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
  AppStrings.get('filters'),
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, size: 24.sp),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                MenuFilterOptions(provider: provider),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<MenuProvider>(
        builder: (context, provider, child) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            child: Container(
              width: 500.w,
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
  AppStrings.get('filters'),
                    style: GoogleFonts.poppins(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  MenuFilterOptions(provider: provider),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.clearFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            side: BorderSide(color: AppColors.primary, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text(
  AppStrings.get('clearAll'),
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            elevation: 0,
                          ),
                          child: Text(
  AppStrings.get('apply'),
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
