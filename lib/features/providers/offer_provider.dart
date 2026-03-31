// lib/features/providers/offer_provider.dart - COMPLETE VERSION
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/core/services/device_discount_manager.dart';
import 'package:Saborly/shared/models/offer.dart';

class OffersProvider extends ChangeNotifier {
  List<OfferModel> _allOffers = [];
  List<FoodItemWithOffer> _itemsWithOffers = [];
  bool _isLoading = false;
  String? _error;
  String _currentLanguage = 'es';
  
  // Device discount manager
  DeviceDiscountManager? _deviceDiscountManager;
  Map<String, dynamic>? _activeDeviceDiscount;
  
  // Track claimed one-time offers for this device
  Set<String> _claimedOfferIds = {};
  
  // Initialization flag
  bool _isInitialized = false;

  static const String baseUrl = 'https://api.saborly.es/api/v1';

  // Getters
  List<OfferModel> get allOffers => _filterClaimedOffers(_allOffers);
  List<FoodItemWithOffer> get itemsWithOffers => _filterClaimedItemOffers(_itemsWithOffers);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentLanguage => _currentLanguage;
  Map<String, dynamic>? get activeDeviceDiscount => _activeDeviceDiscount;
  bool get hasActiveDiscount => _activeDeviceDiscount != null;
  String? get deviceId => _deviceDiscountManager?.deviceId;
  bool get isInitialized => _isInitialized;
  
  List<OfferModel> get foodOffers => _filterClaimedOffers(
    _allOffers.where((offer) => 
      offer.category == 'food' || offer.type == 'percentage' || offer.type == 'fixed-amount'
    ).toList()
  );
  
  List<OfferModel> get limitedTimeOffers => _filterClaimedOffers(
    _allOffers.where((offer) => 
      offer.expiryDate != null && offer.expiryDate!.isAfter(DateTime.now())
    ).toList()
  );

  // ==================== INITIALIZATION ====================
  
  /// Initialize the provider - call this once on app start
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ OffersProvider already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🔧 Initializing OffersProvider...');
      }

      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // Initialize device discount manager
      _deviceDiscountManager = DeviceDiscountManager(prefs);
      await _deviceDiscountManager!.initialize();
      
      if (kDebugMode) {
        print('📱 Device ID: ${_deviceDiscountManager!.deviceId}');
      }
      
      // Load active device discount
      await _loadActiveDeviceDiscount();
      
      // Load claimed offer IDs from local storage
      await _loadClaimedOfferIds();
      
      // Sync with backend to ensure consistency
      await syncClaimedOffersWithBackend();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ OffersProvider initialized successfully');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing OffersProvider: $e');
      }
      _error = 'Failed to initialize: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load the active discount for this device
  Future<void> _loadActiveDeviceDiscount() async {
    if (_deviceDiscountManager == null) return;
    
    try {
      _activeDeviceDiscount = await _deviceDiscountManager!.getActiveDiscount();
      
      if (_activeDeviceDiscount != null && kDebugMode) {
        print('📱 Device has active discount: ${_activeDeviceDiscount!['offerTitle']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading active discount: $e');
      }
    }
  }

  /// Load claimed offer IDs from device storage
  Future<void> _loadClaimedOfferIds() async {
    if (_deviceDiscountManager == null) return;
    
    try {
      _claimedOfferIds = await _deviceDiscountManager!.getClaimedOfferIds();
      
      if (kDebugMode) {
        print('📝 Loaded ${_claimedOfferIds.length} claimed offer IDs');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading claimed offers: $e');
      }
      _claimedOfferIds = {};
    }
  }

  /// Sync claimed offers with backend
  Future<void> syncClaimedOffersWithBackend() async {
    if (_deviceDiscountManager == null) return;

    try {
      final deviceId = _deviceDiscountManager!.deviceId;
      if (deviceId == null) return;

      if (kDebugMode) {
        print('🔄 Syncing claimed offers with backend...');
      }

      // Get claimed offers from backend
      final response = await http.get(
        Uri.parse('$baseUrl/offer/device-claims?deviceId=$deviceId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> claimedOffers = data['claimedOffers'] ?? [];
          final backendClaimedIds = claimedOffers
              .map((offer) => offer['offerId'] as String?)
              .whereType<String>()
              .toSet();

          // Merge with local claims
          _claimedOfferIds.addAll(backendClaimedIds);

          // Update local storage for any new backend claims
          for (final offerId in backendClaimedIds) {
            if (!await _deviceDiscountManager!.isOfferClaimed(offerId)) {
              await _deviceDiscountManager!.markOfferAsClaimed(offerId);
            }
          }

          if (kDebugMode) {
            print('✅ Synced ${backendClaimedIds.length} claimed offers from backend');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to sync with backend: $e');
      }
      // Don't throw - continue with local data
    }
  }

  // ==================== FILTERING ====================
  
  /// Filter out claimed one-time offers
  List<OfferModel> _filterClaimedOffers(List<OfferModel> offers) {
    return offers.where((offer) {
      // If it's not a one-time offer, always show it
      if (!offer.isOneTimePerDevice) return true;
      
      // If it's one-time and claimed, hide it
      return !_claimedOfferIds.contains(offer.id);
    }).toList();
  }

  /// Filter out items with claimed one-time offers
  List<FoodItemWithOffer> _filterClaimedItemOffers(List<FoodItemWithOffer> items) {
    return items.where((item) {
      // If item has no offer, keep it
      if (item.offer == null) return true;
      
      // If offer is not one-time, keep it
      if (!item.offer!.isOneTimePerDevice) return true;
      
      // If offer is one-time and claimed, remove item
      return !_claimedOfferIds.contains(item.offer!.id);
    }).toList();
  }

  // ==================== CLAIMING METHODS ====================

  /// Mark offer as claimed locally (called from payment provider)
  Future<void> markOfferAsClaimedLocally(String offerId) async {
    if (_deviceDiscountManager == null) {
      if (kDebugMode) {
        print('⚠️ Device discount manager not initialized');
      }
      return;
    }

    try {
      // Add to claimed set
      _claimedOfferIds.add(offerId);

      // Mark in device discount manager (persistent storage)
      await _deviceDiscountManager!.markOfferAsClaimed(
        offerId,
        offerTitle: 'Offer $offerId',
      );

      if (kDebugMode) {
        print('✅ Locally marked offer $offerId as claimed');
      }

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking offer locally: $e');
      }
    }
  }

  /// Check if specific offer is claimed by this device
  bool isOfferClaimedByDevice(String offerId) {
    return _claimedOfferIds.contains(offerId);
  }

  /// Check if device can claim a new discount
  Future<bool> canClaimDiscount() async {
    if (_deviceDiscountManager == null) {
      await initialize();
    }
    
    return !(await _deviceDiscountManager!.hasActiveDiscount());
  }

  /// Claim a discount for this device
  Future<bool> claimDiscount({
    required String offerId,
    required String offerTitle,
    required String offerType,
    required double discountValue,
    DateTime? expiryDate,
    String? itemId,
    String? itemName,
    bool isOneTimeOffer = false,
  }) async {
    if (_deviceDiscountManager == null) {
      await initialize();
    }

    final success = await _deviceDiscountManager!.claimDiscount(
      offerId: offerId,
      offerTitle: offerTitle,
      offerType: offerType,
      discountValue: discountValue,
      expiryDate: expiryDate,
      itemId: itemId,
      itemName: itemName,
    );

    if (success) {
      await _loadActiveDeviceDiscount();
      
      // If it's a one-time offer, add to claimed set
      if (isOneTimeOffer) {
        _claimedOfferIds.add(offerId);
        
        if (kDebugMode) {
          print('✅ One-time offer $offerId claimed and hidden');
        }
      }
      
      notifyListeners();
    }

    return success;
  }

  /// Release the current discount (called after order completion)
  Future<void> releaseDiscount() async {
    if (_deviceDiscountManager == null) return;
    
    await _deviceDiscountManager!.clearActiveDiscount();
    _activeDeviceDiscount = null;
    notifyListeners();
  }

  /// Get discount history for this device
  Future<List<Map<String, dynamic>>> getDiscountHistory() async {
    if (_deviceDiscountManager == null) {
      await initialize();
    }
    
    return await _deviceDiscountManager!.getDiscountHistory();
  }

  /// Get claimed offer IDs
  Future<Set<String>> getClaimedOfferIds() async {
    if (_deviceDiscountManager == null) {
      await initialize();
    }
    
    return _claimedOfferIds;
  }

  // ==================== PLATFORM DETECTION ====================
  
  /// Detect current platform
  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    }
    return 'all';
  }

  // ==================== LANGUAGE ====================
  
  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  // ==================== LOAD OFFERS ====================
  
  /// Main method: Load all offers with language support
  Future<void> loadOffers() async {
    // Ensure initialized
    if (!_isInitialized) {
      await initialize();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Set API language
      ApiService().setLanguage(_currentLanguage);
      
      // Run both requests in parallel
      await Future.wait([
        _loadMainOffers(),
        _loadItemsWithOffers(),
      ]);

    } catch (e) {
      _error = 'Failed to load offers: ${e.toString()}';
      if (kDebugMode) {
        print('❌ Error loading offers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load main offers with platform filter and device ID
  Future<void> _loadMainOffers() async {
    try {
      final platform = _getPlatform();
      final deviceId = _deviceDiscountManager?.deviceId ?? '';
      
      // Include deviceId in request to get server-side filtering
      final response = await http.get(
        Uri.parse('$baseUrl/offer?platform=$platform&deviceId=$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Language': _currentLanguage,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> offersJson = data['offers'] ?? [];
          _allOffers = offersJson
              .map((json) => _parseOfferFromApi(json))
              .toList();
          
          if (kDebugMode) {
            print('✅ Loaded ${_allOffers.length} offers for $platform');
            final filtered = _filterClaimedOffers(_allOffers);
            print('📊 ${filtered.length} offers after device filtering');
          }
        } else {
          _error = data['message'] ?? 'Failed to load main offers';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading main offers: $e');
      }
      _allOffers = [];
    }
  }

  /// Load items with active offers (with platform filter and device ID)
  Future<void> _loadItemsWithOffers() async {
    try {
      final platform = _getPlatform();
      final deviceId = _deviceDiscountManager?.deviceId ?? '';
      final url = '$baseUrl/offer/items-with-offers?platform=$platform&deviceId=$deviceId&includeUnavailable=false';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Language': _currentLanguage,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> itemsJson = data['items'] ?? [];
          
          if (itemsJson.isEmpty) {
            _itemsWithOffers = [];
          } else {
            _itemsWithOffers = itemsJson
                .map((json) {
                  try {
                    return FoodItemWithOffer.fromJson(
                      json,
                      currentLanguage: _currentLanguage,
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print('⚠️ Error parsing item: $e');
                    }
                    return null;
                  }
                })
                .whereType<FoodItemWithOffer>()
                .toList();
            
            if (kDebugMode) {
              print('✅ Loaded ${_itemsWithOffers.length} items with offers');
              final filtered = _filterClaimedItemOffers(_itemsWithOffers);
              print('📊 ${filtered.length} items after device filtering');
            }
          }
        } else {
          _error = data['message'] ?? 'Failed to load items with offers';
          _itemsWithOffers = [];
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        _itemsWithOffers = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading items with offers: $e');
      }
      _itemsWithOffers = [];
    }
  }

  // ==================== VALIDATION ====================
  
  /// Validate coupon code with device check
  Future<Map<String, dynamic>?> validateCouponCode(
    String couponCode, {
    required double subtotal,
    String? deliveryType,
  }) async {
    // Ensure initialized
    if (!_isInitialized) {
      await initialize();
    }

    // Check if device already has a discount
    if (await _deviceDiscountManager!.hasActiveDiscount()) {
      final activeDiscount = await _deviceDiscountManager!.getActiveDiscount();
      return {
        'success': false,
        'message': 'You already have an active discount: ${activeDiscount?['offerTitle']}',
        'hasActiveDiscount': true,
      };
    }

    try {
      final platform = _getPlatform();
      
      final response = await http.post(
        Uri.parse('$baseUrl/offer/validate-coupon'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'couponCode': couponCode,
          'platform': platform,
          'deviceId': _deviceDiscountManager!.deviceId,
          'orderDetails': {
            'subtotal': subtotal,
            'deliveryType': deliveryType ?? 'pickup',
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error validating coupon: $e');
      }
      return null;
    }
  }

  // ==================== HELPERS ====================
  
  /// Get items by category with offers (filtered)
  List<FoodItemWithOffer> getItemsByCategory(String categoryId) {
    final filtered = _filterClaimedItemOffers(_itemsWithOffers);
    return filtered
      .where((item) => item.category.id == categoryId)
      .toList();
  }

  /// Get best discount items (sorted by discount percentage, filtered)
  List<FoodItemWithOffer> getBestDiscounts({int limit = 10}) {
    final filtered = _filterClaimedItemOffers(_itemsWithOffers);
    final sortedItems = List<FoodItemWithOffer>.from(filtered);
    sortedItems.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    return sortedItems.take(limit).toList();
  }

  /// Filter items by minimum discount percentage (filtered)
  List<FoodItemWithOffer> filterByMinDiscount(int minPercentage) {
    final filtered = _filterClaimedItemOffers(_itemsWithOffers);
    return filtered
      .where((item) => item.discountPercentage >= minPercentage)
      .toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Parse offer from API response
  OfferModel _parseOfferFromApi(Map<String, dynamic> json) {
    final type = json['type'] as String;
    String badge = '';
    String category = 'general';
    
    switch (type) {
      case 'percentage':
        badge = 'SAVE ${json['value']}%';
        category = 'food';
        break;
      case 'fixed-amount':
        badge = '\$${json['value']} OFF';
        category = 'food';
        break;
      case 'buy-one-get-one':
        badge = 'BUY 1 GET 1';
        category = 'food';
        break;
      case 'free-delivery':
        badge = 'FREE DELIVERY';
        category = 'delivery';
        break;
      case 'combo':
        badge = 'COMBO DEAL';
        category = 'combo';
        break;
      default:
        badge = 'SPECIAL OFFER';
    }

    List<Color> gradientColors = _getGradientColors(
      json['bannerColor'] as String?,
      type,
    );

    return OfferModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      badge: badge,
      gradientColors: gradientColors,
      imageUrl: json['imageUrl'] as String?,
      expiryDate: json['endDate'] != null 
        ? DateTime.parse(json['endDate'] as String)
        : null,
      category: category,
      type: type,
      value: json['value']?.toDouble(),
      minOrderAmount: json['minOrderAmount']?.toDouble() ?? 0,
      couponCode: json['couponCode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isOneTimePerDevice: json['isOneTimePerDevice'] as bool? ?? false,
    );
  }

  /// Get gradient colors for offer type
  List<Color> _getGradientColors(String? bannerColor, String type) {
    if (bannerColor != null && bannerColor.isNotEmpty) {
      try {
        final baseColor = _hexToColor(bannerColor);
        return [
          baseColor,
          baseColor.withOpacity(0.7),
        ];
      } catch (e) {
        // Fall back to default
      }
    }

    switch (type) {
      case 'percentage':
      case 'fixed-amount':
        return [const Color(0xFF7ED4AD), const Color(0xFF6BCF7F)];
      case 'buy-one-get-one':
        return [const Color(0xFFE91E63), const Color(0xFF9C27B0)];
      case 'free-delivery':
        return [const Color(0xFF2196F3), const Color(0xFF3F51B5)];
      case 'combo':
        return [const Color(0xFFFFC107), const Color(0xFFFF9800)];
      default:
        return [const Color(0xFF7ED4AD), const Color(0xFF6BCF7F)];
    }
  }

  /// Convert hex color to Flutter Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _allOffers.clear();
    _itemsWithOffers.clear();
    _claimedOfferIds.clear();
    super.dispose();
  }
}
