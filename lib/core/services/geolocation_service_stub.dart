/// Non-web stub for geolocation — always returns null so the branch
/// selection screen falls back to showing both cards without pre-selection.
Future<Map<String, double>?> detectUserLocation() async => null;
