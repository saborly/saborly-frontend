import 'package:flutter/foundation.dart';
import 'dart:math' show cos, sqrt, asin;
import '../../../core/services/api_service.dart';
import '../../../shared/models/branch.dart';
import '../../../shared/models/order.dart';
import 'cart_provider.dart'; // Add this import

class CheckoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  CartProvider? _cartProvider; // Add this
  
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  DeliveryAddress? _selectedAddress;
  List<DeliveryAddress> _savedAddresses = [];
  DeliveryType _deliveryType = DeliveryType.pickup;
  DateTime? _selectedDeliveryDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;
  double? _deliveryDistance;
  double? _deliveryFee;

  // Shop coordinates (Saborly-Burgers, Barcelona)
  static const double shopLat = 41.3995;
  static const double shopLng = 2.1909;
  static const double maxDeliveryDistance = 6.0; // km

  // Add this method to inject CartProvider
  void setCartProvider(CartProvider cartProvider) {
    _cartProvider = cartProvider;
  }

  // Getters
  List<Branch> get branches => _branches;
  Branch? get selectedBranch => _selectedBranch;
  DeliveryAddress? get selectedAddress => _selectedAddress;
  List<DeliveryAddress> get savedAddresses => _savedAddresses;
  DeliveryType get deliveryType => _deliveryType;
  DateTime? get selectedDeliveryDate => _selectedDeliveryDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get deliveryDistance => _deliveryDistance;
  double? get deliveryFee => _deliveryFee;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Helper method to update delivery fee in both providers
  void _updateDeliveryFee(double? fee) {
    _deliveryFee = fee;
    if (_cartProvider != null && fee != null) {
      _cartProvider!.setDeliveryFee(fee);
    }
    notifyListeners();
  }

  // Calculate distance using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Calculate delivery fee based on distance and order total
  double? calculateDeliveryFee(double orderTotal) {
    if (_deliveryType == DeliveryType.pickup || _selectedAddress == null) {
      return 0.0;
    }

    if (_deliveryDistance == null) return null;

    final distance = _deliveryDistance!;

    // Don't allow delivery beyond 6km
    if (distance > maxDeliveryDistance) {
      return null;
    }

    // Within 3km: Free if order >= €20, else €3.50
    if (distance <= 3) {
      return orderTotal >= 20 ? 0.0 : 3.5;
    }
    // Within 5km: €10.00
    else if (distance <= 5) {
      return 10.0;
    }
    // Within 6km: €12.00
    else {
      return 12.0;
    }
  }

  Future<void> loadBranches() async {
    _setLoading(true);
    _setError(null);

    try {
      // Fallback to default branch
      _branches = [
        Branch(
          id: '1',
          name: 'Saborly-Burgers',
          address: 'Carrer de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
          phone: '+34 932112072',
          latitude: shopLat,
          longitude: shopLng,
          isActive: true,
        ),
      ];

      if (_branches.isNotEmpty) {
        _selectedBranch = _branches.first;
      }
    } catch (e) {
      _setError('Failed to load branches: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSavedAddresses() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getSavedAddresses();
      
      if (response.isSuccess && response.data != null) {
        _savedAddresses = response.data!;
      } else {
        _savedAddresses = [];
      }
    } catch (e) {
      _setError('Failed to load addresses: ${e.toString()}');
      _savedAddresses = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveAddress(DeliveryAddress address) async {
    try {
      final response = await _apiService.saveAddress(address.toMap());
      
      if (response.isSuccess && response.data != null) {
        final existingIndex = _savedAddresses.indexWhere((a) => a.id == response.data!.id);
        if (existingIndex >= 0) {
          _savedAddresses[existingIndex] = response.data!;
        } else {
          _savedAddresses.add(response.data!);
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to save address');
        return false;
      }
    } catch (e) {
      _setError('Error saving address: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      final response = await _apiService.deleteAddress(addressId);
      
      if (response.isSuccess) {
        _savedAddresses.removeWhere((a) => a.id == addressId);
        
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = null;
          _deliveryDistance = null;
          _updateDeliveryFee(null);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete address');
        return false;
      }
    } catch (e) {
      _setError('Error deleting address: ${e.toString()}');
      return false;
    }
  }

  void selectBranch(Branch branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  Future<void> selectAddress(DeliveryAddress address, {double? orderTotal}) async {
    _selectedAddress = address;
    
    if (address.latitude != null && address.longitude != null) {
      _deliveryDistance = _calculateDistance(
        shopLat,
        shopLng,
        address.latitude!,
        address.longitude!,
      );
      
      if (orderTotal != null) {
        final fee = calculateDeliveryFee(orderTotal);
        _updateDeliveryFee(fee);
      }
    } else {
      _deliveryDistance = null;
      _updateDeliveryFee(null);
    }
    
    notifyListeners();
  }

  void setDeliveryType(DeliveryType type) {
    _deliveryType = type;
    
    // Reset delivery-related fields when switching to pickup
    if (type == DeliveryType.pickup) {
      _deliveryDistance = null;
      _updateDeliveryFee(0.0);
    } else if (type == DeliveryType.delivery && _selectedAddress != null && _cartProvider != null) {
      // Recalculate delivery fee when switching to delivery
      final fee = calculateDeliveryFee(_cartProvider!.subtotal);
      _updateDeliveryFee(fee);
    }
    
    notifyListeners();
  }

  void setDeliveryDate(DateTime date) {
    _selectedDeliveryDate = date;
    notifyListeners();
  }

  void setTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  void updateDeliveryFee(double orderTotal) {
    if (_deliveryType == DeliveryType.delivery && _selectedAddress != null) {
      final fee = calculateDeliveryFee(orderTotal);
      _updateDeliveryFee(fee);
    } else if (_deliveryType == DeliveryType.pickup) {
      _updateDeliveryFee(0.0);
    }
  }

  bool get isReadyForOrder {
    if (_deliveryType == DeliveryType.pickup) {
      return _selectedBranch != null;
    } else {
      return _selectedBranch != null && 
             _selectedAddress != null && 
             canDeliver;
    }
  }

  bool get canDeliver {
    return _deliveryDistance != null && _deliveryDistance! <= maxDeliveryDistance;
  }

  String? getDeliveryDistanceText() {
    if (_deliveryDistance == null) return null;
    return '${_deliveryDistance!.toStringAsFixed(1)} km';
  }

  String? getDeliveryFeeText() {
    if (_deliveryFee == null) return null;
    if (_deliveryFee == 0.0) return 'Free';
    return '€${_deliveryFee!.toStringAsFixed(2)}';
  }

  void clearAddress() {
    _selectedAddress = null;
    _deliveryDistance = null;
    _updateDeliveryFee(null);
    notifyListeners();
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final response = await _apiService.setDefaultAddress(addressId);
      
      if (response.isSuccess && response.data != null) {
        for (var address in _savedAddresses) {
          address.isDefault = address.id == addressId;
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to set default address');
        return false;
      }
    } catch (e) {
      _setError('Error setting default address: ${e.toString()}');
      return false;
    }
  }

  void reset() {
    _selectedAddress = null;
    _deliveryDistance = null;
    _updateDeliveryFee(null);
    _deliveryType = DeliveryType.pickup;
    _selectedDeliveryDate = null;
    _selectedTimeSlot = null;
    _error = null;
    notifyListeners();
  }
}