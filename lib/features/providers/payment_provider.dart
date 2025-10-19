// ==================== PAYMENT PROVIDER ====================
import 'package:flutter/foundation.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/checkout_provider.dart';
import 'package:soely/features/providers/order_provider.dart';
import '../../../shared/models/order.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  CodPaymentType? _codPaymentType; // NEW: COD payment type
  bool _isProcessing = false;
  String? _error;
  String? _orderId;

  // Dependencies
  OrderProvider? _orderProvider;
  CartProvider? _cartProvider;
  CheckoutProvider? _checkoutProvider;

  // Shop pickup address and branch
  static const String defaultBranchId = '68dbd3f99bd73f7f7262664b';
  static DeliveryAddress shopAddress = DeliveryAddress(
    id: 'shop_main',
    type: 'pickup',
    address: 'Saborly C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
    apartment: '+34932112072',
    isDefault: true,
  );

  String? _specialInstructions;

  // Getters
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  CodPaymentType? get codPaymentType => _codPaymentType; // NEW
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get orderId => _orderId;
  String? get specialInstructions => _specialInstructions;

  // Initialize with dependencies
  void initialize({
    required OrderProvider orderProvider,
    required CartProvider cartProvider,
    CheckoutProvider? checkoutProvider,
  }) {
    _orderProvider = orderProvider;
    _cartProvider = cartProvider;
    _checkoutProvider = checkoutProvider;
    
    // Set initial payment method based on delivery type
    _updatePaymentMethodBasedOnDeliveryType();
  }

  // Update payment method when delivery type changes
  void _updatePaymentMethodBasedOnDeliveryType() {
    if (_checkoutProvider != null) {
      final deliveryType = _checkoutProvider!.deliveryType;
      
      if (deliveryType == DeliveryType.pickup) {
        _selectedPaymentMethod = PaymentMethod.shop;
        _codPaymentType = null; // Reset COD payment type
      } else {
        _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
        _codPaymentType = CodPaymentType.cash; // Set default
      }
      notifyListeners();
    }
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    // Only allow selecting available payment methods
    if (isPaymentMethodAvailable(method)) {
      _selectedPaymentMethod = method;
      
      // Reset COD payment type if not COD
      if (method != PaymentMethod.cashOnDelivery) {
        _codPaymentType = null;
      } else if (_codPaymentType == null) {
        _codPaymentType = CodPaymentType.cash; // Set default
      }
      
      notifyListeners();
    }
  }

  // NEW: Set COD payment type
  void setCodPaymentType(CodPaymentType type) {
    _codPaymentType = type;
    notifyListeners();
  }

  void setSpecialInstructions(String? instructions) {
    _specialInstructions = instructions;
    notifyListeners();
  }

  Future<bool> processPayment() async {
    _setProcessing(true);
    _setError(null);

    try {
      // Validate dependencies
      if (_orderProvider == null || 
          _cartProvider == null || 
          _checkoutProvider == null) {
        throw Exception('Payment provider not properly initialized');
      }

      // Validate payment method is available
      if (!isPaymentMethodAvailable(_selectedPaymentMethod)) {
        throw Exception('Selected payment method is not available');
      }

      // Validate COD payment type for delivery orders
      if (_selectedPaymentMethod == PaymentMethod.cashOnDelivery && _codPaymentType == null) {
        throw Exception('Please select cash or card payment option');
      }

      // Validate cart has items
      if (_cartProvider!.items.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Get delivery type and address from CheckoutProvider
      final deliveryType = _checkoutProvider!.deliveryType;
      final deliveryAddress = deliveryType == DeliveryType.delivery
          ? _checkoutProvider!.selectedAddress
          : null;

      // Validate delivery requirements
      if (deliveryType == DeliveryType.delivery) {
        if (deliveryAddress == null) {
          throw Exception('Please select a delivery address');
        }
        if (!_checkoutProvider!.canDeliver) {
          throw Exception('Selected address is beyond delivery range');
        }
        // Ensure cashOnDelivery is selected for delivery
        if (_selectedPaymentMethod != PaymentMethod.cashOnDelivery) {
          throw Exception('Only Cash on Delivery is available for home delivery');
        }
      } else {
        // Ensure shop payment is selected for pickup
        if (_selectedPaymentMethod != PaymentMethod.shop) {
          throw Exception('Only Shop Payment is available for pickup orders');
        }
      }

      // Get delivery fee from cart (already calculated in CheckoutProvider)
      final deliveryFee = _cartProvider!.deliveryFee;

      // Create order using OrderProvider
      final success = await _orderProvider!.createOrder(
        items: _cartProvider!.items,
        branchId: defaultBranchId,
        deliveryAddress: deliveryType == DeliveryType.delivery
            ? deliveryAddress
            : shopAddress,
        deliveryType: deliveryType,
        paymentMethod: _selectedPaymentMethod,
        codPaymentType: _codPaymentType, // NEW: Pass COD payment type
        deliveryFee: deliveryFee,
        specialInstructions: _specialInstructions,
      );

      if (!success) {
        throw Exception(_orderProvider!.error ?? 'Failed to create order');
      }

      // Get the created order ID
      _orderId = _orderProvider!.currentOrder?.id;

      if (_orderId == null) {
        throw Exception('Order created but ID not available');
      }

      // Clear cart after successful order
      _cartProvider!.clearCart();

      // Reset checkout provider
      _checkoutProvider!.reset();


      _setProcessing(false);
      return true;
    } catch (e) {
      _setError('Order failed: ${e.toString()}');
      _setProcessing(false);
      return false;
    }
  }

  bool isPaymentMethodAvailable(PaymentMethod method) {
    if (_checkoutProvider == null) return false;
    
    final deliveryType = _checkoutProvider!.deliveryType;
    
    // For pickup orders, only shop payment is available
    if (deliveryType == DeliveryType.pickup) {
      return method == PaymentMethod.shop;
    }
    
    // For delivery orders, only cash on delivery is available
    if (deliveryType == DeliveryType.delivery) {
      return method == PaymentMethod.cashOnDelivery;
    }
    
    return false;
  }

  // Get available payment methods based on delivery type
  List<PaymentMethod> getAvailablePaymentMethods() {
    if (_checkoutProvider == null) return [];
    
    final deliveryType = _checkoutProvider!.deliveryType;
    
    if (deliveryType == DeliveryType.pickup) {
      return [PaymentMethod.shop];
    } else {
      return [PaymentMethod.cashOnDelivery];
    }
  }

  void reset() {
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _codPaymentType = null; // NEW: Reset COD payment type
    _isProcessing = false;
    _error = null;
    _orderId = null;
    _specialInstructions = null;
    notifyListeners();
  }
}