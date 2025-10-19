import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String? imageUrl;
  final Map<String, String>? openingHours;
  final List<String>? features;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
    this.imageUrl,
    this.openingHours,
    this.features,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        email,
        latitude,
        longitude,
        isActive,
        imageUrl,
        openingHours,
        features,
        createdAt,
        updatedAt,
      ];

  Branch copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    bool? isActive,
    String? imageUrl,
    Map<String, String>? openingHours,
    List<String>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      openingHours: openingHours ?? this.openingHours,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'openingHours': openingHours,
      'features': features,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      isActive: map['isActive'] ?? true,
      imageUrl: map['imageUrl'],
      openingHours: map['openingHours'] != null 
          ? Map<String, String>.from(map['openingHours'])
          : null,
      features: map['features'] != null 
          ? List<String>.from(map['features'])
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}