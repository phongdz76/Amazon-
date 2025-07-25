import 'dart:convert';
import 'dart:io';
import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/features/auth/screens/auth_screen.dart';
import 'package:amazon_clone/models/order.dart';
import 'package:amazon_clone/models/user.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AccountServices {
  Future<List<Order>> fetchMyOrders({required BuildContext context}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/orders/me'),
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

  Future<void> updateProfile({
    required BuildContext context,
    required String name,
    required String phone,
    required String address,
    required File? avatarFile,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    print('Updating profile...');
    print('Token: ${userProvider.user.token}');
    print('URI: $uri/api/update-profile');
    print('Name: $name, Phone: $phone, Address: $address');

    try {
      String? avatarUrl;
      if (avatarFile != null) {
        print('Uploading avatar to Cloudinary...');
        final cloudinary = CloudinaryPublic('dardtagt3', 'amazon_cloudinary');
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(avatarFile.path, folder: 'avatars'),
        );
        avatarUrl = response.secureUrl;
        print('Avatar uploaded: $avatarUrl');
      }

      Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'address': address,
      };

      if (avatarUrl != null) {
        requestBody['avatar'] = avatarUrl;
      }

      http.Response res = await http.post(
        Uri.parse('$uri/api/update-profile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        User user = User.fromJson(res.body);
        userProvider.setUserFromModel(user);
        // Don't show snackbar here, let the calling widget handle it
      } else if (res.statusCode == 401) {
        // Token expired or invalid
        showSnackBar(context, 'Session expired. Please login again.');
        await userProvider.clearUser();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AuthScreen.routeName,
          (route) => false,
        );
      } else {
        // Other errors
        Map<String, dynamic> errorResponse = jsonDecode(res.body);
        String errorMessage = errorResponse['error'] ?? 'Update failed';
        showSnackBar(context, errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        showSnackBar(context, 'Network error. Please check your connection.');
      } else {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
  }

  void logOut(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUser();

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, e.toString());
    }
  }
}
