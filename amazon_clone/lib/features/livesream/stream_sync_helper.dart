// stream_sync_helper.dart
import 'dart:async';
import 'package:amazon_clone/models/product.dart';

class StreamSyncHelper {
  static bool _isStreamActive = false;
  static int _currentViewers = 0;
  static List<Product> _currentProducts = [];
  static String _streamStatus =
      'offline'; // 'offline', 'starting', 'live', 'ending'
  static DateTime? _streamStartTime;
  static StreamController<StreamState>? _stateController;

  // Stream state class
  static StreamState get currentState => StreamState(
    isActive: _isStreamActive,
    viewers: _currentViewers,
    products: List.from(_currentProducts),
    status: _streamStatus,
    startTime: _streamStartTime,
  );

  // Getters
  static bool get isStreamActive => _isStreamActive;
  static int get currentViewers => _currentViewers;
  static List<Product> get currentProducts => List.from(_currentProducts);
  static String get streamStatus => _streamStatus;
  static DateTime? get streamStartTime => _streamStartTime;

  // Stream for real-time updates
  static Stream<StreamState> get stateStream {
    _stateController ??= StreamController<StreamState>.broadcast();
    return _stateController!.stream;
  }

  // Admin methods
  static void startStream(List<Product> products) {
    print('🔴 ADMIN: Starting live stream with ${products.length} products');
    _streamStatus = 'starting';
    _notifyStateChange();

    // Simulate startup delay
    Future.delayed(const Duration(seconds: 2), () {
      _isStreamActive = true;
      _currentProducts = List.from(products);
      _currentViewers = 1; // Admin counts as viewer
      _streamStatus = 'live';
      _streamStartTime = DateTime.now();
      print('🔴 ADMIN: Live stream is now LIVE!');
      _notifyStateChange();
    });
  }

  static void endStream() {
    print('⚫ ADMIN: Ending live stream...');
    _streamStatus = 'ending';
    _notifyStateChange();

    Future.delayed(const Duration(seconds: 1), () {
      _isStreamActive = false;
      _currentProducts.clear();
      _currentViewers = 0;
      _streamStatus = 'offline';
      _streamStartTime = null;
      print('⚫ ADMIN: Live stream ended');
      _notifyStateChange();
    });
  }

  static void updateProducts(List<Product> products) {
    if (_isStreamActive) {
      _currentProducts = List.from(products);
      print('📦 ADMIN: Updated stream products (${products.length} items)');
      _notifyStateChange();
    }
  }

  // User methods
  static bool joinStream() {
    if (_isStreamActive && _streamStatus == 'live') {
      _currentViewers++;
      print('👤 USER: Joined stream. Total viewers: $_currentViewers');
      _notifyStateChange();
      return true;
    }
    print('❌ USER: No active stream to join (Status: $_streamStatus)');
    return false;
  }

  static void leaveStream() {
    if (_currentViewers > 1) {
      // Keep at least admin
      _currentViewers--;
      print('👋 USER: Left stream. Total viewers: $_currentViewers');
      _notifyStateChange();
    }
  }

  // Private helper
  static void _notifyStateChange() {
    if (_stateController != null && !_stateController!.isClosed) {
      _stateController!.add(currentState);
    }
  }

  // Cleanup
  static void dispose() {
    _stateController?.close();
    _stateController = null;
  }
}

// Stream state data class
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
}
