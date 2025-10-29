// lib/features/providers/menu_provider.dart - FIXED: Minimum search length validation

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/food_category.dart';
import '../../../shared/models/food_item.dart';
import '../../../shared/models/offer.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ✅ Minimum search length (backend requires at least 2 characters)
  static const int minSearchLength = 2;

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
  bool get hasItems => _allFoodItems.isNotEmpty;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
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
      } else {
        debugPrint('Failed to load categories: ${response.error}');
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // ==================== LOAD ITEMS WITH OFFERS ====================
  
  Future<void> loadItemsWithOffers() async {
    try {
      final response = await _apiService.dio.get(
        '/offer/items-with-offers',
        queryParameters: {
          'lang': _currentLanguage,
        },
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
                debugPrint('⚠️ Error parsing offer item: $e');
                return null;
              }
            })
            .whereType<FoodItemWithOffer>()
            .toList();
        
        debugPrint('✅ Loaded ${_itemsWithOffers.length} items with offers');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading items with offers: $e');
      _itemsWithOffers = [];
    }
  }

  // ==================== SAFE MERGE WITH MAP LOOKUP ====================
  
  List<FoodItem> _mergeOffersIntoItems(List<FoodItem> items) {
    if (items.isEmpty) return items;
    if (_itemsWithOffers.isEmpty) {
      debugPrint('⚠️ No offers available for merging');
      return items;
    }

    debugPrint('🔄 Merging offers into ${items.length} items...');

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
        debugPrint('⚠️ Error mapping offer item: $e');
      }
    }

    int mergedCount = 0;

    return items.map((item) {
      try {
        FoodItemWithOffer? offerItem = offerMapById[item.id];
        
        if (offerItem == null && item.name.isNotEmpty) {
          final normalizedName = item.name.toLowerCase().trim();
          offerItem = offerMapByName[normalizedName];
        }

        if (offerItem != null && offerItem.offer != null) {
          mergedCount++;
          debugPrint('✅ Merged offer for: ${item.name}');
          return item.copyWith(offer: offerItem.offer);
        }

        return item;
      } catch (e) {
        debugPrint('⚠️ Error merging offer for ${item.name}: $e');
        return item;
      }
    }).toList();
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
        
        debugPrint('✅ Loaded ${_allFoodItems.length} food items (${_foodItems.length} after filters)');
        debugPrint('✅ Items with offers: ${_allFoodItems.where((i) => i.hasActiveOffer).length}');
      } else {
        _error = response.error ?? 'Failed to load food items';
        _allFoodItems = [];
        _foodItems = [];
      }
    } catch (e) {
      _error = 'Error loading food items: ${e.toString()}';
      _allFoodItems = [];
      _foodItems = [];
      debugPrint('❌ Error loading food items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== ✅ FIXED: SEARCH WITH MINIMUM LENGTH ====================
  
  void searchFoodItems(String query) {
    _debounceTimer?.cancel();
    
    final trimmedQuery = query.trim();
    
    // ✅ Empty query - reload all items
    if (trimmedQuery.isEmpty) {
      _searchQuery = '';
      loadFoodItems(categoryId: _currentCategoryId);
      return;
    }
    
    // ✅ Too short - wait for more characters
    if (trimmedQuery.length < minSearchLength) {
      debugPrint('⏸️ Search query too short: "$trimmedQuery" (min: $minSearchLength chars)');
      _searchQuery = trimmedQuery;
      // Don't trigger search yet, just update the query
      notifyListeners();
      return;
    }
    
    // ✅ Valid length - debounce and search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(trimmedQuery);
    });
  }
  
  Future<void> _performSearch(String query) async {
    // ✅ Double-check length before API call
    if (query.length < minSearchLength) {
      debugPrint('⏸️ Skipping search - query too short: "$query"');
      return;
    }
    
    if (_isSearching || _isLoading) return;
    
    _searchRequestId++;
    final currentRequestId = _searchRequestId;
    
    _searchQuery = query;
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔍 Starting search #$currentRequestId for: "$query"');
      
      await loadItemsWithOffers();
      
      if (currentRequestId != _searchRequestId) {
        debugPrint('⏭️ Search #$currentRequestId cancelled');
        return;
      }
      
      final response = await _apiService.getFoodItems(
        search: query,
        categoryId: _currentCategoryId,
        limit: 100,
      );

      if (currentRequestId != _searchRequestId) {
        debugPrint('⏭️ Search #$currentRequestId results discarded');
        return;
      }

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        _allFoodItems = _mergeOffersIntoItems(parsedItems);
        _applyLocalFilters();
        
        debugPrint('✅ Search #$currentRequestId complete: ${_allFoodItems.length} results');
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
        debugPrint('❌ Search #$currentRequestId error: $e');
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

    switch (_sortBy) {
      case 'name':
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price-low':
        filteredItems.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price-high':
        filteredItems.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'rating':
        filteredItems.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    _foodItems = filteredItems;
    notifyListeners();
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
        debugPrint('⚠️ Error parsing food item: $e');
      }
    }
    
    return parsedItems;
  }
}