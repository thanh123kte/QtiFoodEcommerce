class LocationPoint {
  final double latitude;
  final double longitude;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
  });
}

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}

abstract interface class LocationProvider {
  Future<LocationPoint> getCurrentPosition();
}

