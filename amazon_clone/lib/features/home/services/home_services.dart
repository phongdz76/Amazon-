import 'dart:convert';

import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeServices {
  Future<List<Product>> fetchCategoryProducts({
    required BuildContext context,
    required String category,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/products?category=$category'),
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

  Future<List<Product>> fetchAllProducts({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];

    // Fetch products from all categories
    List<String> categories = [
      'Mobiles',
      'Essentials',
      'Appliances',
      'Books',
      'Fashion',
    ];

    try {
      for (String category in categories) {
        http.Response res = await http.get(
          Uri.parse('$uri/api/products?category=$category'),
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
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }

  Future<Product> fetchDealOfDay({required BuildContext context}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Product product = Product(
      name: '',
      description: '',
      price: 0,
      images: [],
      category: '',
      quantity: 0,
    );
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/deal-of-day'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          product = Product.fromJson(res.body);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return product;
  }
}
