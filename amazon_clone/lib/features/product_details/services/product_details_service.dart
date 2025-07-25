import 'dart:convert';

import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/models/user.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProductDetailsService {
  void addToCart({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/add-to-cart'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': product.id!}),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(
            cart: jsonDecode(res.body)['cart'],
          );
          userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Thêm phương thức để đặt hàng trực tiếp một sản phẩm (Buy Now)
  void buyNowProduct({
    required BuildContext context,
    required Product product,
    required String address,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Tạo cart tạm thời chỉ chứa sản phẩm hiện tại
      List<Map<String, dynamic>> tempCart = [
        {
          'product': {
            '_id': product.id,
            'name': product.name,
            'price': product.price,
            'images': product.images,
            'description': product.description,
            'category': product.category,
          },
          'quantity': 1,
        },
      ];

      http.Response res = await http.post(
        Uri.parse('$uri/api/order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'cart': tempCart,
          'address': address,
          'totalPrice': product.price.toDouble(),
          'isBuyNow': true, // Flag để server biết đây là buy now
        }),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Your order has been placed successfully!');
          // Không cần xóa cart vì chúng ta không thay đổi cart gốc
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void rateProduct({
    required BuildContext context,
    required Product product,
    required double rating,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/rate-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': product.id!, 'rating': rating}),
      );

      httpErrorHand(response: res, context: context, onSuccess: () {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
