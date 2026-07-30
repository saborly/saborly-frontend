// ignore_for_file: avoid_web_libraries_in_flutter
// Web-specific geolocation implementation using dart:html Geolocation API

import 'dart:async';
import 'dart:html' as html;

/// Requests the user's current GPS coordinates via the browser Geolocation API.
/// Returns a map with 'lat' and 'lng' keys, or null if permission is denied
/// or the position cannot be determined within the timeout.
///
/// Windows + Chrome (and some other combinations) gate geolocation behind
/// *two* consent steps: the in-page permission prompt, and then a separate
/// OS-level "let this app use your location" dialog that appears only after
/// the user answers the first one. Chrome's `getCurrentPosition` call
/// resolves with an error immediately if OS-level access isn't granted yet —
/// no JS-side timeout can wait that out, because the browser has already
/// settled the promise. There's no way to await the OS dialog directly, but
/// the W3C Permissions API *does* report a state change once the user
/// finishes granting access at every level, so we poll that after a first
/// failure and only retry once it actually reports "granted" (or give up
/// once it reports "denied") instead of guessing with a fixed delay.
Future<Map<String, double>?> detectUserLocation() async {
  final first = await _requestPosition(const Duration(seconds: 8));
  if (first != null) return first;

  final settled = await _awaitPermissionSettled(const Duration(seconds: 20));
  if (settled != 'granted') return null;

  return _requestPosition(const Duration(seconds: 6));
}

/// Polls `navigator.permissions.query({name: 'geolocation'})` until its
/// state leaves "prompt", or the timeout elapses. Returns the final state
/// ("granted"/"denied"), or null if the Permissions API isn't available or
/// never settles in time.
Future<String?> _awaitPermissionSettled(Duration timeout) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final state = await _geolocationPermissionState();
    if (state == null) return null; // API unsupported — caller gives up gracefully
    if (state != 'prompt') return state;
    await Future.delayed(const Duration(milliseconds: 400));
  }
  return null;
}

Future<String?> _geolocationPermissionState() async {
  try {
    final permissions = html.window.navigator.permissions;
    if (permissions == null) return null;

    final status = await permissions.query({'name': 'geolocation'});
    return status.state;
  } catch (_) {
    return null;
  }
}

Future<Map<String, double>?> _requestPosition(Duration timeout) async {
  try {
    final position =
        await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: false,
      timeout: timeout,
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
