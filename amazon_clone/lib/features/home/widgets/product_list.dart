import 'package:amazon_clone/common/widgets/loader.dart';
import 'package:amazon_clone/common/widgets/stars.dart';
import 'package:amazon_clone/features/home/services/home_services.dart';
import 'package:amazon_clone/features/product_details/screens/product_details_screen.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:flutter/material.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product>? products;
  final HomeServices homeServices = HomeServices();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  void fetchAllProducts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedProducts = await homeServices.fetchAllProducts(
        context: context,
      );
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          products = [];
          isLoading = false;
        });
      }
    }
  }

  void navigateToProductDetails(Product product) {
    Navigator.pushNamed(
      context,
      ProductDetailsScreen.routeName,
      arguments: product,
    );
  }

  double calculateAverageRating(Product product) {
    if (product.rating == null || product.rating!.isEmpty) {
      return 0.0;
    }
    double totalRating = 0;
    for (int i = 0; i < product.rating!.length; i++) {
      totalRating += product.rating![i].rating;
    }
    return totalRating / product.rating!.length;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(20.0), child: Loader()),
      );
    }

    if (products == null || products!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new arrivals',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${products!.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85, // Tỷ lệ tối ưu để tránh overflow
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products!.length,
            itemBuilder: (context, index) {
              final product = products![index];
              final avgRating = calculateAverageRating(product);

              return Hero(
                tag: 'product-${product.id ?? 'product-$index'}',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => navigateToProductDetails(product),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      product.images.isNotEmpty
                                          ? product.images[0]
                                          : '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey.shade50,
                                          child: Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.orange.shade400),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade50,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey.shade400,
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'No Image',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // HOT Badge
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'HOT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Product Details - FIXED OVERFLOW
                          Expanded(
                            flex: 4, // Tăng flex để có nhiều không gian hơn
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize
                                    .min, // Quan trọng để tránh overflow
                                children: [
                                  // Product Name
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 12, // Giảm size để fit better
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                        height: 1.2, // Line height tối ưu
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4), // Giảm spacing
                                  // Rating
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Stars(rating: avgRating),
                                      ), // Flexible để tránh overflow
                                      const SizedBox(width: 3),
                                      Text(
                                        '(${product.rating?.length ?? 0})',
                                        style: TextStyle(
                                          fontSize: 10, // Giảm size
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withOpacity(0.7),
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
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product.price.toStringAsFixed(0),
                                        style: const TextStyle(
                                          fontSize: 15, // Giảm từ 16
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(), // Đẩy stock status xuống cuối
                                  // Stock Status
                                  Text(
                                    product.quantity > 0
                                        ? 'In Stock (${product.quantity.toInt()})'
                                        : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 9, // Size nhỏ để fit
                                      color: product.quantity > 0
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                      fontWeight: FontWeight.w500,
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
