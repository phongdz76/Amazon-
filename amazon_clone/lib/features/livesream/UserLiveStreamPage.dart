// Updated UserLiveStreamPage with WebSocket
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/features/home/services/home_services.dart';
import 'package:amazon_clone/features/product_details/services/product_details_service.dart';
import 'package:amazon_clone/common/widgets/loader.dart';
import 'package:amazon_clone/common/widgets/stars.dart';
// Import WebSocket service
import 'websocket_service.dart';

class UserLiveStreamPage extends StatefulWidget {
  static const String routeName = '/user-live-stream';
  const UserLiveStreamPage({Key? key}) : super(key: key);

  @override
  State<UserLiveStreamPage> createState() => _UserLiveStreamPageState();
}

class _UserLiveStreamPageState extends State<UserLiveStreamPage> {
  Timer? _refreshTimer;
  Duration _currentDuration = Duration.zero;
  int _viewerCount = 0;
  List<Product> _products = [];
  bool _isConnected = false;
  bool _isLoading = true;
  String _streamStatus = 'offline';

  // WebSocket service
  final WebSocketService _webSocketService = WebSocketService.instance;
  StreamSubscription<StreamState>? _streamSubscription;

  // Fallback products if WebSocket fails
  bool _isLoadingProducts = false;
  final HomeServices _homeServices = HomeServices();
  final ProductDetailsService _productDetailsService = ProductDetailsService();

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _startRefreshTimer();
  }

  Future<void> _connectToWebSocket() async {
    setState(() => _isLoading = true);

    debugPrint('🔗 User connecting to WebSocket...');
    
    // Thay đổi IP này thành IP máy Windows của bạn
    final connected = await _webSocketService.connect(
      serverUrl: 'http://192.168.1.100:3000' // Thay IP này
    );

    if (connected) {
      debugPrint('✅ User WebSocket connected successfully');
      
      // Join as user
      _webSocketService.joinAsUser(userName: 'User');
      
      // Listen to stream state changes
      _streamSubscription = _webSocketService.stateStream.listen((state) {
        if (!mounted) return;

        setState(() {
          _isConnected = state.isActive && state.status == 'live';
          _products = List.from(state.products);
          _viewerCount = state.viewers;
          _currentDuration = state.duration;
          _streamStatus = state.status;
          _isLoading = false;
        });

        // Handle stream status changes
        if (state.status == 'starting') {
          _showStreamStartingMessage();
        } else if (state.status == 'ending' ||
            (state.status == 'offline' && _isConnected)) {
          _handleStreamEnded();
        } else if (state.status == 'live' && !_isConnected) {
          _handleStreamStarted();
        }
      });

      setState(() => _isLoading = false);
      
      // Check initial state
      final currentState = _webSocketService.currentState;
      if (currentState.isActive && currentState.status == 'live') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.live_tv, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Kết nối live stream thành công!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String message;
        Color color;

        switch (currentState.status) {
          case 'starting':
            message = 'Admin đang chuẩn bị live stream...';
            color = Colors.orange;
            break;
          case 'ending':
            message = 'Live stream đang kết thúc...';
            color = Colors.orange;
            break;
          default:
            message = 'Không có live stream. Hiển thị chế độ demo.';
            color = Colors.orange;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _connectToWebSocket,
            ),
          ),
        );
        
        // Load fallback products
        _fetchFallbackProducts();
      }
    } else {
      debugPrint('❌ User WebSocket connection failed');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Không thể kết nối WebSocket server!'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      
      // Load fallback products
      _fetchFallbackProducts();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Ping WebSocket to keep connection alive
      if (_webSocketService.isConnected) {
        _webSocketService.ping();
      } else {
        // Try to reconnect
        debugPrint('🔄 WebSocket disconnected, trying to reconnect...');
        _connectToWebSocket();
      }
    });
  }

  void _showStreamStartingMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text('Admin đang chuẩn bị live stream...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleStreamStarted() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.live_tv, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Live stream đã bắt đầu!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleStreamEnded() {
    if (!mounted) return;

    setState(() {
      _isConnected = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.tv_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Live stream đã kết thúc'),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );

    // Clear products after showing message
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isConnected) {
        setState(() {
          _products.clear();
          _viewerCount = 0;
        });
      }
    });
  }

  // Fallback method to load products from API
  Future<void> _fetchFallbackProducts() async {
    setState(() => _isLoadingProducts = true);

    try {
      final fetchedProducts = await _homeServices.fetchAllProducts(
        context: context,
      );

      if (mounted) {
        setState(() {
          _products = fetchedProducts;
          _isLoadingProducts = false;
          _viewerCount = 125; // Simulated for demo
        });
      }
    } catch (e) {
      debugPrint('Error fetching fallback products: $e');
      if (mounted) {
        setState(() {
          _products = [];
          _isLoadingProducts = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  double _calculateAverageRating(Product product) {
    if (product.rating == null || product.rating!.isEmpty) {
      return 0.0;
    }
    double totalRating = 0;
    for (int i = 0; i < product.rating!.length; i++) {
      totalRating += product.rating![i].rating;
    }
    return totalRating / product.rating!.length;
  }

  void _addToCart(Product product) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Add product to cart using ProductDetailsService
      _productDetailsService.addToCart(context: context, product: product);
      
      // Notify WebSocket about cart activity
      if (_webSocketService.isConnected) {
        _webSocketService.addToCart(product);
      }

      // Close loading dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã thêm "${product.name}" vào giỏ hàng',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Xem giỏ hàng',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ),
          );
        }
      });
    } catch (e) {
      // Close loading dialog if open
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error adding product to cart: ${e.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _addToCart(product),
              ),
            ),
          );
        }
      });
    }
  }

  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'Đang kết nối WebSocket...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStreamView() {
    String message;
    IconData icon;
    String subtitle;

    switch (_streamStatus) {
      case 'starting':
        icon = Icons.hourglass_empty;
        message = 'Đang chuẩn bị...';
        subtitle = 'Admin đang khởi động live stream';
        break;
      case 'ending':
        icon = Icons.tv_off;
        message = 'Đang kết thúc...';
        subtitle = 'Live stream sắp kết thúc';
        break;
      default:
        icon = Icons.tv_off;
        message = 'Không có live stream';
        subtitle = 'Hiện tại không có live stream nào đang hoạt động';
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade800, Colors.grey.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _connectToWebSocket,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.8),
            Colors.purple.withOpacity(0.8),
            Colors.pink.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background effect
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Live indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_isConnected ? Colors.red : Colors.orange)
                            .withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected ? 'LIVE' : 'DEMO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Main content
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.live_tv, size: 80, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        _isConnected
                            ? 'LIVE SHOPPING STREAM'
                            : 'DEMO SHOPPING STREAM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isConnected
                            ? 'Đang xem từ Admin'
                            : 'Chế độ demo - Không có live stream',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stream info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isConnected
                                  ? '🎥 Kết nối với Admin Stream'
                                  : '📱 Chế độ Demo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isConnected
                                  ? 'Đang nhận dữ liệu trực tiếp từ Admin'
                                  : 'Hiển thị sản phẩm mẫu',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Connection status indicator
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _webSocketService.isConnected ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _webSocketService.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _webSocketService.isConnected ? 'WebSocket' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating elements for effect
          Positioned(
            top: 100,
            right: 50,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 30,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    final avgRating = _calculateAverageRating(product);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      Stars(rating: avgRating),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.rating?.length ?? 0})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Row(
                    children: [
                      const Text(
                        '₫',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  // Stock Status
                  Text(
                    product.quantity > 0
                        ? 'Còn hàng (${product.quantity.toInt()})'
                        : 'Hết hàng',
                    style: TextStyle(
                      fontSize: 11,
                      color: product.quantity > 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            ElevatedButton(
              onPressed: product.quantity > 0
                  ? () => _addToCart(product)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 32),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: const Text('Mua ngay', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.fiber_manual_record,
              color: _isConnected ? Colors.red : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(_currentDuration),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (_isConnected ? Colors.blue : Colors.orange).withOpacity(
                  0.2,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isConnected ? Colors.blue : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                _isConnected ? 'LIVE' : 'DEMO',
                style: TextStyle(
                  color: _isConnected ? Colors.blue : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            const Icon(Icons.people, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text('$_viewerCount', style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        actions: [
          // WebSocket connection indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _webSocketService.isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _webSocketService.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  _webSocketService.isConnected ? 'WS' : 'OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoadingProducts = true;
              });
              _connectToWebSocket();
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Stream View
          Expanded(
            flex: 3,
            child: _isLoading
                ? _buildLoadingView()
                : _isConnected || _products.isNotEmpty
                ? _buildLiveStreamView()
                : _buildNoStreamView(),
          ),

          // Products List
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Sản phẩm trong live stream',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (_isConnected ? Colors.blue : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (_isConnected ? Colors.blue : Colors.orange)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _isConnected ? 'Live Shopping' : 'Demo Mode',
                          style: TextStyle(
                            color: _isConnected ? Colors.blue : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoadingProducts)
                        Text(
                          '${_products.length} sản phẩm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isLoadingProducts
                        ? const Center(child: Loader())
                        : _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _streamStatus == 'starting'
                                      ? Icons.hourglass_empty
                                      : Icons.shopping_bag_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _streamStatus == 'starting'
                                      ? 'Đang chuẩn bị sản phẩm...'
                                      : 'Chưa có sản phẩm nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _connectToWebSocket,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _buildProductItem(product);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}