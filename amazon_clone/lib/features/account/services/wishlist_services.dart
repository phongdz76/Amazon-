import 'dart:convert';
import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WishlistServices {
  void addToWishlist({
    required BuildContext context,
    required String productId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/add-to-wishlist'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'productId': productId}),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          // Update user data with new wishlist
          final updatedUser = userProvider.user.copyWith(
            wishlist: List<String>.from(jsonDecode(res.body)['wishlist'] ?? []),
          );
          userProvider.setUserFromModel(updatedUser);
          showSnackBar(context, 'Added to wishlist!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void removeFromWishlist({
    required BuildContext context,
    required String productId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.delete(
        Uri.parse('$uri/api/remove-from-wishlist'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'productId': productId}),
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          // Update user data with new wishlist
          final updatedUser = userProvider.user.copyWith(
            wishlist: List<String>.from(jsonDecode(res.body)['wishlist'] ?? []),
          );
          userProvider.setUserFromModel(updatedUser);
          showSnackBar(context, 'Removed from wishlist!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Product>> fetchWishlistProducts({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/wishlist'),
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
}
