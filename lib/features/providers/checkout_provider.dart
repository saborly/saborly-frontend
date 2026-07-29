import 'package:Saborly/core/utils/time_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:math' show cos, sqrt, asin;
import '../../../core/services/api_service.dart';
import '../../../shared/models/branch.dart';
import '../../../shared/models/order.dart';
import 'cart_provider.dart';

class CheckoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  CartProvider? _cartProvider;
  
  // ✅ NEW: Track delivery availability
  bool _isDeliveryEnabled = true;
  String? _deliveryDisabledMessage;
  
  bool get isDeliveryEnabled => _isDeliveryEnabled;
  String? get deliveryDisabledMessage => _deliveryDisabledMessage;

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

  // Fallback to Barcelona; overwritten by loadCurrentBranchCoords()
  double _shopLat = 41.3995;
  double _shopLng = 2.1909;
  static const double maxDeliveryDistance = 3.5;

  // Keep static getters so call-sites that use CheckoutProvider.shopLat still compile
  double get shopLat => _shopLat;
  double get shopLng => _shopLng;
  bool _isRestaurantOpen = true;
  String? _restaurantClosedMessage;
  
  bool get isRestaurantOpen => _isRestaurantOpen;
  String? get restaurantClosedMessage => _restaurantClosedMessage;

  // ✅ NEW: Check if orders are allowed (both delivery enabled AND restaurant open)
  bool get canPlaceOrder => _isDeliveryEnabled && _isRestaurantOpen;
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

  void setCartProvider(CartProvider cartProvider) {
    _cartProvider = cartProvider;
    if (_deliveryType == DeliveryType.delivery && _selectedAddress != null) {
      _recalculateDeliveryFee();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _updateDeliveryFee(double? fee) {
    _deliveryFee = fee;
    if (_cartProvider != null && fee != null) {
      _cartProvider!.setDeliveryFee(fee);
    }
    notifyListeners();
  }

  void _recalculateDeliveryFee() {
    if (_cartProvider != null && _selectedAddress != null && _deliveryType == DeliveryType.delivery) {
      if (_selectedAddress!.latitude != null && _selectedAddress!.longitude != null) {
        _deliveryDistance = _calculateDistance(
          shopLat,
          shopLng,
          _selectedAddress!.latitude!,
          _selectedAddress!.longitude!,
        );
      }
      
      final fee = calculateDeliveryFee(_cartProvider!.subtotal);
      _updateDeliveryFee(fee);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double? calculateDeliveryFee(double orderTotal) {
    if (_deliveryType == DeliveryType.pickup || _selectedAddress == null) {
      return 0.0;
    }

    if (_deliveryDistance == null) return null;

    final distance = _deliveryDistance!;

    if (distance > maxDeliveryDistance) {
      return null;
    }

    if (distance <= 3.5) {
      return orderTotal >= 20 ? 0.0 : 3.5;
    } 
  }

Future<void> checkDeliveryAvailability() async {
    // Check restaurant hours first
    _checkRestaurantHours();
    
    // Then check delivery settings from backend
    try {
      final response = await _apiService.getPublicSettings();
      
      if (response.isSuccess && response.data != null) {
        final settings = response.data!;
        _isDeliveryEnabled = settings.deliverySettings?.isDeliveryEnabled ?? true;
        _deliveryDisabledMessage = settings.deliverySettings?.disabledMessage;
        
        // If delivery is disabled and currently selected, switch to pickup
        if (!_isDeliveryEnabled && _deliveryType == DeliveryType.delivery) {
          _deliveryType = DeliveryType.pickup;
          _deliveryFee = 0;
        }
        
        notifyListeners();
      }
    } catch (e) {
      // Default to enabled on error
      _isDeliveryEnabled = true;
    }
  }

  // ✅ NEW: Check restaurant operating hours
  void _checkRestaurantHours() {
    _isRestaurantOpen = TimeUtils.isRestaurantOpen();
    
    if (!_isRestaurantOpen) {
      final nextOpening = TimeUtils.getNextOpeningTime();
      if (nextOpening != null) {
        final formatter = DateFormat('EEEE \'at\' h:mm a');
        final spainTime = TimeUtils.getSpainTime();
        
        if (nextOpening.day == spainTime.day) {
          // Opening today
          final timeFormatter = DateFormat('h:mm a');
          _restaurantClosedMessage = 
            'We\'re currently closed. We open today at ${timeFormatter.format(nextOpening)}';
        } else if (nextOpening.day == spainTime.day + 1) {
          // Opening tomorrow
          final timeFormatter = DateFormat('h:mm a');
          _restaurantClosedMessage = 
            'We\'re currently closed. We open tomorrow at ${timeFormatter.format(nextOpening)}';
        } else {
          // Opening later
          _restaurantClosedMessage = 
            'We\'re currently closed. We open on ${formatter.format(nextOpening)}';
        }
      } else {
        _restaurantClosedMessage = 'We\'re currently closed. Please check back later.';
      }
    } else {
      _restaurantClosedMessage = null;
    }
  }

  // ✅ NEW: Periodic check for restaurant hours (call this in initState)
  void startHoursMonitoring() {
    // Check immediately
    _checkRestaurantHours();
    
    // Check every minute
    Future.delayed(Duration(minutes: 1), () {
      if (!_disposed) {
        _checkRestaurantHours();
        startHoursMonitoring();
      }
    });
  }

  bool _disposed = false;
  // ✅ UPDATED: Modified setDeliveryType to check if delivery is enabled
  void setDeliveryType(DeliveryType type) {
    // CRITICAL: Prevent setting delivery if it's disabled
    if (type == DeliveryType.delivery && !_isDeliveryEnabled) {
      // Don't call notifyListeners() - no state change should occur
      return;
    }
    
    _deliveryType = type;
    
    if (type == DeliveryType.pickup) {
      _deliveryFee = 0;
      clearAddress();
    } else if (_cartProvider != null) {
      updateDeliveryFee(_cartProvider!.subtotal);
    }
    
    notifyListeners();
  }

  Future<void> loadBranches() async {
    _setLoading(true);
    _setError(null);

    try {
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

  /// Fetches the active branch from the API and updates shop coordinates.
  Future<void> loadCurrentBranchCoords() async {
    try {
      final branchId = _apiService.branchId;
      if (branchId == null || branchId.isEmpty) return;
      final res = await _apiService.dio.get('/branches/public');
      final raw = (res.data['branches'] as List<dynamic>? ?? []);
      final match = raw.cast<Map<String, dynamic>>().firstWhere(
        (b) => '${b['_id']}' == branchId,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        final lat = (match['latitude'] as num?)?.toDouble();
        final lng = (match['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          _shopLat = lat;
          _shopLng = lng;
        }
      }
    } catch (_) {}
  }

  Future<void> loadSavedAddresses() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getSavedAddresses();
      
      if (response.isSuccess && response.data != null) {
        _savedAddresses = response.data!;
        
        if (_selectedAddress != null) {
          final updatedAddress = _savedAddresses.firstWhere(
            (addr) => addr.id == _selectedAddress!.id,
            orElse: () => _selectedAddress!,
          );
          
          if (updatedAddress.latitude != null && updatedAddress.longitude != null) {
            _selectedAddress = updatedAddress;
            _recalculateDeliveryFee();
          }
        }
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
      
      final total = orderTotal ?? _cartProvider?.subtotal ?? 0.0;
      final fee = calculateDeliveryFee(total);
      _updateDeliveryFee(fee);
    } else {
      _deliveryDistance = null;
      _updateDeliveryFee(null);
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

  /// Prefills the delivery address with the location detected/selected on
  /// the branch-selection screen, so checkout only needs apartment/instructions.
  void seedFromDetectedLocation() {
    if (_selectedAddress != null) return; // don't override a real choice
    final lat = _apiService.selectedLat;
    final lng = _apiService.selectedLng;
    if (lat == null || lng == null) return;

    selectAddress(DeliveryAddress(
      id: '',
      address: _apiService.selectedAddressText ?? 'Your detected location',
      latitude: lat,
      longitude: lng,
    ));
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
 @override
  void dispose() {
    _disposed = true;
    super.dispose();
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