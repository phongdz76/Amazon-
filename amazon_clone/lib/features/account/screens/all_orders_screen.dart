import 'package:amazon_clone/common/widgets/loader.dart';
import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/account/services/account_services.dart';
import 'package:amazon_clone/features/order_details/screens/order_details.dart';
import 'package:amazon_clone/features/search/screens/search_screen.dart';
import 'package:amazon_clone/models/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllOrdersScreen extends StatefulWidget {
  static const String routeName = '/all-orders';
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  List<Order>? orders;
  final AccountServices accountServices = AccountServices();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    orders = await accountServices.fetchMyOrders(context: context);
    setState(() {
      isLoading = false;
    });
  }

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  // Màu sắc theo trạng thái
  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Đang chờ
      case 1:
        return Colors.blue; // Đã xác nhận
      case 2:
        return Colors.purple; // Đang giao
      case 3:
        return Colors.green; // Đã giao
      case 4:
        return Colors.red; // Đã hủy
      default:
        return Colors.grey;
    }
  }

  // Text trạng thái
  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Card đơn hàng với thiết kế đẹp
  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(
              context,
              OrderDetailScreen.routeName,
              arguments: order,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                // Hình ảnh sản phẩm
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: order.products.isNotEmpty && order.products[0].images.isNotEmpty
                        ? Image.network(
                            order.products[0].images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.4),
                                  size: 32,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withOpacity(0.4),
                              size: 32,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // Thông tin đơn hàng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Số lượng sản phẩm và trạng thái
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.products.length > 1
                                ? '${order.products.length} items'
                                : '1 item',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order.status,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _getStatusColor(
                                  order.status,
                                ).withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Tên sản phẩm (nếu có)
                      Text(
                        order.products.isNotEmpty ? order.products[0].name : 'No product',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Tổng tiền và arrow
                      Row(
                        children: [
                          Text(
                            '\$${order.totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Trạng thái rỗng khi không có đơn hàng
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start shopping to see your orders here',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              'Start Shopping',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.getAppBarGradient(context),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      margin: const EdgeInsets.only(left: 15),
                      child: Material(
                        borderRadius: BorderRadius.circular(7),
                        elevation: 1,
                        child: TextFormField(
                          onFieldSubmitted: navigateToSearchScreen,
                          decoration: InputDecoration(
                            prefixIcon: InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.search,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 23,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.only(top: 10),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(7),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(7),
                              ),
                              borderSide: BorderSide(
                                color: Colors.black38,
                                width: 1,
                              ),
                            ),
                            hintText: 'Search Amazon.in',
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    height: 42,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.mic,
                      color: Theme.of(context).iconTheme.color,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: isLoading
              ? const Loader()
              : orders == null || orders!.isEmpty
              ? _buildEmptyState()
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).cardColor,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header với thiết kế đẹp hơn
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All Your Orders',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.headlineLarge?.color,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${orders!.length} orders found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: themeProvider
                                    .getSelectedNavBarColor(context)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: themeProvider
                                      .getSelectedNavBarColor(context)
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${orders!.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.getSelectedNavBarColor(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Danh sách đơn hàng
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            fetchOrders();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: orders!.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(orders![index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
