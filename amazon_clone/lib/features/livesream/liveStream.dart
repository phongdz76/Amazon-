// Updated LiveStreamShopPage that can be used directly in routing
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/features/home/services/home_services.dart';
import 'package:amazon_clone/features/product_details/services/product_details_service.dart';
import 'package:amazon_clone/common/widgets/loader.dart';
import 'package:amazon_clone/common/widgets/stars.dart';
// Import WebSocket service
import 'websocket_service.dart';

class LiveStreamShopPage extends StatefulWidget {
  static const String routeName = '/live-stream-shop';

  final List<CameraDescription>? cameras;

  const LiveStreamShopPage({super.key, this.cameras});

  @override
  State<LiveStreamShopPage> createState() => _LiveStreamShopPageState();
}

class _LiveStreamShopPageState extends State<LiveStreamShopPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  int _viewerCount = 0;
  bool _isCameraInitialized = false;
  bool _isVirtualCamera = false;
  bool _isStreamActive = false;

  // Camera management
  List<CameraDescription> _cameras = [];
  bool _isLoadingCameras = false;

  // WebSocket service
  final WebSocketService _webSocketService = WebSocketService.instance;
  StreamSubscription<StreamState>? _streamSubscription;

  // Real products from API
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  final HomeServices _homeServices = HomeServices();
  final ProductDetailsService _productDetailsService = ProductDetailsService();

  @override
  void initState() {
    super.initState();
    _initializeCamerasAndSetup();
  }

  Future<void> _initializeCamerasAndSetup() async {
    // If cameras were passed, use them; otherwise, try to get them
    if (widget.cameras != null) {
      _cameras = widget.cameras!;
    } else {
      setState(() => _isLoadingCameras = true);
      try {
        _cameras = await availableCameras();
      } catch (e) {
        debugPrint('Error getting cameras: $e');
        _cameras = [];
      }
      setState(() => _isLoadingCameras = false);
    }

    _isVirtualCamera =
        _cameras.isEmpty ||
        (_cameras.isNotEmpty && _cameras.first.name.contains('Virtual'));

    _initWebSocket();
    _initCamera();
    _fetchProducts();
  }

  Future<void> _initWebSocket() async {
    debugPrint('🔗 Initializing WebSocket connection...');

    // Change this IP to your Windows machine IP
    final connected = await _webSocketService.connect(
      serverUrl: 'http://192.168.1.100:3000', // Change this IP
    );

    if (connected) {
      debugPrint('✅ WebSocket connected successfully');

      // Join as admin
      _webSocketService.joinAsAdmin(adminName: 'Admin');

      // Listen to stream state changes
      _streamSubscription = _webSocketService.stateStream.listen((state) {
        if (!mounted) return;

        setState(() {
          _viewerCount = state.viewers;
          _isStreamActive = state.isActive;
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Kết nối WebSocket thành công!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      debugPrint('❌ WebSocket connection failed');
      if (mounted) {
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
      }
    }
  }

  Future<void> _initCamera() async {
    if (_isVirtualCamera || _cameras.isEmpty) {
      setState(() => _isCameraInitialized = false);
      return;
    }

    try {
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initializeControllerFuture = _controller!
          .initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _isCameraInitialized = true);
          })
          .catchError((e) {
            debugPrint('Camera initialization error: $e');
            if (mounted) {
              setState(() {
                _isVirtualCamera = true;
                _isCameraInitialized = false;
              });
            }
          });
    } catch (e) {
      debugPrint('Camera controller creation error: $e');
      if (mounted) {
        setState(() {
          _isVirtualCamera = true;
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await _homeServices.fetchAllProducts(
        context: context,
      );

      if (mounted) {
        setState(() {
          _products = fetchedProducts;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products for live stream: $e');
      if (mounted) {
        setState(() {
          _products = [];
          _isLoadingProducts = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load products. Please try again!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startLiveStream() {
    if (!_webSocketService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa kết nối WebSocket server!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có sản phẩm để livestream!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    debugPrint('🔴 Admin starting livestream...');

    // Start stream via WebSocket
    _webSocketService.startStream(_products);

    setState(() {
      _isStreamActive = true;
    });

    // Start duration timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentDuration = Duration(seconds: _currentDuration.inSeconds + 1);
      });
    });

    String platformMessage = '';
    if (_isVirtualCamera) {
      platformMessage = ' (Demo Mode - Virtual Machine)';
    } else {
      platformMessage = Platform.isWindows
          ? ' (Windows Admin)'
          : Platform.isAndroid
          ? ' (Android Admin)'
          : '';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.fiber_manual_record,
              color: _isVirtualCamera ? Colors.orange : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text('Live Stream đã bắt đầu!$platformMessage'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _endLiveStream() {
    debugPrint('⚫ Admin ending livestream...');

    // End stream via WebSocket
    _webSocketService.endStream();

    setState(() {
      _isStreamActive = false;
      _currentDuration = Duration.zero;
    });

    _timer?.cancel();
    _timer = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.tv_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Live Stream đã kết thúc'),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updateStreamProducts() {
    if (_isStreamActive && _webSocketService.isConnected) {
      debugPrint('📦 Admin updating stream products...');
      _webSocketService.updateProducts(_products);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật sản phẩm cho stream!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
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

  Widget _buildVirtualCameraView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (_isStreamActive ? Colors.red : Colors.orange).withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Main content
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isStreamActive ? Icons.videocam : Icons.computer,
                    size: 80,
                    color: _isStreamActive ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isStreamActive ? 'ĐANG LIVESTREAM' : 'CAMERA MÔ PHỎNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isStreamActive
                        ? 'Admin đang livestream'
                        : 'Chế độ Demo cho máy ảo',
                    style: TextStyle(
                      color: _isStreamActive ? Colors.red : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isStreamActive ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isStreamActive ? 'LIVE' : 'DEMO MODE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Connection status
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _webSocketService.isConnected
                    ? Colors.green
                    : Colors.red,
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
                    _webSocketService.isConnected ? 'Connected' : 'Offline',
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
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
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

            // Admin indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSubscription?.cancel();
    _controller?.dispose();

    // End stream when admin leaves
    if (_isStreamActive) {
      _webSocketService.endStream();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCameras) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing cameras...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.fiber_manual_record,
              color: _isStreamActive
                  ? (_isVirtualCamera ? Colors.orange : Colors.red)
                  : Colors.grey,
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
                color: _isStreamActive
                    ? (_isVirtualCamera ? Colors.orange : Colors.red)
                          .withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isStreamActive
                      ? (_isVirtualCamera ? Colors.orange : Colors.red)
                      : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                _isStreamActive ? 'LIVE' : 'OFFLINE',
                style: TextStyle(
                  color: _isStreamActive
                      ? (_isVirtualCamera ? Colors.orange : Colors.red)
                      : Colors.grey,
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

          if (!_isVirtualCamera && _cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.switch_camera, color: Colors.white),
              onPressed: () {
                final newLensDirection =
                    _controller!.description.lensDirection ==
                        CameraLensDirection.back
                    ? CameraLensDirection.front
                    : CameraLensDirection.back;

                final camera = _cameras.firstWhere(
                  (c) => c.lensDirection == newLensDirection,
                  orElse: () => _cameras.first,
                );

                _controller = CameraController(
                  camera,
                  ResolutionPreset.high,
                  enableAudio: true,
                  imageFormatGroup: ImageFormatGroup.yuv420,
                );

                setState(() {
                  _isCameraInitialized = false;
                  _initializeControllerFuture = _controller!.initialize().then((
                    _,
                  ) {
                    if (mounted) {
                      setState(() => _isCameraInitialized = true);
                    }
                  });
                });
              },
            ),

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoadingProducts = true;
              });
              _fetchProducts();
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
          // Camera/Stream View
          Expanded(
            flex: 3,
            child: _isVirtualCamera
                ? _buildVirtualCameraView()
                : FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (_isCameraInitialized && _controller != null) {
                          return Stack(
                            children: [
                              CameraPreview(_controller!),
                              if (_isStreamActive)
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'LIVE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Camera không khả dụng',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 50,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Lỗi camera: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                Platform.isWindows
                                    ? 'Starting Windows camera...'
                                    : 'Starting camera...',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ),

          // Control Panel & Products
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Control buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isStreamActive
                                ? null
                                : _startLiveStream,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Bắt đầu Live'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isStreamActive ? _endLiveStream : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Kết thúc Live'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isStreamActive
                              ? _updateStreamProducts
                              : null,
                          icon: const Icon(Icons.sync),
                          label: const Text('Cập nhật'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Products list
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Sản phẩm livestream',
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
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'ADMIN VIEW',
                                  style: TextStyle(
                                    color: Colors.blue,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Chưa có sản phẩm',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: _fetchProducts,
                                          child: const Text('Tải lại'),
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
            ),
          ),
        ],
      ),
    );
  }
}
