// lib/features/providers/home_provider.dart - FIXED: Safe search with no validation errors

import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/services/language_service.dart';
import '../../shared/models/food_category.dart';
import '../../shared/models/food_item.dart';
import '../../shared/models/offer.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Main data
  List<FoodCategory> _categories = [];
  List<FoodItem> _featuredItems = [];
  List<FoodItem> _popularItems = [];
  
  // Store items with offers for merging
  List<FoodItemWithOffer> _itemsWithOffers = [];
  
  // Home loading state
  bool _isLoading = false;
  String? _error;
  
  // Search state
  bool _isInSearchMode = false;
  bool _isSearchLoading = false;
  String? _searchError;
  List<FoodItem> _searchResults = [];
  String _lastSearchQuery = '';
  
  // ✅ Search debouncing
  int _searchRequestId = 0;
  
  // Language
  String _currentLanguage = LanguageService.english;
  bool _hasInitialized = false;

  // ==================== GETTERS ====================
  
  List<FoodCategory> get categories => _categories;
  List<FoodItem> get featuredItems => _featuredItems;
  List<FoodItem> get popularItems => _popularItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get isInSearchMode => _isInSearchMode;
  bool get isSearchLoading => _isSearchLoading;
  String? get searchError => _searchError;
  List<FoodItem> get searchResults => _searchResults;
  String get lastSearchQuery => _lastSearchQuery;
  
  String get currentLanguage => _currentLanguage;

  // ==================== INITIALIZATION ====================

  Future<void> initializeIfNeeded(String systemLanguage) async {
    if (_hasInitialized) return;
    
    _currentLanguage = systemLanguage;
    _apiService.setLanguage(systemLanguage);
    _hasInitialized = true;
    
    await loadHomeData();
  }

  void setLanguage(String languageCode) {
    if (_currentLanguage == languageCode) return;
    
    _currentLanguage = languageCode;
    _apiService.setLanguage(languageCode);
    
    if (_isInSearchMode && _lastSearchQuery.isNotEmpty) {
      performSearch(_lastSearchQuery);
    } else {
      loadHomeData();
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
                if (kDebugMode) {
                  print('⚠️ Error parsing offer item: $e');
                }
                return null;
              }
            })
            .whereType<FoodItemWithOffer>()
            .toList();
        
        if (kDebugMode) {
          print('✅ Loaded ${_itemsWithOffers.length} items with offers');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error loading items with offers: $e');
      }
      // Don't throw - continue without offers
      _itemsWithOffers = [];
    }
  }

  // ==================== ✅ FIXED: SAFE MERGE WITH MAP LOOKUP ====================
  
  List<FoodItem> _mergeOffersIntoItems(List<FoodItem> items) {
    // ✅ Return early if no items
    if (items.isEmpty) {
      return items;
    }

    // ✅ Return early if no offers available
    if (_itemsWithOffers.isEmpty) {
      if (kDebugMode) {
        print('⚠️ No offers available for merging');
      }
      return items;
    }

    if (kDebugMode) {
      print('🔄 Merging offers into ${items.length} items...');
    }

    // ✅ Build lookup maps for O(1) access - NO firstWhere!
    final offerMapById = <String, FoodItemWithOffer>{};
    final offerMapByName = <String, FoodItemWithOffer>{};
    
    for (final offerItem in _itemsWithOffers) {
      try {
        // Map by ID
        if (offerItem.id.isNotEmpty) {
          offerMapById[offerItem.id] = offerItem;
        }
        
        // Map by normalized name
        final normalizedName = offerItem.name.toLowerCase().trim();
        if (normalizedName.isNotEmpty) {
          offerMapByName[normalizedName] = offerItem;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error mapping offer item: $e');
        }
      }
    }

    int mergedCount = 0;
    
    // ✅ Safe merge with try-catch for each item
    final mergedItems = items.map((item) {
      try {
        // Try to find offer by ID first
        FoodItemWithOffer? offerItem = offerMapById[item.id];
        
        // If not found by ID, try by name
        if (offerItem == null && item.name.isNotEmpty) {
          final normalizedName = item.name.toLowerCase().trim();
          offerItem = offerMapByName[normalizedName];
        }

        // If we found a matching offer, merge it
        if (offerItem != null && offerItem.offer != null) {
          mergedCount++;
          if (kDebugMode) {
            print('✅ Merged offer for: ${item.name}');
          }
          return item.copyWith(offer: offerItem.offer);
        }

        return item;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error merging offer for ${item.name}: $e');
        }
        // Return original item if merge fails
        return item;
      }
    }).toList();

    if (kDebugMode) {
      print('✅ Merged $mergedCount offers into ${items.length} items');
    }

    return mergedItems;
  }

  // ==================== HOME DATA ====================

  Future<void> loadHomeData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load offers first
      await loadItemsWithOffers();
      
      final results = await Future.wait([
        _fetchCategories(),
        _fetchFeaturedItems(),
        _fetchPopularItems(),
      ]);

      final allSuccess = results.every((success) => success);
      
      if (!allSuccess) {
        _error = 'Some content failed to load';
      }
    } catch (e) {
      _error = 'Failed to load content: ${e.toString()}';
      if (kDebugMode) {
        print('❌ Error loading home data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _fetchCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching categories: $e');
      }
      return false;
    }
  }

  Future<bool> _fetchFeaturedItems() async {
    try {
      if (kDebugMode) {
        print('🌟 Fetching featured items...');
      }
      
      final response = await _apiService.getFoodItems(featured: true, limit: 20);
      
      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        
        if (kDebugMode) {
          print('📦 Parsed ${parsedItems.length} featured items');
        }
        
        // ✅ Safe merge
        _featuredItems = _mergeOffersIntoItems(parsedItems);
        
        if (kDebugMode) {
          final withOffers = _featuredItems.where((item) => item.hasActiveOffer).length;
          print('✅ Featured items loaded: ${_featuredItems.length} ($withOffers with offers)');
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching featured items: $e');
      }
      return false;
    }
  }

  Future<bool> _fetchPopularItems() async {
    try {
      if (kDebugMode) {
        print('🔥 Fetching popular items...');
      }
      
      final response = await _apiService.getFoodItems(popular: true, limit: 20);
      
      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        
        if (kDebugMode) {
          print('📦 Parsed ${parsedItems.length} popular items');
        }
        
        // ✅ Safe merge
        _popularItems = _mergeOffersIntoItems(parsedItems);
        
        if (kDebugMode) {
          final withOffers = _popularItems.where((item) => item.hasActiveOffer).length;
          print('✅ Popular items loaded: ${_popularItems.length} ($withOffers with offers)');
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching popular items: $e');
      }
      return false;
    }
  }

  // ==================== ✅ FIXED: SAFE SEARCH WITH DEDUPLICATION ====================

  Future<void> performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    // Empty query exits search mode
    if (trimmedQuery.isEmpty) {
      exitSearchMode();
      return;
    }

    // ✅ Prevent duplicate searches for same query
    if (_isInSearchMode && 
        _lastSearchQuery == trimmedQuery && 
        !_isSearchLoading &&
        _searchResults.isNotEmpty) {
      if (kDebugMode) {
        print('⏭️ Skipping duplicate search for: $trimmedQuery');
      }
      return;
    }

    // ✅ Increment request ID to handle race conditions
    _searchRequestId++;
    final currentRequestId = _searchRequestId;

    _isInSearchMode = true;
    _isSearchLoading = true;
    _searchError = null;
    _lastSearchQuery = trimmedQuery;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Starting search #$currentRequestId for: "$trimmedQuery"');
      }

      // Load offers first
      await loadItemsWithOffers();
      
      // ✅ Check if this request is still valid
      if (currentRequestId != _searchRequestId) {
        if (kDebugMode) {
          print('⏭️ Search #$currentRequestId cancelled (newer search started)');
        }
        return;
      }
      
      final response = await _apiService.getFoodItems(search: trimmedQuery);
      
      // ✅ Check again after async call
      if (currentRequestId != _searchRequestId) {
        if (kDebugMode) {
          print('⏭️ Search #$currentRequestId results discarded (newer search started)');
        }
        return;
      }
      
      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        
        // ✅ Safe merge
        _searchResults = _mergeOffersIntoItems(parsedItems);
        _searchError = null;
        
        if (kDebugMode) {
          final withOffers = _searchResults.where((item) => item.hasActiveOffer).length;
          print('✅ Search #$currentRequestId complete: ${_searchResults.length} results ($withOffers with offers)');
        }
      } else {
        _searchResults = [];
        _searchError = response.error ?? 'Search failed';
        
        if (kDebugMode) {
          print('⚠️ Search #$currentRequestId failed: $_searchError');
        }
      }
    } catch (e) {
      // ✅ Only update error if this is still the current search
      if (currentRequestId == _searchRequestId) {
        _searchResults = [];
        _searchError = 'Search error: ${e.toString()}';
        
        if (kDebugMode) {
          print('❌ Search #$currentRequestId error: $e');
        }
      }
    } finally {
      // ✅ Only update loading state if this is still the current search
      if (currentRequestId == _searchRequestId) {
        _isSearchLoading = false;
        notifyListeners();
      }
    }
  }

  void exitSearchMode() {
    if (!_isInSearchMode) return;

    // ✅ Increment to cancel any pending searches
    _searchRequestId++;
    
    _isInSearchMode = false;
    _isSearchLoading = false;
    _searchError = null;
    _searchResults = [];
    _lastSearchQuery = '';
    
    if (kDebugMode) {
      print('🚪 Exited search mode');
    }
    
    notifyListeners();
  }

  // ==================== FOOD ITEM DETAILS ====================

  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      final response = await _apiService.getFoodItem(id);
      return response;
    } catch (e) {
      return ApiResponse.error('Error loading food item: $e');
    }
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
          print('⚠️ Error parsing food item: $e');
        }
      }
    }
    
    return parsedItems;
  }
}