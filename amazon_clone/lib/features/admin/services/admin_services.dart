import 'dart:convert';
import 'dart:io';
import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/features/admin/models/sales.dart';
import 'package:amazon_clone/models/order.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdminServices {
  Future<void> sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required double quantity,
    required String category,
    required List<File> images,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final cloudinary = CloudinaryPublic('dardtagt3', 'amazon_cloudinary');
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(images[i].path, folder: name),
        );
        imageUrls.add(res.secureUrl);
      }

      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: imageUrls,
        category: category,
        price: price,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/admin/add-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product added successfully!');
          if (onSuccess != null) {
            onSuccess();
          } else {
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      if (onError != null) {
        onError();
      }
    }
  }

  // get all the products
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-products'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            productList.add(
              Product.fromJson(jsonEncode(jsonDecode(res.body)[i])),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }

  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/delete-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': product.id}),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          onSuccess();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Get single product by ID
  Future<Product?> getProductById({
    required BuildContext context,
    required String productId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-product/$productId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (res.statusCode == 200) {
        return Product.fromJson(res.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return null;
  }

  // Edit/Update product
  Future<void> editProduct({
    required BuildContext context,
    required String productId,
    required String name,
    required String description,
    required double price,
    required double quantity,
    required String category,
    required List<File> newImages, // Ảnh mới được chọn
    required List<String> existingImageUrls, // Ảnh cũ giữ lại
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      List<String> finalImageUrls = List.from(existingImageUrls);

      // Upload ảnh mới lên Cloudinary nếu có
      if (newImages.isNotEmpty) {
        final cloudinary = CloudinaryPublic('dardtagt3', 'amazon_cloudinary');

        for (int i = 0; i < newImages.length; i++) {
          CloudinaryResponse res = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(newImages[i].path, folder: name),
          );
          finalImageUrls.add(res.secureUrl);
        }
      }

      // Tạo product object với thông tin mới
      Map<String, dynamic> productData = {
        'id': productId,
        'name': name,
        'description': description,
        'quantity': quantity,
        'images': finalImageUrls,
        'category': category,
        'price': price,
      };

      http.Response res = await http.put(
        Uri.parse('$uri/admin/edit-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(productData),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Fetch all orders
  /// Lấy danh sách tất cả các đơn hàng từ server
  Future<List<Order>> fetchAllOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-orders'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            orderList.add(Order.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return orderList;
  }

  // Change order status
  void changeOrderStatus({
    required BuildContext context,
    required int status,
    required Order order,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/change-order-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': order.id, 'status': status}),
      );

      httpErrorHand(response: res, context: context, onSuccess: onSuccess);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Change order status for user (cancel order)
  void changeOrderStatusUser({
    required BuildContext context,
    required int status,
    required Order order,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/change-order-statusUser'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': order.id, 'status': status}),
      );

      httpErrorHand(response: res, context: context, onSuccess: onSuccess);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Get earnings for analytics
  Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    int totalEarning = 0;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/analytics'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          var response = jsonDecode(res.body);
          totalEarning = (response['totalEarnings'] as num).toInt();
          sales = [
            Sales('Mobiles', (response['mobileEarnings'] as num).toInt()),
            Sales('Essentials', (response['essentialEarnings'] as num).toInt()),
            Sales('Books', (response['booksEarnings'] as num).toInt()),
            Sales('Appliances', (response['applianceEarnings'] as num).toInt()),
            Sales('Fashion', (response['fashionEarnings'] as num).toInt()),
          ];
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {'sales': sales, 'totalEarnings': totalEarning};
  }
}
