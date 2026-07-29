// Mobile (Android/iOS) geolocation implementation using the geolocator plugin.

import 'package:geolocator/geolocator.dart';

/// Requests the user's current GPS coordinates via the device's location
/// services. Returns a map with 'lat' and 'lng' keys, or null if permission
/// is denied, location services are off, or the position cannot be
/// determined within the timeout.
Future<Map<String, double>?> detectUserLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );

    return {'lat': position.latitude, 'lng': position.longitude};
  } catch (_) {
    return null;
  }
}
