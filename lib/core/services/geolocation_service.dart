/// Platform-aware geolocation service.
///
/// On the web this delegates to `dart:html`'s Geolocation API.
/// On all other platforms it returns null (no-op stub).
export 'geolocation_service_stub.dart'
    if (dart.library.html) 'geolocation_service_web.dart';
