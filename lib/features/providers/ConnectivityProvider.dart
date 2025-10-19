import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityProvider with ChangeNotifier {
  bool _isInternetAvailable = false;
  String _connectionStatus = 'Unknown';
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityProvider() {
    _initConnectivity();
  }

  bool get isInternetAvailable => _isInternetAvailable;
  String get connectionStatus => _connectionStatus;

  Future<void> _initConnectivity() async {
    await _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_checkConnectivity);
  }

  Future<void> _checkConnectivity([List<ConnectivityResult>? result]) async {
    result ??= await Connectivity().checkConnectivity();
    
    String status;
    bool isConnected = false;

    if (result.contains(ConnectivityResult.none)) {
      status = 'No Internet';
    } else if (result.contains(ConnectivityResult.wifi)) {
      status = 'Connected to Wi-Fi';
      isConnected = await _pingInternet();
    } else if (result.contains(ConnectivityResult.mobile)) {
      status = 'Connected to Mobile Data';
      isConnected = await _pingInternet();
    } else {
      status = 'Unknown';
    }

    if (_connectionStatus != status || _isInternetAvailable != isConnected) {
      _connectionStatus = status;
      _isInternetAvailable = isConnected;
      notifyListeners();
    }
  }

  Future<bool> _pingInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}