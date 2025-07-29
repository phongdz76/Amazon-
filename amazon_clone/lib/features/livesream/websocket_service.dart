// websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:amazon_clone/models/product.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  IO.Socket? _socket;
  StreamController<StreamState>? _stateController;

  // Current stream state
  StreamState _currentState = StreamState(
    isActive: false,
    viewers: 0,
    products: [],
    status: 'offline',
  );

  // Getters
  StreamState get currentState => _currentState;
  bool get isConnected => _socket?.connected ?? false;

  // Stream for UI updates
  Stream<StreamState> get stateStream {
    _stateController ??= StreamController<StreamState>.broadcast();
    return _stateController!.stream;
  }

  // Connect to WebSocket server
  Future<bool> connect({String? serverUrl}) async {
    try {
      // Default server URL - thay đổi IP này thành IP máy Windows của bạn
      final url = serverUrl ?? 'http://10.21.6.207:3000'; // Thay IP này

      debugPrint('🔗 Connecting to WebSocket server: $url');

      _socket = IO.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'timeout': 5000,
      });

      // Set up event listeners
      _setupEventListeners();

      // Connect
      _socket!.connect();

      // Wait for connection
      final completer = Completer<bool>();
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      _socket!.on('connect', (_) {
        debugPrint('✅ Connected to WebSocket server');
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      });

      _socket!.on('connect_error', (error) {
        debugPrint('❌ Connection error: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      return false;
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // Initial stream state
    _socket!.on('stream_state', (data) {
      debugPrint('📡 Received stream state: $data');
      _updateStateFromData(data);
    });

    // Stream starting
    _socket!.on('stream_starting', (data) {
      debugPrint('🟡 Stream starting...');
      _currentState = _currentState.copyWith(
        status: 'starting',
        products: _parseProducts(data['products']),
      );
      _notifyStateChange();
    });

    // Stream live
    _socket!.on('stream_live', (data) {
      debugPrint('🟢 Stream is LIVE!');
      _currentState = _currentState.copyWith(
        isActive: true,
        status: 'live',
        products: _parseProducts(data['products']),
        viewers: data['viewers'] ?? 0,
        startTime: data['startTime'] != null
            ? DateTime.parse(data['startTime'])
            : null,
      );
      _notifyStateChange();
    });

    // Stream ending
    _socket!.on('stream_ending', (data) {
      debugPrint('🟡 Stream ending...');
      _currentState = _currentState.copyWith(status: 'ending');
      _notifyStateChange();
    });

    // Stream ended
    _socket!.on('stream_ended', (data) {
      debugPrint('🔴 Stream ended');
      _currentState = StreamState(
        isActive: false,
        viewers: 0,
        products: [],
        status: 'offline',
      );
      _notifyStateChange();
    });

    // Products updated
    _socket!.on('products_updated', (data) {
      debugPrint('📦 Products updated');
      _currentState = _currentState.copyWith(
        products: _parseProducts(data['products']),
      );
      _notifyStateChange();
    });

    // Viewer count updated
    _socket!.on('viewer_update', (data) {
      debugPrint('👥 Viewers: ${data['viewers']}');
      _currentState = _currentState.copyWith(viewers: data['viewers'] ?? 0);
      _notifyStateChange();
    });

    // Admin connected/disconnected
    _socket!.on('admin_connected', (data) {
      debugPrint('👨‍💼 Admin connected');
    });

    _socket!.on('admin_disconnected', (data) {
      debugPrint('👨‍💼 Admin disconnected');
      _currentState = StreamState(
        isActive: false,
        viewers: 0,
        products: [],
        status: 'offline',
      );
      _notifyStateChange();
    });

    // Connection events
    _socket!.on('disconnect', (_) {
      debugPrint('❌ Disconnected from server');
    });

    _socket!.on('reconnect', (_) {
      debugPrint('🔄 Reconnected to server');
    });
  }

  void _updateStateFromData(dynamic data) {
    _currentState = StreamState(
      isActive: data['isActive'] ?? false,
      viewers: data['viewers'] ?? 0,
      products: _parseProducts(data['products']),
      status: data['status'] ?? 'offline',
      startTime: data['startTime'] != null
          ? DateTime.parse(data['startTime'])
          : null,
    );
    _notifyStateChange();
  }

  List<Product> _parseProducts(dynamic productsData) {
    if (productsData == null) return [];

    try {
      if (productsData is List) {
        return productsData
            .map((item) {
              if (item is Map<String, dynamic>) {
                return Product.fromMap(item);
              }
              return null;
            })
            .where((product) => product != null)
            .cast<Product>()
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error parsing products: $e');
    }

    return [];
  }

  void _notifyStateChange() {
    if (_stateController != null && !_stateController!.isClosed) {
      _stateController!.add(_currentState);
    }
  }

  // Admin methods
  void joinAsAdmin({String? adminName}) {
    if (_socket?.connected == true) {
      debugPrint('👨‍💼 Joining as admin');
      _socket!.emit('admin_join', {
        'name': adminName ?? 'Admin',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void startStream(List<Product> products) {
    if (_socket?.connected == true) {
      debugPrint('🔴 Starting stream with ${products.length} products');
      _socket!.emit('start_stream', {
        'products': products.map((p) => p.toMap()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void endStream() {
    if (_socket?.connected == true) {
      debugPrint('⚫ Ending stream');
      _socket!.emit('end_stream', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void updateProducts(List<Product> products) {
    if (_socket?.connected == true) {
      debugPrint('📦 Updating products: ${products.length}');
      _socket!.emit('update_products', {
        'products': products.map((p) => p.toMap()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // User methods
  void joinAsUser({String? userName}) {
    if (_socket?.connected == true) {
      debugPrint('👤 Joining as user');
      _socket!.emit('user_join', {
        'name': userName ?? 'User',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void addToCart(Product product) {
    if (_socket?.connected == true) {
      debugPrint('🛒 Adding to cart: ${product.name}');
      _socket!.emit('add_to_cart', {
        'product': product.toMap(),
        'productName': product.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Utility methods
  void ping() {
    if (_socket?.connected == true) {
      _socket!.emit('ping');
    }
  }

  void disconnect() {
    debugPrint('🔌 Disconnecting from WebSocket server');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    _stateController?.close();
    _stateController = null;
    disconnect();
  }
}

// Stream state data class - updated
class StreamState {
  final bool isActive;
  final int viewers;
  final List<Product> products;
  final String status;
  final DateTime? startTime;

  StreamState({
    required this.isActive,
    required this.viewers,
    required this.products,
    required this.status,
    this.startTime,
  });

  Duration get duration {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime!);
  }

  StreamState copyWith({
    bool? isActive,
    int? viewers,
    List<Product>? products,
    String? status,
    DateTime? startTime,
  }) {
    return StreamState(
      isActive: isActive ?? this.isActive,
      viewers: viewers ?? this.viewers,
      products: products ?? this.products,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  String toString() {
    return 'StreamState(isActive: $isActive, viewers: $viewers, '
        'products: ${products.length}, status: $status)';
  }
}
