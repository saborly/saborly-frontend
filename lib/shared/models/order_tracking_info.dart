/// The customer/admin-facing live tracking view of an order, parsed from both
/// GET /orders/:id/tracking (REST) and the `order:location_update` /
/// `order:status_changed` socket events. Deliberately kept separate from
/// [Order] rather than bloating that model with driver/location fields.
class OrderTrackingInfo {
  final String orderId;
  final String status;
  final int trackingStage;
  final String trackingStageLabel;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleType;
  final double? latitude;
  final double? longitude;
  final double? heading;
  final bool isLive;
  final bool isStale;
  final DateTime? startedAt;
  final String? branchName;
  final double? branchLatitude;
  final double? branchLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? destinationAddress;
  final DateTime? estimatedDeliveryTime;
  final DateTime updatedAt;

  OrderTrackingInfo({
    required this.orderId,
    required this.status,
    required this.trackingStage,
    required this.trackingStageLabel,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleType,
    this.latitude,
    this.longitude,
    this.heading,
    this.isLive = false,
    this.isStale = false,
    this.startedAt,
    this.branchName,
    this.branchLatitude,
    this.branchLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationAddress,
    this.estimatedDeliveryTime,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Parses the GET /orders/:id/tracking REST payload's `tracking` object.
  factory OrderTrackingInfo.fromMap(Map<String, dynamic> map) {
    final driver = map['driver'] as Map<String, dynamic>?;
    final location = map['location'] as Map<String, dynamic>?;
    final branch = map['branch'] as Map<String, dynamic>?;
    final destination = map['destination'] as Map<String, dynamic>?;

    return OrderTrackingInfo(
      orderId: (map['orderId'] ?? '').toString(),
      status: map['status'] as String? ?? 'pending',
      trackingStage: (map['trackingStage'] as num?)?.toInt() ?? 0,
      trackingStageLabel: map['trackingStageLabel'] as String? ?? '',
      driverId: driver?['id']?.toString(),
      driverName: driver != null ? '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim() : null,
      driverPhone: driver?['phone'] as String?,
      vehicleType: driver?['vehicleType'] as String?,
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      heading: (location?['heading'] as num?)?.toDouble(),
      isLive: map['isLive'] as bool? ?? false,
      isStale: map['isStale'] as bool? ?? false,
      startedAt: map['startedAt'] != null ? DateTime.tryParse(map['startedAt'].toString()) : null,
      branchName: branch?['name'] as String?,
      branchLatitude: (branch?['latitude'] as num?)?.toDouble(),
      branchLongitude: (branch?['longitude'] as num?)?.toDouble(),
      destinationLatitude: (destination?['latitude'] as num?)?.toDouble(),
      destinationLongitude: (destination?['longitude'] as num?)?.toDouble(),
      destinationAddress: destination?['address'] as String?,
      estimatedDeliveryTime: map['estimatedDeliveryTime'] != null
          ? DateTime.tryParse(map['estimatedDeliveryTime'].toString())
          : null,
    );
  }

  /// Merges a live `order:location_update` socket payload into this snapshot,
  /// keeping every other field (driver identity, destination, etc.) intact.
  OrderTrackingInfo copyWithLocation(Map<String, dynamic> payload) {
    return OrderTrackingInfo(
      orderId: orderId,
      status: status,
      trackingStage: trackingStage,
      trackingStageLabel: trackingStageLabel,
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
      vehicleType: vehicleType,
      latitude: (payload['latitude'] as num?)?.toDouble() ?? latitude,
      longitude: (payload['longitude'] as num?)?.toDouble() ?? longitude,
      heading: (payload['heading'] as num?)?.toDouble() ?? heading,
      isLive: true,
      isStale: false,
      startedAt: startedAt,
      branchName: branchName,
      branchLatitude: branchLatitude,
      branchLongitude: branchLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      destinationAddress: destinationAddress,
      estimatedDeliveryTime: estimatedDeliveryTime,
      updatedAt: DateTime.now(),
    );
  }

  /// Merges a live `order:status_changed` socket payload.
  OrderTrackingInfo copyWithStatus(Map<String, dynamic> payload) {
    return OrderTrackingInfo(
      orderId: orderId,
      status: payload['status'] as String? ?? status,
      trackingStage: (payload['trackingStage'] as num?)?.toInt() ?? trackingStage,
      trackingStageLabel: payload['trackingStageLabel'] as String? ?? trackingStageLabel,
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
      vehicleType: vehicleType,
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      isLive: isLive,
      isStale: isStale,
      startedAt: startedAt,
      branchName: branchName,
      branchLatitude: branchLatitude,
      branchLongitude: branchLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      destinationAddress: destinationAddress,
      estimatedDeliveryTime: estimatedDeliveryTime,
      updatedAt: DateTime.now(),
    );
  }

  bool get isTerminal => status == 'delivered' || status == 'cancelled' || status == 'refunded';
  bool get hasDriverLocation => latitude != null && longitude != null;
}
