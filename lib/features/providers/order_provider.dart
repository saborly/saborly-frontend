import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreOrders = false;
  bool _isLoadingMore = false;

  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreOrders => _hasMoreOrders;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Load orders with pagination
  Future<void> loadOrders({int limit = 50}) async {
    _setLoading(true);
    _setError(null);
    _currentPage = 1; // Reset to first page

    try {
      final response = await _apiService.getOrders(
        page: _currentPage,
        limit: limit,
      );
      
      if (response.isSuccess && response.data != null) {
        _orders = response.data!;
        
        // Update pagination info if available from API
        _totalPages = 1; // Default, update if API provides this
        _hasMoreOrders = _orders.length >= limit;
      } else {
        _setError(response.error ?? 'Failed to load orders');
      }
    } catch (e) {
      _setError('Error loading orders: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMoreOrders({int limit = 50}) async {
    if (_isLoadingMore || !_hasMoreOrders) return;

    _setLoadingMore(true);
    _setError(null);

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.getOrders(
        page: nextPage,
        limit: limit,
      );

      if (response.isSuccess && response.data != null) {
        final newOrders = response.data!;
        
        if (newOrders.isNotEmpty) {
          _orders.addAll(newOrders);
          _currentPage = nextPage;
          _hasMoreOrders = newOrders.length >= limit;
        } else {
          _hasMoreOrders = false;
        }
      } else {
        _setError(response.error ?? 'Failed to load more orders');
      }
    } catch (e) {
      _setError('Error loading more orders: ${e.toString()}');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Load single order with optional silent mode for background polling
  Future<void> loadOrder(String orderId, {bool silent = false}) async {
    if (!silent) {
      _setLoading(true);
      _setError(null);
    }

    try {
      final response = await _apiService.getOrder(orderId);
      if (response.isSuccess && response.data != null) {
        final newOrder = response.data!;
        
        // Check if order actually changed before updating
        final hasChanged = _currentOrder == null || 
                          _currentOrder!.status != newOrder.status ||
                          _currentOrder!.updatedAt != newOrder.updatedAt;
        
        if (hasChanged) {
          _currentOrder = newOrder;
          
          // Also update in orders list if it exists
          final index = _orders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            _orders[index] = newOrder;
          }
          
        
          notifyListeners();
        }
      } else {
        if (!silent) {
          _setError(response.error ?? 'Order not found');
        }
      }
    } catch (e) {
      if (!silent) {
        _setError('Error loading order: ${e.toString()}');
      }
  
    } finally {
      if (!silent) {
        _setLoading(false);
      }
    }
  }

  Future<bool> createOrder({
    required List<CartItem> items,
    required String branchId,
    DeliveryAddress? deliveryAddress,
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
    CodPaymentType? codPaymentType,
    required double deliveryFee,
    String? specialInstructions,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = 0.0;
      final discount = 0.0;
      final total = subtotal + deliveryFee + tax - discount;

      final orderData = {
        'items': items.map((item) => item.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'tax': tax,
        'discount': discount,
        'total': total,
        'deliveryType': deliveryType.name,
        'paymentMethod': paymentMethod.name,
        'paymentStatus': PaymentStatus.pending.name,
        'branchId': branchId,
        'specialInstructions': specialInstructions,
        'estimatedDeliveryTime': DateTime.now()
            .add(const Duration(minutes: 40))
            .toIso8601String(),
        
        // Only include deliveryAddress for delivery orders
        if (deliveryType == DeliveryType.delivery && deliveryAddress != null)
          'deliveryAddress': deliveryAddress.toMap(),
        
        // Only include codPaymentType for cash-on-delivery orders
        if (paymentMethod == PaymentMethod.cashOnDelivery && codPaymentType != null)
          'codPaymentType': codPaymentType.name,
      };

      final response = await _apiService.createOrder(orderData);

      if (response.isSuccess && response.data != null) {
        _currentOrder = response.data!;
        // Add new order to the beginning of the list
        _orders.insert(0, response.data!);
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to create order');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error creating order: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Reset pagination state
  void resetPagination() {
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreOrders = false;
    _orders.clear();
    notifyListeners();
  }

  /// Manually update current order status (useful for FCM notifications)
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    if (_currentOrder != null && _currentOrder!.id == orderId) {
      _currentOrder = _currentOrder!.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      
  
    }

    // Also update in orders list
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}