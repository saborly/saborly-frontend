// lib/features/providers/home_provider.dart - FIXED with search state reset

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/language_service.dart';
import '../../shared/models/food_category.dart';
import '../../shared/models/food_item.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FoodCategory> _categories = [];
  List<FoodItem> _featuredItems = [];
  List<FoodItem> _popularItems = [];
  bool _isLoading = false;
  String? _error;
  String _currentLanguage = LanguageService.english;
  bool _hasInitialized = false;
  bool _isSearchMode = false; // ✅ Track if in search mode
  String _lastSearchQuery = ''; // ✅ Track last search query

  // Getters
  List<FoodCategory> get categories => _categories;
  List<FoodItem> get featuredItems => _featuredItems;
  List<FoodItem> get popularItems => _popularItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentLanguage => _currentLanguage;
  bool get isSearchMode => _isSearchMode; // ✅ Expose search mode
  String get lastSearchQuery => _lastSearchQuery; // ✅ Expose last query

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// ✅ CRITICAL: Initialize with current language on first creation
  Future<void> initializeIfNeeded(String systemLanguage) async {
    if (!_hasInitialized) {
      _currentLanguage = systemLanguage;
      _apiService.setLanguage(systemLanguage);
      _hasInitialized = true;
      await loadData();
    }
  }

  /// ✅ CRITICAL: Update language and reload data with proper parsing
  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _apiService.setLanguage(languageCode);
      
      // If in search mode, re-run the search with new language
      if (_isSearchMode && _lastSearchQuery.isNotEmpty) {
        searchFoodItems(_lastSearchQuery);
      } else {
        loadData();
      }
    }
  }

  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      final response = await _apiService.getFoodItem(id);
      if (response.isSuccess && response.data != null) {
        return response;
      } else {
        return ApiResponse.error('Failed to load food item: ${response.error}');
      }
    } catch (e) {
      return ApiResponse.error('Error loading food item: $e');
    }
  }

  /// ✅ NEW: Reset search state and reload original data
  Future<void> resetSearch() async {
    _isSearchMode = false;
    _lastSearchQuery = '';
    await loadData();
  }

  Future<void> loadData() async {
    _setLoading(true);
    _setError(null);
    _isSearchMode = false; // ✅ Clear search mode
    _lastSearchQuery = ''; // ✅ Clear search query

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _loadCategories(),
        _loadFeaturedItems(),
        _loadPopularItems(),
      ]);

      final categoriesSuccess = results[0] as bool;
      final featuredSuccess = results[1] as bool;
      final popularSuccess = results[2] as bool;

      if (!categoriesSuccess || !featuredSuccess || !popularSuccess) {
        _setError('Some data could not be loaded');
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _loadFeaturedItems() async {
    try {
      final response = await _apiService.getFoodItems(featured: true, limit: 20);
      if (response.isSuccess && response.data != null) {
        _featuredItems = (response.data as List)
            .map((item) {
              if (item is FoodItem) {
                return item;
              } else if (item is Map<String, dynamic>) {
                return FoodItem.fromMap(item, currentLanguage: _currentLanguage);
              }
              return null;
            })
            .whereType<FoodItem>()
            .toList();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _loadPopularItems() async {
    try {
      final response = await _apiService.getFoodItems(popular: true, limit: 20);
      if (response.isSuccess && response.data != null) {
        _popularItems = (response.data as List)
            .map((item) {
              if (item is FoodItem) {
                return item;
              } else if (item is Map<String, dynamic>) {
                return FoodItem.fromMap(item, currentLanguage: _currentLanguage);
              }
              return null;
            })
            .whereType<FoodItem>()
            .toList();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> searchFoodItems(String query) async {
    if (query.isEmpty) {
      await resetSearch(); // ✅ Use resetSearch instead of loadData
      return;
    }

    _isSearchMode = true; // ✅ Set search mode
    _lastSearchQuery = query; // ✅ Store search query
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getFoodItems(search: query);
      if (response.isSuccess && response.data != null) {
        final parsedItems = (response.data as List)
            .map((item) {
              if (item is FoodItem) {
                return item;
              } else if (item is Map<String, dynamic>) {
                return FoodItem.fromMap(item, currentLanguage: _currentLanguage);
              }
              return null;
            })
            .whereType<FoodItem>()
            .toList();

        _featuredItems = parsedItems;
        _popularItems = parsedItems;
        notifyListeners();
      } else {
        _setError('Search failed: ${response.error}');
      }
    } catch (e) {
      _setError('Search error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}