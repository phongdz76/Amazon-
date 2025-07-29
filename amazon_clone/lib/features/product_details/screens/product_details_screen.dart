import 'dart:convert';
import 'package:amazon_clone/common/widgets/stars.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/account/services/wishlist_services.dart';
import 'package:amazon_clone/features/address/screens/address_screen.dart'; // Thêm import này
import 'package:amazon_clone/features/product_details/services/product_details_service.dart';
import 'package:amazon_clone/features/search/screens/search_screen.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/models/user.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductDetailsService productDetailsService = ProductDetailsService();
  final WishlistServices wishlistServices = WishlistServices();
  double avgRating = 0;
  double myRating = 0;
  bool isInWishlist = false;

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  // Thêm hàm này để navigate đến AddressScreen
  void navigateToAddress(int sum) {
    Navigator.pushNamed(
      context,
      AddressScreen.routeName,
      arguments: sum.toString(),
    );
  }

  // Thêm hàm này để xử lý Buy Now
  void buyNow() async {
    try {
      // Hiển thị loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing...'),
              ],
            ),
          );
        },
      );

      // Thêm sản phẩm vào cart
      await _addToCartAsync();

      // Đóng loading dialog
      if (mounted) Navigator.of(context).pop();

      // Tính tổng giá của cart sau khi thêm sản phẩm
      final user = Provider.of<UserProvider>(context, listen: false).user;
      double sum = 0;
      for (var item in user.cart) {
        if (item['quantity'] != null &&
            item['product'] != null &&
            item['product']['price'] != null) {
          int quantity = item['quantity'] as int;
          double price = (item['product']['price'] as num).toDouble();
          sum += quantity * price;
        }
      }

      // Navigate đến address screen với tổng giá
      if (mounted) {
        navigateToAddress(sum.toInt());
      }
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm async để thêm sản phẩm vào cart
  Future<void> _addToCartAsync() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final response = await http.post(
      Uri.parse('$uri/api/add-to-cart'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
      body: jsonEncode({'id': widget.product.id!}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      User updatedUser = userProvider.user.copyWith(cart: responseData['cart']);
      userProvider.setUserFromModel(updatedUser);
    } else {
      throw Exception('Failed to add product to cart');
    }
  }

  @override
  void initState() {
    super.initState();
    double totalRating = 0;
    for (int i = 0; i < widget.product.rating!.length; i++) {
      totalRating += widget.product.rating![i].rating;
      if (widget.product.rating![i].userId ==
          Provider.of<UserProvider>(context, listen: false).user.id) {
        myRating = widget.product.rating![i].rating;
      }
    }

    if (totalRating != 0) {
      avgRating = totalRating / widget.product.rating!.length;
    }

    // Check if product is in wishlist
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.wishlist != null) {
      isInWishlist = user.wishlist!.contains(widget.product.id);
    }
  }

  void addToCart() {
    productDetailsService.addToCart(context: context, product: widget.product);
  }

  void toggleWishlist() {
    if (isInWishlist) {
      wishlistServices.removeFromWishlist(
        context: context,
        productId: widget.product.id!,
      );
    } else {
      wishlistServices.addToWishlist(
        context: context,
        productId: widget.product.id!,
      );
    }
    setState(() {
      isInWishlist = !isInWishlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.getAppBarGradient(context),
            ),
          ),
          iconTheme: IconThemeData(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 10),
                  child: Material(
                    borderRadius: BorderRadius.circular(25),
                    elevation: 2,
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    child: TextFormField(
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.search,
                              color: themeProvider.getTextSecondaryColor(
                                context,
                              ),
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25),
                          ),
                          borderSide: BorderSide(
                            color: themeProvider.isDarkMode
                                ? AppColors.darkDividerColor
                                : Colors.black38,
                            width: 1,
                          ),
                        ),
                        hintText: 'Search Amazon.in',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                          color: themeProvider.getTextSecondaryColor(context),
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
                child: IconButton(
                  onPressed: toggleWishlist,
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist
                        ? Colors.red
                        : (themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black54),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [themeProvider.getCardShadow(context)],
                border: Border.all(
                  color: themeProvider.getBorderColor(context),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: themeProvider.getHeadingStyle(
                        context,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Stars(rating: avgRating),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: themeProvider
                              .getAmazonOrangeColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${avgRating.toStringAsFixed(1)} ⭐',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getAmazonOrangeColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Image Carousel with enhanced styling
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [themeProvider.getCardShadow(context)],
                border: Border.all(
                  color: themeProvider.getBorderColor(context),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CarouselSlider(
                  items: widget.product.images.map((i) {
                    return Builder(
                      builder: (BuildContext context) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          i,
                          fit: BoxFit.contain,
                          height: 280,
                          width: double.infinity,
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    viewportFraction: 1,
                    height: 280,
                    autoPlay: false,
                    enlargeCenterPage: true,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Price and Description Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [themeProvider.getCardShadow(context)],
                border: Border.all(
                  color: themeProvider.getBorderColor(context),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.isDarkMode
                            ? [
                                Colors.red.withOpacity(0.2),
                                Colors.orange.withOpacity(0.2),
                              ]
                            : [
                                Colors.red.withOpacity(0.1),
                                Colors.orange.withOpacity(0.1),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Deal Price: ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: '\$${widget.product.price}',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: themeProvider.getHeadingStyle(context, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.getTextSecondaryColor(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [themeProvider.getCardShadow(context)],
                border: Border.all(
                  color: themeProvider.getBorderColor(context),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  // Buy Now Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9900), Color(0xFFFF6B35)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: buyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Add to Cart Button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(254, 216, 19, 1),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.black87,
                              size: 20,
                            ),
                            label: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Wishlist Button
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isInWishlist
                              ? Colors.red
                              : (themeProvider.isDarkMode
                                    ? themeProvider.getSurfaceVariantColor(
                                        context,
                                      )
                                    : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: (isInWishlist ? Colors.red : Colors.grey)
                                  .withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: toggleWishlist,
                          icon: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist
                                ? Colors.white
                                : themeProvider.getTextSecondaryColor(context),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rating Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [themeProvider.getCardShadow(context)],
                border: Border.all(
                  color: themeProvider.getBorderColor(context),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rate,
                        color: themeProvider.getAmazonOrangeColor(context),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rate This Product',
                        style: themeProvider.getHeadingStyle(
                          context,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingBar.builder(
                      initialRating: myRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 35,
                      glow: true,
                      glowColor: themeProvider
                          .getAmazonOrangeColor(context)
                          .withOpacity(0.5),
                      itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: themeProvider.getAmazonOrangeColor(context),
                      ),
                      onRatingUpdate: (rating) {
                        productDetailsService.rateProduct(
                          context: context,
                          product: widget.product,
                          rating: rating,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (myRating > 0)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: themeProvider
                              .getAmazonOrangeColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Your rating: ${myRating.toStringAsFixed(1)} ⭐',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: themeProvider.getAmazonOrangeColor(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
