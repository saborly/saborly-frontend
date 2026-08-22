// lib/features/providers/home_provider.dart - OPTIMIZED FOR SPEED

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  // ✅ Cache offers and lookup maps
  List<FoodItemWithOffer> _itemsWithOffers = [];
  Map<String, FoodItemWithOffer>? _cachedOfferMapById;
  Map<String, FoodItemWithOffer>? _cachedOfferMapByName;
  bool _offersLoaded = false;
  
  // Home loading state
  bool _isLoading = false;
  String? _error;
  
  // Search state
  bool _isInSearchMode = false;
  bool _isSearchLoading = false;
  String? _searchError;
  List<FoodItem> _searchResults = [];
  String _lastSearchQuery = '';
  
  // Search debouncing
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
  bool get hasInitialized => _hasInitialized;

  // ==================== INITIALIZATION ====================

  Future<void> initializeIfNeeded(String systemLanguage) async {
    if (_hasInitialized) return;

    _currentLanguage = systemLanguage;
    _apiService.setLanguage(systemLanguage);
    _hasInitialized = true;

    // ✅ Stale-while-revalidate: paint instantly from last session's data
    // (persisted on disk) while the real network fetch runs underneath —
    // this is what actually removes the loading spinner on every visit
    // (cold start / web reload), not just repeat navigation.
    await _hydrateFromDiskCache();

    await loadHomeData();
  }

  void setLanguage(String languageCode) {
    if (_currentLanguage == languageCode) return;
    
    _currentLanguage = languageCode;
    _apiService.setLanguage(languageCode);
    
    // ✅ Invalidate offer cache on language change
    _invalidateOfferCache();
    
    if (_isInSearchMode && _lastSearchQuery.isNotEmpty) {
      performSearch(_lastSearchQuery);
    } else {
      // Paint instantly with this language's last cached snapshot (if any)
      // while the fresh fetch for the new language runs underneath.
      _hydrateFromDiskCache().then((_) => loadHomeData());
    }
  }

  // ==================== ✅ OPTIMIZED: LOAD & CACHE OFFERS ONCE ====================
  
  Future<void> loadItemsWithOffers() async {
    // ✅ Return immediately if already loaded
    if (_offersLoaded && _itemsWithOffers.isNotEmpty) {
      return;
    }

    try {
      final response = await _apiService.dio.get(
        '/offer/items-with-offers',
        queryParameters: {'lang': _currentLanguage},
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
        
        // ✅ Build lookup maps once
        _buildOfferLookupMaps();
        _offersLoaded = true;
      }
    } catch (e) {
      _itemsWithOffers = [];
      _offersLoaded = false;
    }
  }

  // ✅ Build lookup maps once and cache them
  void _buildOfferLookupMaps() {
    _cachedOfferMapById = {};
    _cachedOfferMapByName = {};
    
    for (final offerItem in _itemsWithOffers) {
      try {
        if (offerItem.id.isNotEmpty) {
          _cachedOfferMapById![offerItem.id] = offerItem;
        }
        
        final normalizedName = offerItem.name.toLowerCase().trim();
        if (normalizedName.isNotEmpty) {
          _cachedOfferMapByName![normalizedName] = offerItem;
        }
      } catch (e) {
        // Skip invalid items
      }
    }
  }

  // ✅ Invalidate cache when language changes
  void _invalidateOfferCache() {
    _offersLoaded = false;
    _cachedOfferMapById = null;
    _cachedOfferMapByName = null;
  }

  // ==================== ✅ ULTRA-FAST MERGE WITH CACHED MAPS ====================
  
  List<FoodItem> _mergeOffersIntoItems(List<FoodItem> items) {
    if (items.isEmpty || _cachedOfferMapById == null) {
      return items;
    }

    int mergedCount = 0;
    
    // ✅ Use cached maps for O(1) lookups
    final mergedItems = items.map((item) {
      try {
        FoodItemWithOffer? offerItem = _cachedOfferMapById![item.id];
        
        if (offerItem == null && item.name.isNotEmpty) {
          final normalizedName = item.name.toLowerCase().trim();
          offerItem = _cachedOfferMapByName![normalizedName];
        }

        if (offerItem != null && offerItem.offer != null) {
          mergedCount++;
          return item.copyWith(offer: offerItem.offer);
        }

        return item;
      } catch (e) {
        return item;
      }
    }).toList();

    return mergedItems;
  }

  // ==================== ✅ OPTIMIZED: LOAD HOME DATA ====================

  Future<void> loadHomeData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ Load offers ONCE at the start
      await loadItemsWithOffers();
      
      // ✅ Fetch all data in parallel
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
        _saveCategoriesToDisk(_categories);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _fetchFeaturedItems() async {
    try {
      final response = await _apiService.getFoodItems(featured: true, limit: 20);

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        _featuredItems = _mergeOffersIntoItems(parsedItems);
        _saveFoodItemsToDisk(_diskKeyFeatured, parsedItems);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _fetchPopularItems() async {
    try {
      final response = await _apiService.getFoodItems(popular: true, limit: 20);

      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        _popularItems = _mergeOffersIntoItems(parsedItems);
        _saveFoodItemsToDisk(_diskKeyPopular, parsedItems);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== ✅ PERSISTENT DISK CACHE (stale-while-revalidate) ====================
  //
  // The Dio-level response cache in ApiService only lives in memory, so it's
  // gone on every cold start / web page reload — the exact moments the home
  // screen felt slowest. This mirrors the same JSON to disk so the *next*
  // app launch can paint instantly with last session's data while a fresh
  // network fetch quietly replaces it underneath (offers are intentionally
  // excluded — they change often and are cheap to wait for).

  String get _diskKeyCategories => 'home_cache_v1_categories_$_currentLanguage';
  String get _diskKeyFeatured => 'home_cache_v1_featured_$_currentLanguage';
  String get _diskKeyPopular => 'home_cache_v1_popular_$_currentLanguage';

  Future<void> _saveCategoriesToDisk(List<FoodCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(categories.map((c) => c.toMap()).toList());
      await prefs.setString(_diskKeyCategories, encoded);
    } catch (_) {
      // Disk cache is a best-effort optimization — never let it break loading.
    }
  }

  Future<void> _saveFoodItemsToDisk(String key, List<FoodItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.map((i) => i.toMap()).toList());
      await prefs.setString(key, encoded);
    } catch (_) {
      // Best-effort — ignore.
    }
  }

  Future<void> _hydrateFromDiskCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final categoriesJson = prefs.getString(_diskKeyCategories);
      if (categoriesJson != null) {
        final decoded = jsonDecode(categoriesJson) as List;
        _categories = decoded
            .map((m) => FoodCategory.fromMap(m as Map<String, dynamic>))
            .toList();
      }

      final featuredJson = prefs.getString(_diskKeyFeatured);
      if (featuredJson != null) {
        final decoded = jsonDecode(featuredJson) as List;
        _featuredItems = decoded
            .map((m) => FoodItem.fromMap(m as Map<String, dynamic>))
            .toList();
      }

      final popularJson = prefs.getString(_diskKeyPopular);
      if (popularJson != null) {
        final decoded = jsonDecode(popularJson) as List;
        _popularItems = decoded
            .map((m) => FoodItem.fromMap(m as Map<String, dynamic>))
            .toList();
      }

      if (categoriesJson != null || featuredJson != null || popularJson != null) {
        notifyListeners();
      }
    } catch (_) {
      // Corrupt/missing cache — fall through to the normal network load.
    }
  }

  // ==================== ✅ OPTIMIZED: FAST SEARCH ====================

  Future<void> performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      exitSearchMode();
      return;
    }

    // ✅ Prevent duplicate searches
    if (_isInSearchMode && 
        _lastSearchQuery == trimmedQuery && 
        !_isSearchLoading &&
        _searchResults.isNotEmpty) {
      return;
    }

    _searchRequestId++;
    final currentRequestId = _searchRequestId;

    _isInSearchMode = true;
    _isSearchLoading = true;
    _searchError = null;
    _lastSearchQuery = trimmedQuery;
    notifyListeners();

    try {
      // ✅ Ensure offers are loaded (uses cache if already loaded)
      await loadItemsWithOffers();
      
      if (currentRequestId != _searchRequestId) return;
      
      final response = await _apiService.getFoodItems(search: trimmedQuery);
      
      if (currentRequestId != _searchRequestId) return;
      
      if (response.isSuccess && response.data != null) {
        final parsedItems = _parseFoodItems(response.data);
        _searchResults = _mergeOffersIntoItems(parsedItems);
        _searchError = null;
      } else {
        _searchResults = [];
        _searchError = response.error ?? 'Search failed';
      }
    } catch (e) {
      if (currentRequestId == _searchRequestId) {
        _searchResults = [];
        _searchError = 'Search error: ${e.toString()}';
      }
    } finally {
      if (currentRequestId == _searchRequestId) {
        _isSearchLoading = false;
        notifyListeners();
      }
    }
  }

  void exitSearchMode() {
    if (!_isInSearchMode) return;

    _searchRequestId++;
    
    _isInSearchMode = false;
    _isSearchLoading = false;
    _searchError = null;
    _searchResults = [];
    _lastSearchQuery = '';
    
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
        // Skip invalid items
      }
    }
    
    return parsedItems;
  }
}
