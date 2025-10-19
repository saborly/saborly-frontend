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