import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/features/home/services/home_services.dart';
import 'package:amazon_clone/features/product_details/services/product_details_service.dart';
import 'package:amazon_clone/common/widgets/loader.dart';
import 'package:amazon_clone/common/widgets/stars.dart';

// Global cameras variable for compatibility with Windows approach
List<CameraDescription> _globalCameras = [];

class LiveStreamHomePage extends StatelessWidget {
  static const String routeName = '/live-stream';
  const LiveStreamHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>>(
      future: _initializeGlobalCameras(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(context, snapshot.error.toString());
        }

        final cameras = snapshot.data ?? [];
        return _buildMainScreen(context, cameras);
      },
    );
  }

  Future<List<CameraDescription>> _initializeGlobalCameras() async {
    try {
      final camerasList = await availableCameras();

      if (camerasList.isEmpty) {
        debugPrint('No physical cameras found, creating virtual camera');
        _globalCameras = [
          const CameraDescription(
            name: 'Virtual Camera (Máy ảo)',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ];
      } else {
        _globalCameras = camerasList;
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      debugPrint('Creating fallback virtual camera');
      _globalCameras = [
        const CameraDescription(
          name: 'Virtual Camera (Fallback)',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
      ];
    }

    return _globalCameras;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Live Stream Shop'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang khởi tạo camera...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Live Stream Shop'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi khởi tạo camera: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, routeName);
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen(
    BuildContext context,
    List<CameraDescription> cameras,
  ) {
    final isVirtualCamera =
        cameras.isNotEmpty && cameras.first.name.contains('Virtual');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Live Stream Shop'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isVirtualCamera ? Colors.orange : Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isVirtualCamera ? Colors.orange : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isVirtualCamera ? Icons.computer : Icons.videocam,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              isVirtualCamera ? 'Live Stream (Demo Mode)' : 'Start Live Stream',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isVirtualCamera
                  ? 'Running on virtual machine - Simulated camera'
                  : 'Livestream and sell products online',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (isVirtualCamera) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  '⚠️ No physical camera found',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () => _startLiveStream(context, cameras),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVirtualCamera ? Colors.orange : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                  shadowColor: (isVirtualCamera ? Colors.orange : Colors.red)
                      .withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      isVirtualCamera
                          ? 'Bắt đầu Demo Stream'
                          : 'Start Live Stream',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startLiveStream(BuildContext context, List<CameraDescription> cameras) {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy camera!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isVirtualCamera = cameras.first.name.contains('Virtual');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: isVirtualCamera ? Colors.orange : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isVirtualCamera
                      ? 'Starting Demo Stream...'
                      : 'Starting Live Stream...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveStreamShopPage(cameras: cameras),
        ),
      );
    });
  }
}

class LiveStreamShopPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const LiveStreamShopPage({super.key, required this.cameras});

  @override
  State<LiveStreamShopPage> createState() => _LiveStreamShopPageState();
}

class _LiveStreamShopPageState extends State<LiveStreamShopPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late StreamController<Duration> _durationController;
  late StreamController<List<Product>> _productController;
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  int _viewerCount = 5;
  bool _isCameraInitialized = false;
  bool _isVirtualCamera = false;

  // Real products from API
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  final HomeServices _homeServices = HomeServices();

  // Add ProductDetailsService for cart functionality
  final ProductDetailsService _productDetailsService = ProductDetailsService();

  @override
  void initState() {
    super.initState();
    _durationController = StreamController<Duration>();
    _productController = StreamController<List<Product>>();
    _isVirtualCamera =
        widget.cameras.isNotEmpty &&
        widget.cameras.first.name.contains('Virtual');
    _initCamera();
    _fetchProducts(); // Fetch real products
  }

  // Fetch real products from API
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

        // Update stream with real products
        if (!_productController.isClosed) {
          _productController.add(_products);
        }
      }
    } catch (e) {
      debugPrint('Error fetching products for live stream: $e');
      if (mounted) {
        setState(() {
          _products = [];
          _isLoadingProducts = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load products. Please try again!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initCamera() async {
    if (_isVirtualCamera) {
      setState(() => _isCameraInitialized = false);
      _startLiveStream();
      return;
    }

    try {
      _controller = CameraController(
        widget.cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initializeControllerFuture = _controller!
          .initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _isCameraInitialized = true);
            _startLiveStream();
          })
          .catchError((e) {
            debugPrint('Camera initialization error: $e');
            if (mounted) {
              setState(() {
                _isVirtualCamera = true;
                _isCameraInitialized = false;
              });
              _startLiveStream();
            }
          });
    } catch (e) {
      debugPrint('Camera controller creation error: $e');
      if (mounted) {
        setState(() {
          _isVirtualCamera = true;
          _isCameraInitialized = false;
        });
        _startLiveStream();
      }
    }
  }

  void _startLiveStream() {
    if (!mounted) return;

    String platformMessage = '';
    if (_isVirtualCamera) {
      platformMessage = ' (Chế độ Demo - Máy ảo)';
    } else {
      platformMessage = Platform.isWindows
          ? ' (Windows)'
          : Platform.isAndroid
          ? ' (Android)'
          : Platform.isIOS
          ? ' (iOS)'
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
            Text('Live Stream has started!$platformMessage'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Start timer for stream duration and viewer count
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _currentDuration = Duration(seconds: _currentDuration.inSeconds + 1);
      if (!_durationController.isClosed) {
        _durationController.add(_currentDuration);
      }

      if (timer.tick % 5 == 0) {
        setState(() {
          _viewerCount += (timer.tick % 2 == 0) ? 1 : -1;
        });
      }
    });
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

  // Updated _addToCart method to actually add to cart
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
                  // Navigate to cart screen
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

  Widget _buildVirtualCameraView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.computer, size: 80, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'CAMERA MÔ PHỎNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chế độ Demo cho máy ảo',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DEMO MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                        '\$',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  // Stock Status
                  Text(
                    product.quantity > 0
                        ? 'In Stock (${product.quantity.toInt()})'
                        : 'Out of Stock',
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

            // Add to Cart Button - Updated with loading state
            ElevatedButton(
              onPressed: product.quantity > 0
                  ? () => _addToCart(product)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVirtualCamera ? Colors.orange : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 32),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: const Text('Thêm vào giỏ', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _durationController.close();
    _productController.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: StreamBuilder<Duration>(
          stream: _durationController.stream,
          initialData: Duration.zero,
          builder: (context, snapshot) {
            return Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  color: _isVirtualCamera ? Colors.orange : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(snapshot.data!),
                  style: const TextStyle(color: Colors.white),
                ),
                if (_isVirtualCamera) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: const Text(
                      'DEMO',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_viewerCount',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        actions: [
          if (!_isVirtualCamera && widget.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.switch_camera, color: Colors.white),
              onPressed: () {
                final newLensDirection =
                    _controller!.description.lensDirection ==
                        CameraLensDirection.back
                    ? CameraLensDirection.front
                    : CameraLensDirection.back;

                final camera = widget.cameras.firstWhere(
                  (c) => c.lensDirection == newLensDirection,
                  orElse: () => widget.cameras.first,
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
          // Add cart icon to show cart count (optional)
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
          Expanded(
            flex: 3,
            child: _isVirtualCamera
                ? _buildVirtualCameraView()
                : FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (_isCameraInitialized && _controller != null) {
                          return CameraPreview(_controller!);
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
                        'Products for Sale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isVirtualCamera) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Demo',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (!_isLoadingProducts)
                        Text(
                          '${_products.length} products',
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
                                  Icons.shopping_bag_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _fetchProducts,
                                  child: const Text('Try Again'),
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
