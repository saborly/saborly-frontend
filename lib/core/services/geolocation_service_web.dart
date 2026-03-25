// ignore_for_file: avoid_web_libraries_in_flutter
// Web-specific geolocation implementation using dart:html Geolocation API

import 'dart:html' as html;

/// Requests the user's current GPS coordinates via the browser Geolocation API.
/// Returns a map with 'lat' and 'lng' keys, or null if permission is denied
/// or the position cannot be determined within the timeout.
Future<Map<String, double>?> detectUserLocation() async {
  try {
    final position =
        await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: false,
      timeout: const Duration(seconds: 4), // ✅ Faster: fail fast instead of blocking for 10s
      maximumAge: const Duration(hours: 1), // ✅ Reuse a cached GPS fix up to 1 hour old
    );

    final coords = position.coords;
    if (coords != null) {
      final lat = coords.latitude;
      final lng = coords.longitude;
      if (lat != null && lng != null) {
        return {'lat': lat.toDouble(), 'lng': lng.toDouble()};
      }
    }
    return null;
  } catch (_) {
    // Permission denied, position unavailable, or timeout
    return null;
  }
}
