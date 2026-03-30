// lib/features/providers/menu_provider.dart - Platform-Aware Discounts

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TargetPlatform;
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/food_category.dart';
import '../../../shared/models/food_item.dart';
import '../../../shared/models/offer.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  static const int minSearchLength = 2;

  // Platform detection
  String _currentPlatform = 'mobile'; // Default to mobile

  // Categories
  List<FoodCategory> _categories = [];
  
  // Food items
  List<FoodItem> _allFoodItems = [];
  List<FoodItem> _foodItems = [];
  
  // Store items with offers for merging
  List<FoodItemWithOffer> _itemsWithOffers = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isSearching = false;
  
  // Error
  String? _error;
  
  // Filters
  bool _showVegOnly = false;
  bool _showNonVegOnly = false;
  bool _showPopularOnly = false;
  
  // Search
  String _searchQuery = '';
  Timer? _debounceTimer;
  int _searchRequestId = 0;
  
  // Sort
  String _sortBy = 'name';
  
  // Language
  String _currentLanguage = 'es';
  
  // Current category
  String? _currentCategoryId;

  // Getters
  List<FoodCategory> get categories => _categories;
  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  bool get showVegOnly => _showVegOnly;
  bool get showNonVegOnly => _showNonVegOnly;
  bool get showPopularOnly => _showPopularOnly;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get currentLanguage => _currentLanguage;
  String get currentPlatform => _currentPlatform;
  bool get hasItems => _allFoodItems.isNotEmpty;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ==================== PLATFORM DETECTION ====================
  
  /// Initialize platform based on Flutter's TargetPlatform
  void initializePlatform(TargetPlatform platform) {
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.android) {
      _currentPlatform = 'mobile';
    } else if (platform == TargetPlatform.windows || 
               platform == TargetPlatform.macOS || 
               platform == TargetPlatform.linux) {
      _currentPlatform = 'web';
    } else {
      _currentPlatform = 'web'; // Default for web/unknown
    }
    
    if (kDebugMode) {
      print('🔧 [MenuProvider] Platform detected: $_currentPlatform');
    }
  }

  /// Manually set platform (for testing or override)
  void setPlatform(String platform) {
    if (_currentPlatform != platform && ['mobile', 'web', 'all'].contains(platform)) {
      _currentPlatform = platform;
      
      if (kDebugMode) {
        print('🔧 [MenuProvider] Platform changed to: $_currentPlatform');
      }
      
      // Reload data with new platform
      if (_searchQuery.isNotEmpty) {
        _performSearch(_searchQuery);
      } else {
        loadFoodItems(categoryId: _currentCategoryId);
      }
    }
  }

  // ==================== LANGUAGE ====================
  
  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _apiService.setLanguage(languageCode);
      
      loadCategories();
      if (_searchQuery.isNotEmpty) {
        _performSearch(_searchQuery);
      } else {
        loadFoodItems(categoryId: _currentCategoryId);
      }
    }
  }

  // ==================== CATEGORIES ====================
  
  Future<void> loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MenuProvider] Load categories error: $e');
      }
    }
  }

  // ==================== LOAD ITEMS WITH OFFERS (PLATFORM-AWARE) ====================
  
  Future<void> loadItemsWithOffers() async {
    try {
      if (kDebugMode) {
        print('🔍 [MenuProvider] Loading items with offers for platform: $_currentPlatform');
      }
      
      final response = await _apiService.dio.get(
        '/offer/items-with-offers',
        queryParameters: {
          'lang': _currentLanguage,
          'platform': _currentPlatform, // NEW: Include platform
        },
        // Offers aggregation can be slower than regular menu calls.
        // Use a request-level timeout so this endpoint does not fail at the
        // global 15s default during temporary backend slowness.
        options: Options(
          receiveTimeout: const Duration(seconds: 35),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> itemsJson = response.data['items'] ?? [];
        _itemsWithOffers = itemsJson
            .map((json) {
              try {
                return FoodItemWithOffer.fromJson(
                  json,
                  currentLanguage: _currentLanguage,
                );
              } catch (e) {
                return null;
              }
            })
            .whereType<FoodItemWithOffer>()
            .toList();
        
        if (kDebugMode) {
          print('✅ [MenuProvider] Loaded ${_itemsWithOffers.length} items with offers for $_currentPlatform');
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        if (e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionTimeout) {
          print('⚠️ [MenuProvider] Offers request timed out; continuing without merged offers.');
        } else {
          print('❌ [MenuProvider] Load offers error: $e');
        }
      }
      _itemsWithOffers = [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MenuProvider] Load offers error: $e');
      }
      _itemsWithOffers = [];
    }
  }

  // ==================== PLATFORM-AWARE MERGE ====================
  
  List<FoodItem> _mergeOffersIntoItems(List<FoodItem> items) {
    if (items.isEmpty) return items;
    if (_itemsWithOffers.isEmpty) {
      if (kDebugMode) {
        print('⚠️ [MenuProvider] No offers to merge');
      }
      return items;
    }

    final offerMapById = <String, FoodItemWithOffer>{};
    final offerMapByName = <String, FoodItemWithOffer>{};
    
    for (final offerItem in _itemsWithOffers) {
      try {
        if (offerItem.id.isNotEmpty) {
          offerMapById[offerItem.id] = offerItem;
        }
        
        final normalizedName = offerItem.name.toLowerCase().trim();
        if (normalizedName.isNotEmpty) {
          offerMapByName[normalizedName] = offerItem;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [MenuProvider] Error building offer map: $e');
        }
      }
    }

    int mergedCount = 0;
    int platformFilteredCount = 0;

    final mergedItems = items.map((item) {
      try {
        FoodItemWithOffer? offerItem = offerMapById[item.id];
        
        if (offerItem == null && item.name.isNotEmpty) {
          final normalizedName = item.name.toLowerCase().trim();
          offerItem = offerMapByName[normalizedName];
        }

        if (offerItem != null && offerItem.offer != null) {
          // NEW: Check if offer is valid for current platform
          if (offerItem.offer!.isValidForPlatform(_currentPlatform)) {
            mergedCount++;
            return item.copyWith(offer: offerItem.offer);
          } else {
            platformFilteredCount++;
            // Offer exists but not for this platform - don't merge
            return item;
          }
        }

        return item;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [MenuProvider] Error merging offer for ${item.name}: $e');
        }
        return item;
      }
    }).toList();

    if (kDebugMode) {
      print('✅ [MenuProvider] Merged $mergedCount offers for $_currentPlatform');
      print('🚫 [MenuProvider] Filtered $platformFilteredCount offers (wrong platform)');
    }

    return mergedItems;
  }

  // ==================== FOOD ITEMS ====================
  
  Future<void> loadFoodItems({String? categoryId}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _searchQuery = '';
    _currentCategoryId = categoryId;
    notifyListeners();

    try {
      await loadItemsWithOffers();
      
      final response = await _apiService.getFoodItems(
        categoryId: categoryId,
        featured: _showPopularOnly ? true : null,
        limit: 100,
      );

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        _allFoodItems = _mergeOffersIntoItems(parsedItems);
        _applyLocalFilters();
        
        if (kDebugMode) {
          final withOffers = _allFoodItems.where((item) => 
            item.hasActiveOfferForPlatform(_currentPlatform)).length;
          print('✅ [MenuProvider] Loaded ${_allFoodItems.length} items, '
                '$withOffers with active offers for $_currentPlatform');
        }
      } else {
        _error = response.error ?? 'Failed to load food items';
        _allFoodItems = [];
        _foodItems = [];
      }
    } catch (e) {
      _error = 'Error loading food items: ${e.toString()}';
      _allFoodItems = [];
      _foodItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== SEARCH ====================
  
  void searchFoodItems(String query) {
    _debounceTimer?.cancel();
    
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      _searchQuery = '';
      loadFoodItems(categoryId: _currentCategoryId);
      return;
    }
    
    if (trimmedQuery.length < minSearchLength) {
      _searchQuery = trimmedQuery;
      notifyListeners();
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(trimmedQuery);
    });
  }
  
  Future<void> _performSearch(String query) async {
    if (query.length < minSearchLength) return;
    if (_isSearching || _isLoading) return;
    
    _searchRequestId++;
    final currentRequestId = _searchRequestId;
    
    _searchQuery = query;
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      await loadItemsWithOffers();
      
      if (currentRequestId != _searchRequestId) return;
      
      final response = await _apiService.getFoodItems(
        search: query,
        categoryId: _currentCategoryId,
        limit: 100,
      );

      if (currentRequestId != _searchRequestId) return;

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        _allFoodItems = _mergeOffersIntoItems(parsedItems);
        _applyLocalFilters();
      } else {
        _error = response.error ?? 'Search failed';
        _allFoodItems = [];
        _foodItems = [];
      }
    } catch (e) {
      if (currentRequestId == _searchRequestId) {
        _error = 'Search error: ${e.toString()}';
        _allFoodItems = [];
        _foodItems = [];
      }
    } finally {
      if (currentRequestId == _searchRequestId) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  // ==================== FILTERS ====================
  
  void setVegFilter(bool value) {
    _showVegOnly = value;
    if (_showVegOnly) _showNonVegOnly = false;
    _applyLocalFilters();
  }

  void setNonVegFilter(bool value) {
    _showNonVegOnly = value;
    if (_showNonVegOnly) _showVegOnly = false;
    _applyLocalFilters();
  }

  void setPopularFilter(bool value) {
    _showPopularOnly = value;
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    } else {
      loadFoodItems(categoryId: _currentCategoryId);
    }
  }

  void setSortBy(String value) {
    _sortBy = value;
    _applyLocalFilters();
  }

  void clearFilters() {
    _showVegOnly = false;
    _showNonVegOnly = false;
    _showPopularOnly = false;
    _searchQuery = '';
    _sortBy = 'name';
    loadFoodItems(categoryId: _currentCategoryId);
  }

  void _applyLocalFilters() {
    if (_allFoodItems.isEmpty) {
      _foodItems = [];
      notifyListeners();
      return;
    }

    List<FoodItem> filteredItems = List.from(_allFoodItems);

    if (_showVegOnly) {
      filteredItems = filteredItems.where((item) => item.isVeg).toList();
    } else if (_showNonVegOnly) {
      filteredItems = filteredItems.where((item) => !item.isVeg).toList();
    }

    // NEW: Use platform-aware methods for sorting
    switch (_sortBy) {
      case 'name':
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price-low':
        filteredItems.sort((a, b) => 
          a.getEffectivePriceForPlatform(_currentPlatform)
            .compareTo(b.getEffectivePriceForPlatform(_currentPlatform))
        );
        break;
      case 'price-high':
        filteredItems.sort((a, b) => 
          b.getEffectivePriceForPlatform(_currentPlatform)
            .compareTo(a.getEffectivePriceForPlatform(_currentPlatform))
        );
        break;
      case 'rating':
        filteredItems.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'discount':
        // NEW: Sort by discount percentage for current platform
        filteredItems.sort((a, b) => 
          b.getDiscountPercentageForPlatform(_currentPlatform)
            .compareTo(a.getDiscountPercentageForPlatform(_currentPlatform))
        );
        break;
    }

    _foodItems = filteredItems;
    notifyListeners();
  }

  // ==================== PLATFORM-AWARE HELPERS ====================
  
  /// Get items with active offers for current platform
  List<FoodItem> getItemsWithOffers() {
    return _foodItems
        .where((item) => item.hasActiveOfferForPlatform(_currentPlatform))
        .toList();
  }

  /// Get best discount items for current platform
  List<FoodItem> getBestDiscounts({int limit = 10}) {
    final itemsWithOffers = _foodItems
        .where((item) => item.hasActiveOfferForPlatform(_currentPlatform))
        .toList();
    
    itemsWithOffers.sort((a, b) => 
      b.getDiscountPercentageForPlatform(_currentPlatform)
        .compareTo(a.getDiscountPercentageForPlatform(_currentPlatform))
    );
    
    return itemsWithOffers.take(limit).toList();
  }

  // ==================== HELPERS ====================
  
  List<FoodItem> _parseFoodItems(dynamic data) {
    if (data == null) return [];
    
    final List items = data is List ? data : [data];
    final parsedItems = <FoodItem>[];
    
    for (final item in items) {
      try {
        if (item is FoodItem) {
          parsedItems.add(item);
        } else if (item is Map<String, dynamic>) {
          final foodItem = FoodItem.fromMap(
            item,
            currentLanguage: _currentLanguage,
          );
          parsedItems.add(foodItem);
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [MenuProvider] Error parsing food item: $e');
        }
      }
    }
    
    return parsedItems;
  }
}