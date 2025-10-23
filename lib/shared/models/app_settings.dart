// lib/shared/models/app_settings.dart

class AppSettings {
  final String restaurantName;
  final String? description;
  final String? logo;
  final Address? address;
  final String? contactPhone;
  final String? contactEmail;
  final DeliverySettings? deliverySettings;
  final PickupSettings? pickupSettings;
  final String currency;
  final bool isCurrentlyOpen;

  AppSettings({
    required this.restaurantName,
    this.description,
    this.logo,
    this.address,
    this.contactPhone,
    this.contactEmail,
    this.deliverySettings,
    this.pickupSettings,
    required this.currency,
    required this.isCurrentlyOpen,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      restaurantName: map['restaurantName'] ?? '',
      description: map['description'],
      logo: map['logo'],
      address: map['address'] != null ? Address.fromMap(map['address']) : null,
      contactPhone: map['contactPhone'],
      contactEmail: map['contactEmail'],
      deliverySettings: map['deliverySettings'] != null
          ? DeliverySettings.fromMap(map['deliverySettings'])
          : null,
      pickupSettings: map['pickupSettings'] != null
          ? PickupSettings.fromMap(map['pickupSettings'])
          : null,
      currency: map['currency'] ?? 'USD',
      isCurrentlyOpen: map['isCurrentlyOpen'] ?? true,
    );
  }
}

class DeliverySettings {
  final bool isDeliveryEnabled; // ✅ NEW
  final double defaultDeliveryFee;
  final double freeDeliveryThreshold;
  final double deliveryRadius;
  final int estimatedDeliveryTime;
  final String? disabledMessage; // ✅ NEW

  DeliverySettings({
    required this.isDeliveryEnabled,
    required this.defaultDeliveryFee,
    required this.freeDeliveryThreshold,
    required this.deliveryRadius,
    required this.estimatedDeliveryTime,
    this.disabledMessage,
  });

  factory DeliverySettings.fromMap(Map<String, dynamic> map) {
    return DeliverySettings(
      isDeliveryEnabled: map['isDeliveryEnabled'] ?? true,
      defaultDeliveryFee: (map['defaultDeliveryFee'] ?? 0).toDouble(),
      freeDeliveryThreshold: (map['freeDeliveryThreshold'] ?? 0).toDouble(),
      deliveryRadius: (map['deliveryRadius'] ?? 10).toDouble(),
      estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? 45,
      disabledMessage: map['disabledMessage'],
    );
  }
}

class PickupSettings {
  final bool isPickupEnabled;
  final int estimatedPickupTime;
  final String? pickupInstructions;

  PickupSettings({
    required this.isPickupEnabled,
    required this.estimatedPickupTime,
    this.pickupInstructions,
  });

  factory PickupSettings.fromMap(Map<String, dynamic> map) {
    return PickupSettings(
      isPickupEnabled: map['isPickupEnabled'] ?? true,
      estimatedPickupTime: map['estimatedPickupTime'] ?? 20,
      pickupInstructions: map['pickupInstructions'],
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  String get fullAddress => '$street, $city, $state $zipCode, $country';
}