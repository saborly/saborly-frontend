import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constant/api_constants.dart';

typedef SocketEventHandler = void Function(dynamic data);

/// Thin Socket.IO wrapper for the customer app's live order tracking screen.
/// Same factory-singleton idiom as ApiService — one connection for the app's
/// lifetime, screens attach/detach listeners rather than owning a socket.
class TrackingSocketService {
  static final TrackingSocketService instance = TrackingSocketService._internal();
  factory TrackingSocketService() => instance;
  TrackingSocketService._internal();

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String authToken) {
    disconnect();

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': authToken})
          .build(),
    );
    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void on(String event, SocketEventHandler handler) => _socket?.on(event, handler);
  void off(String event) => _socket?.off(event);

  void onConnect(SocketEventHandler handler) => _socket?.onConnect(handler);
  void onConnectError(SocketEventHandler handler) => _socket?.onConnectError(handler);

  void joinOrderTracking(String orderId) => _socket?.emit('join_order_tracking', {'orderId': orderId});
  void leaveOrderTracking(String orderId) => _socket?.emit('leave_order_tracking', {'orderId': orderId});
}
