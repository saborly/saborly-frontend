/// Platform-aware geolocation service.
///
/// On the web this delegates to `dart:html`'s Geolocation API.
/// On Android/iOS it uses the `geolocator` plugin for real device GPS.
export 'geolocation_service_stub.dart'
    if (dart.library.html) 'geolocation_service_web.dart'
    if (dart.library.io) 'geolocation_service_mobile.dart';
