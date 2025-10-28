// lib/features/providers/menu_provider.dart - ENHANCED: Merge offers into food items

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/food_category.dart';
import '../../../shared/models/food_item.dart';
import '../../../shared/models/offer.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Categories
  List<FoodCategory> _categories = [];
  
  // Food items
  List<FoodItem> _allFoodItems = [];
  List<FoodItem> _foodItems = [];
  
  // ✅ NEW: Store items with offers for merging
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

  // ==================== ✅ NEW: LOAD ITEMS WITH OFFERS ====================
  
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
                debugPrint('Error parsing offer item: $e');
                return null;
              }
            })
            .whereType<FoodItemWithOffer>()
            .toList();
        
        debugPrint('✅ Loaded ${_itemsWithOffers.length} items with offers');
      }
    } catch (e) {
      debugPrint('Error loading items with offers: $e');
    }
  }

  // ==================== ✅ ENHANCED: MERGE OFFERS INTO FOOD ITEMS ====================
  
  List<FoodItem> _mergeOffersIntoItems(List<FoodItem> items) {
    if (_itemsWithOffers.isEmpty) {
      return items;
    }

    return items.map((item) {
      // Find matching offer item by ID or name
      final offerItem = _itemsWithOffers.firstWhere(
        (offerItem) => 
          offerItem.id == item.id || 
          offerItem.name.toLowerCase().trim() == item.name.toLowerCase().trim(),
        orElse: () => FoodItemWithOffer(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: const CategoryInfo(id: '', name: ''),
          isActive: false,
          discountedPrice: 0,
          savings: 0,
          discountPercentage: 0,
        ),
      );

      // If we found a matching offer, merge it
      if (offerItem.id.isNotEmpty && offerItem.offer != null) {
        debugPrint('✅ Merging offer for: ${item.name}');
        return item.copyWith(
          offer: offerItem.offer,
        );
      }

      return item;
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
      // ✅ Load offers first
      await loadItemsWithOffers();
      
      // Then load food items
      final response = await _apiService.getFoodItems(
        categoryId: categoryId,
        featured: _showPopularOnly ? true : null,
        limit: 100,
      );

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        
        // ✅ Merge offers into items
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
      debugPrint('Error loading food items: $e');
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
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(trimmedQuery);
    });
  }
  
  Future<void> _performSearch(String query) async {
    if (_isSearching || _isLoading) return;
    
    _searchQuery = query;
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      // Load offers first
      await loadItemsWithOffers();
      
      final response = await _apiService.getFoodItems(
        search: query,
        categoryId: _currentCategoryId,
        limit: 100,
      );

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        
        // ✅ Merge offers into items
        _allFoodItems = _mergeOffersIntoItems(parsedItems);
        _applyLocalFilters();
      } else {
        _error = response.error ?? 'Search failed';
        _allFoodItems = [];
        _foodItems = [];
      }
    } catch (e) {
      _error = 'Search error: ${e.toString()}';
      _allFoodItems = [];
      _foodItems = [];
      debugPrint('Search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
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
    
    return items
        .map((item) {
          try {
            if (item is FoodItem) {
              return item;
            } else if (item is Map<String, dynamic>) {
              return FoodItem.fromMap(item, currentLanguage: _currentLanguage);
            }
          } catch (e) {
            debugPrint('Error parsing food item: $e');
          }
          return null;
        })
        .whereType<FoodItem>()
        .toList();
  }
}