import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/core/services/tracking_socket_service.dart';
import 'package:Saborly/shared/models/order_tracking_info.dart';

/// Drives the live order-tracking screen: one REST call for instant paint,
/// then a socket connection for live updates. Falls back to the same
/// 5-second Timer.periodic REST-poll pattern OrderStatusScreen already uses
/// if the socket never connects (or drops) within ~8 seconds.
class OrderTrackingProvider with ChangeNotifier {
  final String orderId;
  OrderTrackingProvider(this.orderId);

  OrderTrackingInfo? _tracking;
  bool _isLoading = true;
  String? _error;
  bool _usingFallbackPolling = false;

  Timer? _socketWatchdog;
  Timer? _pollTimer;
  bool _disposed = false;

  OrderTrackingInfo? get tracking => _tracking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usingFallbackPolling => _usingFallbackPolling;

  Future<void> start() async {
    await _loadFromRest();
    _connectSocket();
  }

  Future<void> _loadFromRest({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    final response = await ApiService().getOrderTracking(orderId);
    if (_disposed) return;

    if (response.isSuccess && response.data != null) {
      _tracking = response.data;
      _error = null;
    } else if (!silent) {
      _error = response.error ?? 'Unable to load tracking info';
    }

    _isLoading = false;
    notifyListeners();

    if (_tracking != null && _tracking!.isTerminal) {
      _stopFallbackPolling();
    }
  }

  void _connectSocket() {
    final token = ApiService().getAuthToken();
    if (token == null) {
      _startFallbackPolling();
      return;
    }

    final socket = TrackingSocketService.instance;
    socket.connect(token);

    socket.onConnect((_) {
      _stopFallbackPolling();
      socket.joinOrderTracking(orderId);
    });

    socket.onConnectError((_) => _startFallbackPolling());

    socket.on('order:location_update', (data) {
      if (data is! Map || data['orderId'] != orderId || _tracking == null) return;
      _tracking = _tracking!.copyWithLocation(Map<String, dynamic>.from(data));
      notifyListeners();
    });

    socket.on('order:status_changed', (data) {
      if (data is! Map || data['orderId'] != orderId || _tracking == null) return;
      _tracking = _tracking!.copyWithStatus(Map<String, dynamic>.from(data));
      notifyListeners();
      if (_tracking!.isTerminal) _stopFallbackPolling();
    });

    socket.on('order:driver_assigned', (_) => _loadFromRest(silent: true));
    socket.on('order:driver_started', (_) => _loadFromRest(silent: true));
    socket.on('order:driver_ended', (_) => _loadFromRest(silent: true));
    socket.on('order:tracking_error', (_) => _startFallbackPolling());

    // If the socket hasn't confirmed a connection shortly, degrade to polling
    // rather than leaving the customer staring at a stale/empty map.
    _socketWatchdog?.cancel();
    _socketWatchdog = Timer(const Duration(seconds: 8), () {
      if (!socket.isConnected) _startFallbackPolling();
    });
  }

  void _startFallbackPolling() {
    if (_usingFallbackPolling || _disposed) return;
    _usingFallbackPolling = true;
    notifyListeners();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_disposed || (_tracking?.isTerminal ?? false)) {
        timer.cancel();
        return;
      }
      _loadFromRest(silent: true);
    });
  }

  void _stopFallbackPolling() {
    if (!_usingFallbackPolling) return;
    _usingFallbackPolling = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _socketWatchdog?.cancel();
    _pollTimer?.cancel();
    final socket = TrackingSocketService.instance;
    socket.off('order:location_update');
    socket.off('order:status_changed');
    socket.off('order:driver_assigned');
    socket.off('order:driver_started');
    socket.off('order:driver_ended');
    socket.off('order:tracking_error');
    socket.leaveOrderTracking(orderId);
    // This screen is the only user of the tracking socket today — disconnect
    // rather than leave an idle connection alive while the customer browses
    // the rest of the app.
    socket.disconnect();
    super.dispose();
  }
}
