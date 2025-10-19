// lib/features/menu/food_detail_screen.dart - COMPLETE FIX

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/home_provider.dart';
import '../../../shared/models/food_item.dart';
import '../../../shared/widgets/custom_button.dart';

/// ✅ FIXED: Reloads item data when language changes
class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> 
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  MealSize? _selectedMealSize;
  List<Extra> _selectedExtras = [];
  List<Addon> _selectedAddons = [];
  final TextEditingController _instructionsController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  
  // ✅ CRITICAL: Store current food item that can be updated
  late FoodItem _currentFoodItem;
  String _lastLanguage = '';
  bool _isLoadingLanguageChange = false;

  @override
  void initState() {
    super.initState();
    _currentFoodItem = widget.foodItem;
    _lastLanguage = context.read<LanguageService>().currentLanguage;
    
    if (_currentFoodItem.mealSizes.isNotEmpty) {
      _selectedMealSize = _currentFoodItem.mealSizes.first;
    }
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();
  }

  /// ✅ CRITICAL: Detect language changes and reload item
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageService = context.watch<LanguageService>();
    final currentLang = languageService.currentLanguage;
    
    // Update AppStrings
    AppStrings.setLanguage(currentLang);
    
    // ✅ CRITICAL: Reload item if language changed
    if (_lastLanguage != currentLang && !_isLoadingLanguageChange) {
      _lastLanguage = currentLang;
      _reloadFoodItem(currentLang);
    }
  }

  /// ✅ CRITICAL: Fetch fresh item data in new language
  Future<void> _reloadFoodItem(String newLanguage) async {
    setState(() {
      _isLoadingLanguageChange = true;
    });

    try {
      final homeProvider = context.read<HomeProvider>();
      final response = await homeProvider.getFoodItem(_currentFoodItem.id);
      
      if (response.isSuccess && response.data != null) {
        if (mounted) {
          setState(() {
            _currentFoodItem = response.data!;
            _isLoadingLanguageChange = false;
            
            // ✅ Reset selections to match new language data
            if (_currentFoodItem.mealSizes.isNotEmpty) {
              // Try to keep same selection by matching ID
              final previousSizeId = _selectedMealSize?.id;
              _selectedMealSize = _currentFoodItem.mealSizes.firstWhere(
                (size) => size.id == previousSizeId,
                orElse: () => _currentFoodItem.mealSizes.first,
              );
            }
            
            // Update extras
            final previousExtraIds = _selectedExtras.map((e) => e.id).toList();
            _selectedExtras = _currentFoodItem.extras
                .where((extra) => previousExtraIds.contains(extra.id))
                .toList();
            
            // Update addons
            final previousAddonIds = _selectedAddons.map((a) => a.id).toList();
            _selectedAddons = _currentFoodItem.addons
                .where((addon) => previousAddonIds.contains(addon.id))
                .toList();
          });
          
        
        }
      }
    } catch (e) {
    
      if (mounted) {
        setState(() {
          _isLoadingLanguageChange = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  bool get _isLargeScreen => MediaQuery.of(context).size.width > 768;
  bool get _isDesktop => MediaQuery.of(context).size.width > 1200;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Stack(
            children: [
              _isLargeScreen ? _buildDesktopLayout() : _buildMobileLayout(),
              
              // ✅ Show loading overlay during language change
              if (_isLoadingLanguageChange)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              AppStrings.get('loading'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
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
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                _buildImageSection(),
                _buildDesktopBackButton(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isDesktop ? 48.w : 32.w,
                    vertical: _isDesktop ? 48.h : 32.h,
                  ),
                  child: _fadeAnimation != null
                      ? FadeTransition(
                          opacity: _fadeAnimation!,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 680.w),
                            child: _buildContent(),
                          ),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 680.w),
                          child: _buildContent(),
                        ),
                ),
              ),
              _buildDesktopBottomBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: _fadeAnimation != null
              ? FadeTransition(
                  opacity: _fadeAnimation!,
                  child: _buildContent(),
                )
              : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFoodDetails(),
        SizedBox(height: _isLargeScreen ? 40.h : 0),
        _buildQuantitySelector(),
        if (_currentFoodItem.mealSizes.isNotEmpty) ...[
          SizedBox(height: _isLargeScreen ? 36.h : 0),
          _buildMealSizeOptions(),
        ],
        if (_currentFoodItem.extras.isNotEmpty) ...[
          SizedBox(height: _isLargeScreen ? 36.h : 0),
          _buildExtrasSection(),
        ],
        if (_currentFoodItem.addons.isNotEmpty) ...[
          SizedBox(height: _isLargeScreen ? 36.h : 0),
          _buildAddonsSection(),
        ],
        SizedBox(height: _isLargeScreen ? 36.h : 0),
        _buildSpecialInstructions(),
        SizedBox(height: _isLargeScreen ? 120.h : 16.h),
        if (!_isLargeScreen) _buildBottomBar(),
        if (!_isLargeScreen) SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildDesktopBackButton() {
    return Positioned(
      top: 32.h,
      left: 32.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textDark,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Hero(
        tag: 'food_${_currentFoodItem.id}',
        child: kIsWeb
            ? Image.network(
                _currentFoodItem.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 80.sp,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: _currentFoodItem.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 80.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320.h,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textDark,
            size: 22.sp,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageSection(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodDetails() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isLargeScreen ? 0 : 20.w,
        vertical: _isLargeScreen ? 0 : 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _currentFoodItem.isVeg
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _currentFoodItem.isVeg 
                      ? Icons.eco_rounded 
                      : Icons.restaurant_rounded,
                  color: _currentFoodItem.isVeg 
                      ? Colors.green[700] 
                      : Colors.red[700],
                  size: _isLargeScreen ? 18.sp : 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ FIXED: Now uses _currentFoodItem which updates on language change
                    Text(
                      _currentFoodItem.name,
                      style: TextStyle(
                        fontSize: _isLargeScreen ? 36.sp : 28.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (_currentFoodItem.rating > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber[700],
                              size: _isLargeScreen ? 18.sp : 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${_currentFoodItem.rating}',
                              style: TextStyle(
                                fontSize: _isLargeScreen ? 15.sp : 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${_currentFoodItem.reviewCount})',
                              style: TextStyle(
                                fontSize: _isLargeScreen ? 14.sp : 12.sp,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _isLargeScreen ? 20.h : 16.h),
          // ✅ FIXED: Description also updates
          Text(
            _currentFoodItem.description,
            style: TextStyle(
              fontSize: _isLargeScreen ? 17.sp : 15.sp,
              color: AppColors.textMedium,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: _isLargeScreen ? 24.h : 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.get('total'),
                  style: TextStyle(
                    fontSize: _isLargeScreen ? 15.sp : 13.sp,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_currentFoodItem.hasActiveOffer) ...[
                      Text(
                        '${AppStrings.get('currency')}${_currentFoodItem.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: _isLargeScreen ? 18.sp : 16.sp,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    Text(
                      '${AppStrings.get('currency')}${_currentFoodItem.effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: _isLargeScreen ? 28.sp : 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: EdgeInsets.all(_isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('quantity'),
            style: TextStyle(
              fontSize: _isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                  enabled: _quantity > 1,
                ),
                Container(
                  width: _isLargeScreen ? 90.w : 70.w,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: _isLargeScreen ? 22.sp : 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _quantity++),
                  enabled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: _isLargeScreen ? 52.w : 44.w,
          height: _isLargeScreen ? 52.h : 44.h,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.grey[400],
            size: _isLargeScreen ? 24.sp : 22.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildMealSizeOptions() {
    return Container(
      padding: EdgeInsets.all(_isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('mealSize'),
            style: TextStyle(
              fontSize: _isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          if (_isLargeScreen && widget.foodItem.mealSizes.length <= 3)
            Row(
              children: widget.foodItem.mealSizes
                  .map((size) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: _buildMealSizeOption(size),
                        ),
                      ))
                  .toList(),
            )
          else
            ...widget.foodItem.mealSizes.map((size) => _buildMealSizeOption(size)),
        ],
      ),
    );
  }

  Widget _buildMealSizeOption(MealSize size) {
    final isSelected = _selectedMealSize?.id == size.id;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => setState(() => _selectedMealSize = size),
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1) 
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Radio<MealSize>(
                value: size,
                groupValue: _selectedMealSize,
                onChanged: (value) => setState(() => _selectedMealSize = value),
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  size.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
              if (size.additionalPrice != 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${size.additionalPrice > 0 ? '+' : ''}${AppStrings.get('currency')}${size.additionalPrice.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtrasSection() {
    return Container(
      padding: EdgeInsets.all(_isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('extras'),
            style: TextStyle(
              fontSize: _isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          if (_isLargeScreen && widget.foodItem.extras.length <= 2)
            Row(
              children: widget.foodItem.extras
                  .map((extra) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: _buildExtraOption(extra),
                        ),
                      ))
                  .toList(),
            )
          else
            ...widget.foodItem.extras.map((extra) => _buildExtraOption(extra)),
        ],
      ),
    );
  }

  Widget _buildExtraOption(Extra extra) {
    final isSelected = _selectedExtras.any((e) => e.id == extra.id);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedExtras.removeWhere((e) => e.id == extra.id);
            } else {
              _selectedExtras.add(extra);
            }
          });
        },
        borderRadius: BorderRadius.circular(_isLargeScreen ? 16.r : 14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(_isLargeScreen ? 20.w : 18.w),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.08) 
                : Colors.white,
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary 
                  : AppColors.border.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(_isLargeScreen ? 16.r : 14.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
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
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  extra.name,
                  style: TextStyle(
                    fontSize: _isLargeScreen ? 17.sp : 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary 
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${AppStrings.get('currency')}${extra.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: _isLargeScreen ? 15.sp : 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddonsSection() {
    return Container(
      padding: EdgeInsets.only(
        left: _isLargeScreen ? 0 : 20.w,
        right: 0,
        top: 0,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: _isLargeScreen ? 0 : 20.w),
            child: Text(
              AppStrings.get('addons'),
              style: TextStyle(
                fontSize: _isLargeScreen ? 22.sp : 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: _isLargeScreen ? 300.h : 190.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(right: _isLargeScreen ? 0 : 20.w),
              itemCount: widget.foodItem.addons.length,
              itemBuilder: (context, index) {
                final addon = widget.foodItem.addons[index];
                return _buildAddonCard(addon);
              },
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildAddonCard(Addon addon) {
    final isSelected = _selectedAddons.any((a) => a.id == addon.id);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedAddons.removeWhere((a) => a.id == addon.id);
            } else {
              _selectedAddons.add(addon);
            }
          });
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isLargeScreen ? 220.w : 160.w,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (addon.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                  child: kIsWeb
                      ? Image.network(
                          addon.imageUrl,
                          height: _isLargeScreen ? 140.h : 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: _isLargeScreen ? 140.h : 100.h,
                            color: const Color(0xFFF0F0F0),
                            child: Icon(Icons.fastfood_rounded, size: 40.sp, color: Colors.grey[400]),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: addon.imageUrl,
                          height: _isLargeScreen ? 140.h : 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: _isLargeScreen ? 140.h : 100.h,
                            color: const Color(0xFFF0F0F0),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: _isLargeScreen ? 140.h : 100.h,
                            color: const Color(0xFFF0F0F0),
                            child: Icon(Icons.fastfood_rounded, size: 40.sp, color: Colors.grey[400]),
                          ),
                        ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              addon.name,
                              style: TextStyle(
                                fontSize: _isLargeScreen ? 16.sp : 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${AppStrings.currency}${addon.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: _isLargeScreen ? 15.sp : 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Container(
      padding: EdgeInsets.all(_isLargeScreen ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.specialInstructions,
            style: TextStyle(
              fontSize: _isLargeScreen ? 22.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _instructionsController,
              maxLines: 4,
              style: TextStyle(
                fontSize: _isLargeScreen ? 16.sp : 14.sp,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText:    AppStrings.get('specialInstructions'),
                hintStyle: TextStyle(
                  fontSize: _isLargeScreen ? 16.sp : 14.sp,
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
double _calculateTotalPrice() {
    double total = widget.foodItem.effectivePrice; // Use effectivePrice instead of price
    
    if (_selectedMealSize != null && _selectedMealSize!.additionalPrice<=0) {
      total += _selectedMealSize!.additionalPrice;
    }
    else if(_selectedMealSize != null){
            total = _selectedMealSize!.additionalPrice;

    }
    else{
      total=total;
    }
    
    
    for (var extra in _selectedExtras) {
      total += extra.price;
    }
    
    for (var addon in _selectedAddons) {
      total += addon.price;
    }
    
    return total * _quantity;
  }
Widget _buildDesktopBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 48.w : 32.w,
        vertical: 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680.w),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    AppStrings.get('totalAmount'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (widget.foodItem.hasActiveOffer) ...[
                      Text(
                        '${AppStrings.currency}${(_quantity * widget.foodItem.price).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      '${AppStrings.currency}${_calculateTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: CustomButton(
                text: AppStrings.addToCart,
                onPressed: _addToCart,
                height: 56.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (widget.foodItem.hasActiveOffer) ...[
                          Text(
                            '${AppStrings.currency}${(_quantity * widget.foodItem.price).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textLight,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          '${AppStrings.currency}${_calculateTotalPrice().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: AppStrings.addToCart,
              onPressed: _addToCart,
              height: 54.h,
            ),
          ],
        ),
      ),
    );
  }

 void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Create a copy of the foodItem with the effective price
    final foodItemWithDiscount = widget.foodItem.copyWith(
      price: widget.foodItem.effectivePrice, // Use effectivePrice for cart
    );
    
    cartProvider.addItem(
      foodItem: foodItemWithDiscount,
      quantity: _quantity,
      selectedMealSize: _selectedMealSize,
      selectedExtras: _selectedExtras,
      selectedAddons: _selectedAddons,
      specialInstructions: _instructionsController.text.trim(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                '${widget.foodItem.name} added to cart',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 2),
      ),
    );
    
    context.pop();
  }
}