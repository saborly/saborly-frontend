import 'package:flutter/foundation.dart';
import '../../../shared/models/order.dart';

class LocationProvider extends ChangeNotifier {
  List<DeliveryAddress> _addresses = [];
  DeliveryAddress? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DeliveryAddress> get addresses => _addresses;
  DeliveryAddress? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadAddresses() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _addresses = [
     ];

      // Auto-select default address
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => _addresses.first,
        );
      } else {
        _selectedAddress = null;
      }
    } catch (e) {
      _setError('Failed to load addresses: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void selectAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> addAddress(DeliveryAddress address) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _addresses.add(address);
      
      // If this is the first address or marked as default, select it
      if (_addresses.length == 1 || address.isDefault) {
        _selectedAddress = address;
      }
    } catch (e) {
      _setError('Failed to add address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAddress(DeliveryAddress address) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        
        // Update selected address if it's the same one
        if (_selectedAddress?.id == address.id) {
          _selectedAddress = address;
        }
      }
    } catch (e) {
      _setError('Failed to update address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _addresses.removeWhere((address) => address.id == addressId);
      
      // If deleted address was selected, select another one
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
    } catch (e) {
      _setError('Failed to delete address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}