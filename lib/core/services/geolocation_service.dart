// Conditional export: uses web implementation on web, stub on other platforms
export 'geolocation_service_stub.dart'
    if (dart.library.html) 'geolocation_service_web.dart';
