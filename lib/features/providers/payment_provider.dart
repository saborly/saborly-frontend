// lib/features/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/core/services/api_service.dart';
import '../../../shared/models/order.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  CodPaymentType? _codPaymentType;
  bool _isProcessing = false;
  String? _error;
  String? _orderId;

  // Dependencies
  OrderProvider? _orderProvider;
  CartProvider? _cartProvider;
  CheckoutProvider? _checkoutProvider;
  OffersProvider? _offersProvider;

  // Shop pickup address and branch
  static const String defaultBranchId = '68dbd3f99bd73f7f7262664b';
  static DeliveryAddress shopAddress = DeliveryAddress(
    id: 'shop_main',
    type: 'pickup',
    address: 'SaborlyC/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
    apartment: '+34932112072',
    isDefault: true,
  );

  String? _specialInstructions;

  // Getters
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  CodPaymentType? get codPaymentType => _codPaymentType;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get orderId => _orderId;
  String? get specialInstructions => _specialInstructions;

  // Initialize with dependencies
  void initialize({
    required OrderProvider orderProvider,
    required CartProvider cartProvider,
    CheckoutProvider? checkoutProvider,
    OffersProvider? offersProvider,
  }) {
    _orderProvider = orderProvider;
    _cartProvider = cartProvider;
    _checkoutProvider = checkoutProvider;
    _offersProvider = offersProvider;
    
    _updatePaymentMethodBasedOnDeliveryType();
  }

  void _updatePaymentMethodBasedOnDeliveryType() {
    if (_checkoutProvider != null) {
      final deliveryType = _checkoutProvider!.deliveryType;
      
      if (deliveryType == DeliveryType.pickup) {
        _selectedPaymentMethod = PaymentMethod.shop;
        _codPaymentType = null;
      } else {
        _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
        _codPaymentType = CodPaymentType.cash;
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
    if (isPaymentMethodAvailable(method)) {
      _selectedPaymentMethod = method;
      
      if (method != PaymentMethod.cashOnDelivery) {
        _codPaymentType = null;
      } else if (_codPaymentType == null) {
        _codPaymentType = CodPaymentType.cash;
      }
      
      notifyListeners();
    }
  }

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

      if (!isPaymentMethodAvailable(_selectedPaymentMethod)) {
        throw Exception('Selected payment method is not available');
      }

      if (_selectedPaymentMethod == PaymentMethod.cashOnDelivery && _codPaymentType == null) {
        throw Exception('Please select cash or card payment option');
      }

      if (_cartProvider!.items.isEmpty) {
        throw Exception('Cart is empty');
      }

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
        if (_selectedPaymentMethod != PaymentMethod.cashOnDelivery) {
          throw Exception('Only Cash on Delivery is available for home delivery');
        }
      } else {
        if (_selectedPaymentMethod != PaymentMethod.shop) {
          throw Exception('Only Shop Payment is available for pickup orders');
        }
      }

      final deliveryFee = _cartProvider!.deliveryFee;

      // ==================== NEW: CAPTURE OFFER INFO BEFORE ORDER ====================
      Map<String, dynamic>? activeDiscountBeforeOrder;
      List<String> offerIdsInCart = [];
      
      if (_offersProvider != null) {
        // Get active device discount
        activeDiscountBeforeOrder = _offersProvider!.activeDeviceDiscount;
        
        // Collect all offer IDs from cart items
        for (final cartItem in _cartProvider!.items) {
          if (cartItem.foodItem.offer != null && 
              cartItem.foodItem.offer!.isOneTimePerDevice) {
            offerIdsInCart.add(cartItem.foodItem.offer!.id);
          }
        }
        
        if (kDebugMode) {
          if (activeDiscountBeforeOrder != null) {
            print('🎟️ Active discount: ${activeDiscountBeforeOrder['offerTitle']}');
          }
          if (offerIdsInCart.isNotEmpty) {
            print('🎟️ Cart has ${offerIdsInCart.length} one-time offers');
          }
        }
      }

      // Check first-order mobile discount eligibility (mobile only, non-web)
      final String deviceId = _offersProvider?.deviceId ?? '';
      bool applyFirstOrderDiscount = false;
      if (!kIsWeb && deviceId.isNotEmpty) {
        final eligibility = await ApiService().checkFirstOrderDiscount(deviceId);
        applyFirstOrderDiscount = eligibility['eligible'] == true;
      }

      // Create order
      final success = await _orderProvider!.createOrder(
        items: _cartProvider!.items,
        branchId: defaultBranchId,
        deliveryAddress: deliveryType == DeliveryType.delivery
            ? deliveryAddress
            : shopAddress,
        deliveryType: deliveryType,
        paymentMethod: _selectedPaymentMethod,
        codPaymentType: _codPaymentType,
        deliveryFee: deliveryFee,
        specialInstructions: _specialInstructions,
        deviceId: deviceId.isNotEmpty ? deviceId : null,
        platform: kIsWeb ? 'web' : 'mobile',
        applyFirstOrderDiscount: applyFirstOrderDiscount,
      );

      if (!success) {
        throw Exception(_orderProvider!.error ?? 'Failed to create order');
      }

      _orderId = _orderProvider!.currentOrder?.id;

      if (_orderId == null) {
        throw Exception('Order created but ID not available');
      }

      // ==================== NEW: CLAIM OFFERS AFTER SUCCESSFUL ORDER ====================
      if (_offersProvider != null) {
        await _claimUsedOffers(
          activeDiscount: activeDiscountBeforeOrder,
          cartOfferIds: offerIdsInCart,
          orderId: _orderId!,
        );
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

  /// Claim all one-time offers used in this order
  Future<void> _claimUsedOffers({
    Map<String, dynamic>? activeDiscount,
    required List<String> cartOfferIds,
    required String orderId,
  }) async {
    if (_offersProvider == null) return;

    try {
      // 1. Release active device discount
      if (activeDiscount != null) {
        await _offersProvider!.releaseDiscount();
        
        if (kDebugMode) {
          print('✅ Released active discount: ${activeDiscount['offerTitle']}');
        }
      }

      // 2. Claim all one-time offers from cart items
      if (cartOfferIds.isNotEmpty) {
        final uniqueOfferIds = cartOfferIds.toSet();
        
        for (final offerId in uniqueOfferIds) {
          try {
            // Call backend to mark offer as claimed by device
            await _claimOfferOnBackend(offerId, orderId);
            
            // Mark offer as claimed locally
            await _offersProvider!.markOfferAsClaimedLocally(offerId);
            
            if (kDebugMode) {
              print('✅ Claimed one-time offer: $offerId');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Failed to claim offer $offerId: $e');
            }
          }
        }

        // Reload offers to update UI
        await _offersProvider!.loadOffers();
      }
    } catch (e) {
      // Don't fail the order if claiming fails
      if (kDebugMode) {
        print('⚠️ Error claiming offers: $e');
      }
    }
  }

  /// Call backend to claim offer
  Future<void> _claimOfferOnBackend(String offerId, String orderId) async {
    try {
      final deviceId = _offersProvider!.deviceId;
      if (deviceId == null) {
        throw Exception('Device ID not available');
      }

      final response = await ApiService().dio.post(
        '/offer/$offerId/claim',
        data: {
          'deviceId': deviceId,
          'orderId': orderId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to claim offer on backend');
      }

      if (kDebugMode) {
        print('✅ Backend claim successful for offer: $offerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Backend claim failed: $e');
      }
      rethrow;
    }
  }

  bool isPaymentMethodAvailable(PaymentMethod method) {
    if (_checkoutProvider == null) return false;
    
    final deliveryType = _checkoutProvider!.deliveryType;
    
    if (deliveryType == DeliveryType.pickup) {
      return method == PaymentMethod.shop;
    }
    
    if (deliveryType == DeliveryType.delivery) {
      return method == PaymentMethod.cashOnDelivery;
    }
    
    return false;
  }

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
    _codPaymentType = null;
    _isProcessing = false;
    _error = null;
    _orderId = null;
    _specialInstructions = null;
    notifyListeners();
  }
}