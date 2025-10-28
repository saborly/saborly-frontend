// lib/features/providers/home_provider.dart - PROFESSIONAL IMPLEMENTATION

import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/services/language_service.dart';
import '../../shared/models/food_category.dart';
import '../../shared/models/food_item.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Main data
  List<FoodCategory> _categories = [];
  List<FoodItem> _featuredItems = [];
  List<FoodItem> _popularItems = [];
  
  // Home loading state
  bool _isLoading = false;
  String? _error;
  
  // Search state
  bool _isInSearchMode = false;
  bool _isSearchLoading = false;
  String? _searchError;
  List<FoodItem> _searchResults = [];
  String _lastSearchQuery = '';
  
  // Language
  String _currentLanguage = LanguageService.english;
  bool _hasInitialized = false;

  // ==================== GETTERS ====================
  
  // Main data
  List<FoodCategory> get categories => _categories;
  List<FoodItem> get featuredItems => _featuredItems;
  List<FoodItem> get popularItems => _popularItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Search
  bool get isInSearchMode => _isInSearchMode;
  bool get isSearchLoading => _isSearchLoading;
  String? get searchError => _searchError;
  List<FoodItem> get searchResults => _searchResults;
  String get lastSearchQuery => _lastSearchQuery;
  
  // Language
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
    
    // Reload appropriate data
    if (_isInSearchMode && _lastSearchQuery.isNotEmpty) {
      performSearch(_lastSearchQuery);
    } else {
      loadHomeData();
    }
  }

  // ==================== HOME DATA ====================

  Future<void> loadHomeData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return false;
    }
  }

  Future<bool> _fetchFeaturedItems() async {
    try {
      final response = await _apiService.getFoodItems(featured: true, limit: 20);
      if (response.isSuccess && response.data != null) {
        _featuredItems = _parseFoodItems(response.data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching featured items: $e');
      return false;
    }
  }

  Future<bool> _fetchPopularItems() async {
    try {
      final response = await _apiService.getFoodItems(popular: true, limit: 20);
      if (response.isSuccess && response.data != null) {
        _popularItems = _parseFoodItems(response.data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching popular items: $e');
      return false;
    }
  }

  // ==================== SEARCH ====================

  Future<void> performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    // Prevent duplicate searches
    if (_isInSearchMode && 
        _lastSearchQuery == trimmedQuery && 
        !_isSearchLoading) {
      return;
    }

    // Empty query exits search mode
    if (trimmedQuery.isEmpty) {
      exitSearchMode();
      return;
    }

    // Prevent concurrent searches
    if (_isSearchLoading) return;

    _isInSearchMode = true;
    _isSearchLoading = true;
    _searchError = null;
    _lastSearchQuery = trimmedQuery;
    notifyListeners();

    try {
      final response = await _apiService.getFoodItems(search: trimmedQuery);
      
      if (response.isSuccess && response.data != null) {
        _searchResults = _parseFoodItems(response.data);
        _searchError = null;
      } else {
        _searchResults = [];
        _searchError = response.error ?? 'Search failed';
      }
    } catch (e) {
      _searchResults = [];
      _searchError = 'Search error: ${e.toString()}';
      debugPrint('Search error: $e');
    } finally {
      _isSearchLoading = false;
      notifyListeners();
    }
  }

  void exitSearchMode() {
    if (!_isInSearchMode) return;

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