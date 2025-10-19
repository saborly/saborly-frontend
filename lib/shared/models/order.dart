import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'user.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  pickup,      // For pickup orders
  shop,        // For shop orders
  outForDelivery, // For delivery orders
  delivered,
  cancelled,
  refunded
}

enum PaymentMethod {
  cashOnDelivery,
  shop,
  card,
  paypal,
  stripe
}
enum CodPaymentType {
  cash,
  card,
}
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded
}

enum DeliveryType {
  delivery,
  pickup
}

class Order extends Equatable {
  final String id;
  final String userId;
  final User? user;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DeliveryType deliveryType;
  final DeliveryAddress? deliveryAddress;
  final String? specialInstructions;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String branchId;
  final String? branchName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CodPaymentType? codPaymentType; // NEW

  const Order({
    required this.id,
    required this.userId,
    this.user,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryType,
    this.deliveryAddress,
    this.specialInstructions,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.branchId,
    this.branchName,
    required this.createdAt,
    required this.updatedAt,
        this.codPaymentType,

  });

  @override
  List<Object?> get props => [
        id,
        userId,
        user,
        items,
        subtotal,
        deliveryFee,
        tax,
        discount,
        total,
        status,
        paymentMethod,
        paymentStatus,
        deliveryType,
        deliveryAddress,
        specialInstructions,
        estimatedDeliveryTime,
        actualDeliveryTime,
        branchId,
        branchName,
        createdAt,
        updatedAt,
      ];

  Order copyWith({
    String? id,
    String? userId,
    User? user,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? discount,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    DeliveryType? deliveryType,
    DeliveryAddress? deliveryAddress,
    String? specialInstructions,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    String? branchId,
    String? branchName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toMap(),
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'deliveryType': deliveryType.name,
      'deliveryAddress': deliveryAddress?.toMap(),
      'specialInstructions': specialInstructions,
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'branchId': branchId,
      'branchName': branchName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
            if (codPaymentType != null) 'codPaymentType': codPaymentType!.name,

    };
  }

 factory Order.fromMap(Map<String, dynamic> map) {
  return Order(
    id: map['_id'] ?? map['id'] ?? '',
    userId: map['userId'] is String
        ? map['userId']
        : map['userId']?['_id'] ?? '',
    user: map['userId'] is Map<String, dynamic>
        ? User.fromMap(map['userId'])
        : null,
    items: List<CartItem>.from(
      map['items']?.map((x) => CartItem.fromMap(x)) ?? [],
    ),
    subtotal: map['subtotal']?.toDouble() ?? 0.0,
    deliveryFee: map['deliveryFee']?.toDouble() ?? 0.0,
    tax: map['tax']?.toDouble() ?? 0.0,
    discount: map['discount']?.toDouble() ?? 0.0,
    total: map['total']?.toDouble() ?? 0.0,
    status: _parseOrderStatus(map['status']),
    paymentMethod: _parsePaymentMethod(map['paymentMethod']),
    paymentStatus: _parsePaymentStatus(map['paymentStatus']),
    deliveryType: _parseDeliveryType(map['deliveryType']),
    deliveryAddress: map['deliveryAddress'] != null
        ? DeliveryAddress.fromMap(map['deliveryAddress'])
        : null,
    specialInstructions: map['specialInstructions'],
    estimatedDeliveryTime: map['estimatedDeliveryTime'] != null
        ? DateTime.parse(map['estimatedDeliveryTime'])
        : null,
    actualDeliveryTime: map['actualDeliveryTime'] != null
        ? DateTime.parse(map['actualDeliveryTime'])
        

        : null,

codPaymentType: map['codPaymentType'] != null 
          ? CodPaymentType.values.firstWhere(
              (e) => e.name == map['codPaymentType'],
              orElse: () => CodPaymentType.cash,
            )
          : null,
        
    branchId: map['branchId'] ?? '',
    branchName: map['branchName'],
    createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),

  );
}
  static OrderStatus _parseOrderStatus(dynamic status) {
    switch (status.toString().toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'outfordelivery':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentMethod _parsePaymentMethod(dynamic method) {
    switch (method.toString().toLowerCase()) {
      case 'cash-on-delivery':
      case 'cash_on_delivery':
      case 'cod':
        return PaymentMethod.cashOnDelivery;
      case 'card':
        return PaymentMethod.card;
      case 'paypal':
        return PaymentMethod.paypal;
      case 'stripe':
        return PaymentMethod.stripe;
      default:
        return PaymentMethod.cashOnDelivery;
    }
  }

  static PaymentStatus _parsePaymentStatus(dynamic status) {
    switch (status.toString().toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static DeliveryType _parseDeliveryType(dynamic type) {
    switch (type.toString().toLowerCase()) {
      case 'delivery':
        return DeliveryType.delivery;
      case 'pickup':
      case 'takeaway':
        return DeliveryType.pickup;
      default:
        return DeliveryType.delivery;
    }
  }
}

// Update your DeliveryAddress class in order.dart

class DeliveryAddress {
  final String id;
  final String? type;
  final String address;
  final String? apartment;
  final String? instructions;
  final double? latitude;
  final double? longitude;
  bool isDefault;

  DeliveryAddress({
    required this.id,
    this.type,
    required this.address,
    this.apartment,
    this.instructions,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      type: map['type']?.toString(),
      address: map['address']?.toString() ?? '',
      apartment: map['apartment']?.toString(),
      instructions: map['instructions']?.toString(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      isDefault: map['isDefault'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'address': address,
      'apartment': apartment,
      'instructions': instructions,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  DeliveryAddress copyWith({
    String? id,
    String? type,
    String? address,
    String? apartment,
    String? instructions,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      type: type ?? this.type,
      address: address ?? this.address,
      apartment: apartment ?? this.apartment,
      instructions: instructions ?? this.instructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}