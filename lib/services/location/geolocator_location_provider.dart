import 'package:geolocator/geolocator.dart';

import 'location_provider.dart';

class GeolocatorLocationProvider implements LocationProvider {
  final LocationSettings locationSettings;

  GeolocatorLocationProvider({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) : locationSettings = LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        );

  @override
  Future<LocationPoint> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permissions are permanently denied.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: locationSettings.accuracy,
      timeLimit: locationSettings.timeLimit,
    );

    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

