class DriverLocation {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });
}

class OrderTracking {
  final int orderId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final DriverLocation driverLocation;
  // Recipient location (derived from shipping address lat/lng)
  final double? recipientLatitude;
  final double? recipientLongitude;
  final String shippingAddress;
  final String storeAddress;
  final String status;
  final DateTime assignedAt;

  OrderTracking({
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.driverLocation,
    this.recipientLatitude,
    this.recipientLongitude,
    required this.shippingAddress,
    required this.storeAddress,
    required this.status,
    required this.assignedAt,
  });

  OrderTracking copyWith({
    int? orderId,
    String? driverId,
    String? driverName,
    String? driverPhone,
    DriverLocation? driverLocation,
    double? recipientLatitude,
    double? recipientLongitude,
    String? shippingAddress,
    String? storeAddress,
    String? status,
    DateTime? assignedAt,
  }) {
    return OrderTracking(
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverLocation: driverLocation ?? this.driverLocation,
      recipientLatitude: recipientLatitude ?? this.recipientLatitude,
      recipientLongitude: recipientLongitude ?? this.recipientLongitude,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      storeAddress: storeAddress ?? this.storeAddress,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}
