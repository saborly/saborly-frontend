import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/men_provider.dart';

import 'package:soely/shared/widgets/ooter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/food_item_card.dart';
import '../../../shared/widgets/search_bar_widget.dart';

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
  await provider.loadCategories();

  if (mounted && provider.categories.isNotEmpty) {
    setState(() {
      _tabController = TabController(
        length: provider.categories.length + 1,
        vsync: this,
      );
      _tabController!.addListener(_onTabChanged);
    });

    if (_selectedCategoryId != null) {
      final index = provider.categories.indexWhere(
        (category) => category.id == _selectedCategoryId,
      );
      if (index != -1) {
        _tabController!.index = index + 1;
      }
    }
    await provider.loadFoodItems(categoryId: _selectedCategoryId);
  }
}void _onTabChanged() {
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

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1600) return 5;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 900) return 3;
    if (screenWidth >= 600) return 2;
    return 2;
  }

  double _getMaxContentWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1400;
    if (screenWidth >= 1200) return 1200;
    return screenWidth * 0.95;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWeb = screenWidth >= 1200;

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            
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
            appBar: !isWeb ? _buildModernAppBar(context) : null,
            body: Consumer<MenuProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.categories.isEmpty) {
                  return _buildLoadingState();
                }

                if (provider.error != null) {
                  return _buildErrorState(provider.error!);
                }

                if (provider.categories.isEmpty) {
  return _buildEmptyState(AppStrings.get('noCategoriesAvailable'));
                }

                return CustomScrollView(
                  slivers: [
                    if (isWeb) _buildWebHeaderSliver(screenWidth),
                    if (!isWeb) _buildSearchSectionSliver(provider),
                    _buildCategoryTabsSliver(provider, screenWidth, isWeb),
                    _buildFilterSectionSliver(provider, screenWidth),
                    _buildFoodGridSliver(provider, screenWidth),
                    if (isWeb) _buildFooterSliver(screenWidth >= 1200),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18.sp),
        ),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      title: Text(
        AppStrings.ourMenu,
        style: GoogleFonts.poppins(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showFilterBottomSheet,
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20.sp),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
  AppStrings.get('loadingMenu'),
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 64.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<MenuProvider>().loadFoodItems(categoryId: _selectedCategoryId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
  AppStrings.get('retry'),
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
  AppStrings.get('error'),
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<MenuProvider>().loadFoodItems(categoryId: _selectedCategoryId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeaderSliver(double screenWidth) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(48.w, 40.h, 48.w, 24.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _getMaxContentWidth(screenWidth)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.ourMenu,
                      style: GoogleFonts.poppins(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -1.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
  AppStrings.get('discoverOfferings'),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: Icon(Icons.tune_rounded, size: 20.sp),
label: Text(AppStrings.get('filters'), style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)),                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 18.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSectionSliver(MenuProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: SearchBarWidget(onSearch: provider.searchFoodItems),
      ),
    );
  }

  Widget _buildCategoryTabsSliver(MenuProvider provider, double screenWidth, bool isWeb) {
    if (_tabController == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _getMaxContentWidth(screenWidth)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isWeb ? 48.w : 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              height: 60.h,
              padding: EdgeInsets.all(6.w),
              child: TabBar(
                controller: _tabController!,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                tabAlignment: TabAlignment.start,
                physics: const BouncingScrollPhysics(),
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMedium,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                tabs: [
_buildEnhancedTab(AppStrings.get('allCategories'), Icons.apps_rounded),

                  ...provider.categories.map(
                    (category) => _buildEnhancedTab(
                      category.name.replaceAll('\n', ' '),
                      _getCategoryIcon(category.name),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTab(String text, IconData icon) {
    return Tab(
      height: 48.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('burger')) return Icons.lunch_dining_rounded;
    if (name.contains('pizza')) return Icons.local_pizza_rounded;
    if (name.contains('chicken')) return Icons.set_meal_rounded;
    if (name.contains('seafood')) return Icons.set_meal_rounded;
    if (name.contains('sandwich')) return Icons.lunch_dining_rounded;
    if (name.contains('salad')) return Icons.eco_rounded;
    if (name.contains('appetizer')) return Icons.restaurant_rounded;
    if (name.contains('dessert')) return Icons.cake_rounded;
    if (name.contains('drink') || name.contains('beverage')) return Icons.local_cafe_rounded;
    return Icons.restaurant_menu_rounded;
  }

  Widget _buildFilterSectionSliver(MenuProvider provider, double screenWidth) {
    final isWeb = screenWidth >= 1200;
    
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _getMaxContentWidth(screenWidth)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isWeb ? 48.w : 16.w, vertical: 12.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildModernFilterChip(
  AppStrings.get('vegetarian'),
                    Icons.eco_rounded,
                    provider.showVegOnly,
                    () => provider.setVegFilter(!provider.showVegOnly),
                    const Color(0xFF10B981),
                  ),
                  SizedBox(width: 12.w),
                  _buildModernFilterChip(
  AppStrings.get('nonVegetarian'),
                    Icons.restaurant_rounded,
                    provider.showNonVegOnly,
                    () => provider.setNonVegFilter(!provider.showNonVegOnly),
                    const Color(0xFFEF4444),
                  ),
                  SizedBox(width: 12.w),
                  _buildModernFilterChip(
  AppStrings.get('popularItems'),
                    Icons.local_fire_department_rounded,
                    provider.showPopularOnly,
                    () => provider.setPopularFilter(!provider.showPopularOnly),
                    const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Color accentColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Colors.white : accentColor,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildFoodGridSliver(MenuProvider provider, double screenWidth) {
  // Show loading indicator if provider is loading or if categories are loaded but food items are not yet available
  if (provider.isLoading || (provider.categories.isNotEmpty && provider.foodItems.isEmpty)) {
    return SliverFillRemaining(
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  if (provider.foodItems.isEmpty) {
    return SliverFillRemaining(
      child: _buildEmptyState(AppStrings.get('noFoodItemsAvailable')),
    );
  }

  final crossAxisCount = _getCrossAxisCount(screenWidth);
  final aspectRatio = screenWidth >= 1200 ? 0.75 : (screenWidth >= 600 ? 0.7 : 0.68);
  final isWeb = screenWidth >= 1200;

  return SliverPadding(
    padding: EdgeInsets.fromLTRB(
      isWeb ? 48.w : 16.w,
      20.h,
      isWeb ? 48.w : 16.w,
      32.h,
    ),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.h,
        childAspectRatio: aspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = provider.foodItems[index];
          return FoodItemCard(
            foodItem: item,
            onTap: () => context.push(AppRoutes.foodDetail, extra: item),
          );
        },
        childCount: provider.foodItems.length,
      ),
    ),
  );
}
  Widget _buildFooterSliver(bool isDesktop) {
    return SliverToBoxAdapter(
      child: FoodKingFooter(),
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
                _buildFilterOptions(provider),
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
                  _buildFilterOptions(provider),
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

  Widget _buildFilterOptions(MenuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
  AppStrings.get('foodType'),
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 16.h),
        _buildCheckboxTile(
  AppStrings.get('vegetarian'),
          Icons.eco_rounded,
          provider.showVegOnly,
          (value) => provider.setVegFilter(value ?? false),
          const Color(0xFF10B981),
        ),
        SizedBox(height: 8.h),
        _buildCheckboxTile(
  AppStrings.get('nonVegetarian'),
          Icons.restaurant_rounded,
          provider.showNonVegOnly,
          (value) => provider.setNonVegFilter(value ?? false),
          const Color(0xFFEF4444),
        ),
        SizedBox(height: 8.h),
        _buildCheckboxTile(
  AppStrings.get('popularItems'),
          Icons.local_fire_department_rounded,
          provider.showPopularOnly,
          (value) => provider.setPopularFilter(value ?? false),
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool?> onChanged,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: value ? accentColor.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: value ? accentColor : Colors.grey.shade200,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(icon, size: 20.sp, color: value ? accentColor : Colors.grey.shade600),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                color: value ? accentColor : AppColors.textDark,
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        checkColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}