import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/food_category.dart';
import '../../../shared/models/food_item.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FoodCategory> _categories = [];
  List<FoodItem> _foodItems = [];
  List<FoodItem> _allFoodItems = [];
  bool _isLoading = false;
  String? _error;
  bool _showVegOnly = false;
  bool _showNonVegOnly = false;
  bool _showPopularOnly = false;
  String _searchQuery = '';
  String _sortBy = 'name';
  String _currentLanguage = 'es';

  List<FoodCategory> get categories => _categories;
  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showVegOnly => _showVegOnly;
  bool get showNonVegOnly => _showNonVegOnly;
  bool get showPopularOnly => _showPopularOnly;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get currentLanguage => _currentLanguage;

  void setVegFilter(bool value) {
    _showVegOnly = value;
    if (_showVegOnly) _showNonVegOnly = false;
    _applyFilters();
  }

  void setNonVegFilter(bool value) {
    _showNonVegOnly = value;
    if (_showNonVegOnly) _showVegOnly = false;
    _applyFilters();
  }

  void setPopularFilter(bool value) {
    _showPopularOnly = value;
    _applyFilters();
  }

  void setSortBy(String value) {
    _sortBy = value;
    _applyFilters();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// ✅ CRITICAL: Update language and reload data
  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _apiService.setLanguage(languageCode);
      // Reload both categories and items
      loadCategories();
      loadFoodItems();
    }
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    _setError(null);

    try {
     

      final response = await _apiService.getCategories();
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
       
      } else {
        _setError(response.error ?? 'Failed to load categories');
        _loadMockCategories();
      }
    } catch (e) {
      _setError('Error loading categories: ${e.toString()}');
      _loadMockCategories();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFoodItems({String? categoryId}) async {
    _setLoading(true);
    _setError(null);

    try {
     

      final response = await _apiService.getFoodItems(
        categoryId: categoryId,
        limit: 50,
      );

      if (response.isSuccess && response.data != null) {
        _allFoodItems = response.data!;
  
        _applyFilters();
      } else {
        _setError(response.error ?? 'Failed to load food items');
        _loadMockFoodItems();
      }
    } catch (e) {
      _setError('Error loading food items: ${e.toString()}');
      _loadMockFoodItems();
    } finally {
      _setLoading(false);
    }
  }

  void searchFoodItems(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _showVegOnly = false;
    _showNonVegOnly = false;
    _showPopularOnly = false;
    _searchQuery = '';
    _sortBy = 'name';
    _applyFilters();
  }

  void _applyFilters() {
    List<FoodItem> filteredItems = List.from(_allFoodItems);

    if (_showVegOnly) {
      filteredItems = filteredItems.where((item) => item.isVeg).toList();
    } else if (_showNonVegOnly) {
      filteredItems = filteredItems.where((item) => !item.isVeg).toList();
    }

    if (_showPopularOnly) {
      filteredItems = filteredItems.where((item) => item.isPopular).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    switch (_sortBy) {
      case 'name':
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filteredItems.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    _foodItems = filteredItems;
    notifyListeners();
  }

  void _loadMockFoodItems() {
    _allFoodItems = [];
    _applyFilters();
  }

  void _loadMockCategories() {
    _categories = [];
    notifyListeners();
  }
}