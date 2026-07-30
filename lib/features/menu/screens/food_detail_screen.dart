import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/main.dart';
import '../../../shared/models/food_item.dart';
import 'food_detail/widgets/desktop_back_button.dart';
import 'food_detail/widgets/food_image_section.dart';
import 'food_detail/widgets/food_detail_sliver_app_bar.dart';
import 'food_detail/widgets/food_info_section.dart';
import 'food_detail/widgets/quantity_selector.dart';
import 'food_detail/widgets/meal_size_options.dart';
import 'food_detail/widgets/extras_section.dart';
import 'food_detail/widgets/addons_section.dart';
import 'food_detail/widgets/special_instructions_section.dart';
import 'food_detail/widgets/desktop_bottom_bar.dart';
import 'food_detail/widgets/mobile_bottom_bar.dart';

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
  
  late FoodItem _currentFoodItem;
  String _lastLanguage = '';
  bool _isLoadingLanguageChange = false;
  
  // ✅ Platform detection
  late String _currentPlatform;

  @override
  void initState() {
    super.initState();
    _currentFoodItem = widget.foodItem;
    _lastLanguage = context.read<LanguageService>().currentLanguage;
    
    // ✅ Detect platform
    _currentPlatform = _detectPlatform();
    
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

  // ✅ Platform detection method (web-safe, no dart:io)
  String _detectPlatform() {
    if (kIsWeb) return 'web';
    // On non-web platforms, default to mobile (Android/iOS)
    return 'mobile';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageService = context.watch<LanguageService>();
    final currentLang = languageService.currentLanguage;
    
    AppStrings.setLanguage(currentLang);
    
    if (_lastLanguage != currentLang && !_isLoadingLanguageChange) {
      _lastLanguage = currentLang;
      _reloadFoodItem(currentLang);
    }
  }

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
            
            if (_currentFoodItem.mealSizes.isNotEmpty) {
              final previousSizeId = _selectedMealSize?.id;
              _selectedMealSize = _currentFoodItem.mealSizes.firstWhere(
                (size) => size.id == previousSizeId,
                orElse: () => _currentFoodItem.mealSizes.first,
              );
            }
            
            final previousExtraIds = _selectedExtras.map((e) => e.id).toList();
            _selectedExtras = _currentFoodItem.extras
                .where((extra) => previousExtraIds.contains(extra.id))
                .toList();
            
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

  // ✅ Platform-aware discount calculations
double get _effectivePrice {
  // Base price from selected size or default price
  double basePrice = _selectedMealSize != null && _selectedMealSize!.additionalPrice > 0
      ? _selectedMealSize!.additionalPrice
      : _currentFoodItem.price;
  
  // Apply platform-specific discount to base price only
  return _currentFoodItem.getEffectivePriceForPlatform(_currentPlatform) * 
         (basePrice / _currentFoodItem.price);
}

double get _discountAmount => _currentFoodItem.getDiscountAmountForPlatform(_currentPlatform);
int get _discountPercentage => _currentFoodItem.getDiscountPercentageForPlatform(_currentPlatform);
bool get _hasActiveOffer => _currentFoodItem.hasActiveOfferForPlatform(_currentPlatform);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Stack(
            children: [
              _isLargeScreen ? _buildDesktopLayout() : _buildMobileLayout(),
              
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
                FoodImageSection(foodItem: _currentFoodItem),
                const DesktopBackButton(),
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
              DesktopBottomBar(
                isDesktop: _isDesktop,
                foodItem: widget.foodItem,
                quantity: _quantity,
                selectedMealSize: _selectedMealSize,
                hasActiveOffer: _hasActiveOffer,
                totalPrice: _calculateTotalPrice(),
                onAddToCart: _addToCart,
              ),
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
        FoodDetailSliverAppBar(foodItem: _currentFoodItem),
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
        FoodInfoSection(
          foodItem: _currentFoodItem,
          isLargeScreen: _isLargeScreen,
          hasActiveOffer: _hasActiveOffer,
          effectivePrice: _effectivePrice,
        ),
        SizedBox(height: _isLargeScreen ? 40.h : 0),
        QuantitySelector(
          quantity: _quantity,
          isLargeScreen: _isLargeScreen,
          onDecrement: () {
            if (_quantity > 1) {
              setState(() => _quantity--);
            }
          },
          onIncrement: () => setState(() => _quantity++),
        ),
        if (_currentFoodItem.mealSizes.isNotEmpty) ...[
          SizedBox(height: _isLargeScreen ? 36.h : 0),
          MealSizeOptions(
            mealSizes: widget.foodItem.mealSizes,
            selectedMealSize: _selectedMealSize,
            isLargeScreen: _isLargeScreen,
            onSelected: (value) => setState(() => _selectedMealSize = value),
          ),
        ],
        if (_currentFoodItem.extras.isNotEmpty) ...[
          SizedBox(height: _isLargeScreen ? 36.h : 0),
          ExtrasSection(
            extras: widget.foodItem.extras,
            selectedExtras: _selectedExtras,
            isLargeScreen: _isLargeScreen,
            onToggle: (extra) {
              setState(() {
                if (_selectedExtras.any((e) => e.id == extra.id)) {
                  _selectedExtras.removeWhere((e) => e.id == extra.id);
                } else {
                  _selectedExtras.add(extra);
                }
              });
            },
          ),
        ],
        if (_currentFoodItem.addons.isNotEmpty) ...[
          SizedBox(height: _isLargeScreen ? 36.h : 0),
          AddonsSection(
            addons: widget.foodItem.addons,
            selectedAddons: _selectedAddons,
            isLargeScreen: _isLargeScreen,
            onToggle: (addon) {
              setState(() {
                if (_selectedAddons.any((a) => a.id == addon.id)) {
                  _selectedAddons.removeWhere((a) => a.id == addon.id);
                } else {
                  _selectedAddons.add(addon);
                }
              });
            },
          ),
        ],
        SizedBox(height: _isLargeScreen ? 36.h : 0),
        SpecialInstructionsSection(
          isLargeScreen: _isLargeScreen,
          controller: _instructionsController,
        ),
        SizedBox(height: _isLargeScreen ? 120.h : 16.h),
        if (!_isLargeScreen)
          MobileBottomBar(
            foodItem: widget.foodItem,
            quantity: _quantity,
            selectedMealSize: _selectedMealSize,
            totalPrice: _calculateTotalPrice(),
            onAddToCart: _addToCart,
          ),
        if (!_isLargeScreen) SizedBox(height: 24.h),
      ],
    );
  }

double _calculateTotalPrice() {
  double total = 0.0;
  
  // Start with base price (considering meal size)
  if (_selectedMealSize != null && _selectedMealSize!.additionalPrice > 0) {
    total = _selectedMealSize!.additionalPrice;
  } else {
    total = _currentFoodItem.price;
  }
  
  // Apply platform-specific discount to base price
  if (_hasActiveOffer) {
    final discountedBasePrice = _currentFoodItem.getEffectivePriceForPlatform(_currentPlatform);
    final basePriceRatio = total / _currentFoodItem.price;
    total = discountedBasePrice * basePriceRatio;
  }
  
  // Add meal size additional cost if it's negative (discount)
  if (_selectedMealSize != null && _selectedMealSize!.additionalPrice < 0) {
    total += _selectedMealSize!.additionalPrice;
  }
  
  // Add extras (no discount on extras)
  for (var extra in _selectedExtras) {
    total += extra.price;
  }
  
  // Add addons (no discount on addons)
  for (var addon in _selectedAddons) {
    total += addon.price;
  }
  
  return total * _quantity;
}

 void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final foodItem = widget.foodItem;
    
    // Create a copy of the foodItem with the effective price
    final foodItemWithDiscount = widget.foodItem.copyWith(
    );
    
    cartProvider.addItem(
      foodItem: foodItemWithDiscount,
      quantity: _quantity,
      selectedMealSize: _selectedMealSize,
      selectedExtras: _selectedExtras,
      selectedAddons: _selectedAddons,
      specialInstructions: _instructionsController.text.trim(),
    );
    
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get('addedToCart').replaceAll('{itemName}', foodItem.name),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        action: SnackBarAction(
          label: AppStrings.get('undo'),
          textColor: Colors.white,
          onPressed: () => cartProvider.removeItem(foodItem.id),
        ),
      ),
    );

    // Manual backup dismissal for Web stability
    Future.delayed(const Duration(seconds: 5), () {
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    });
    
    context.pop();
  }
}