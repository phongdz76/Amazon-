import 'dart:convert';
import 'dart:math';
import 'package:amazon_clone/common/widgets/bottom_bar.dart';
import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/network_config.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/models/user.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // In-memory OTP storage
  static Map<String, Map<String, dynamic>> _otpStorage = {};

  // signUp User (giữ nguyên)
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        email: email,
        password: password,
        address: '',
        type: '',
        token: '',
        cart: [],
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signUp'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Account created successfully!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // signIn User (giữ nguyên)
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signIn'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);

          var userType = jsonDecode(res.body)['type'];
          if (userType == 'admin') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin',
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              BottomBar.routeName,
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data (giữ nguyên)
  void getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      // First try to load from SharedPreferences
      await userProvider.loadUserFromPrefs();

      // If we have a token, verify it with server
      if (userProvider.user.token.isNotEmpty) {
        var tokenRes = await http.post(
          Uri.parse('$uri/tokenIsValid'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
        );

        var response = jsonDecode(tokenRes.body);

        if (response == true) {
          // Token is still valid, get fresh user data
          http.Response userRes = await http.get(
            Uri.parse('$uri/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': userProvider.user.token,
            },
          );

          if (userRes.statusCode == 200) {
            userProvider.setUser(userRes.body);
          }
        } else {
          // Token is invalid, clear user data
          await userProvider.clearUser();
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
      // Don't show error to user as this runs on app startup
    }
  }

  // Generate 6-digit OTP
  String _generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // Send OTP for reset password
  Future<bool> sendResetOTP({
    required BuildContext context,
    required String email,
  }) async {
    try {
      String otp = _generateOTP();

      // Store OTP in memory
      _otpStorage[email] = {
        'otp': otp,
        'expiresAt': DateTime.now().add(Duration(minutes: 10)),
        'verified': false,
      };

      print('Sending OTP to: $email');
      print('OTP: $otp');
      print('API URL: ${NetworkConfig.emailApi}');

      // Call Bun server API
      http.Response res = await http
          .post(
            Uri.parse(NetworkConfig.emailApi),
            body: jsonEncode({
              'to': email, // Ensure this field matches Bun server
              'subject': 'Password Reset OTP - Amazon Clone',
              'message':
                  '''Hello,

You have requested to reset your password for your Amazon Clone account.

Your OTP code is: $otp

This code is valid for 10 minutes.

If you did not request a password reset, please ignore this email.

Best regards,
Amazon Clone Team''',
            }),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        showSnackBar(context, 'OTP code has been sent to your email!');
        return true;
      } else {
        print('Error response: ${res.body}');
        showSnackBar(
          context,
          'Unable to send email. Please try again. (Status: ${res.statusCode})',
        );
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      showSnackBar(context, 'Server connection error: ${e.toString()}');
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyResetOTP({
    required BuildContext context,
    required String email,
    required String otp,
  }) async {
    try {
      if (!_otpStorage.containsKey(email)) {
        showSnackBar(context, 'OTP code not found. Please request a new code.');
        return false;
      }

      var otpData = _otpStorage[email]!;

      if (DateTime.now().isAfter(otpData['expiresAt'])) {
        _otpStorage.remove(email);
        showSnackBar(
          context,
          'OTP code has expired. Please request a new code.',
        );
        return false;
      }

      if (otpData['otp'] != otp) {
        showSnackBar(context, 'Incorrect OTP code. Please try again.');
        return false;
      }

      _otpStorage[email]!['verified'] = true;
      showSnackBar(context, 'OTP verification successful!');
      return true;
    } catch (e) {
      showSnackBar(context, 'Error verifying OTP.');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required BuildContext context,
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      if (!_otpStorage.containsKey(email)) {
        showSnackBar(context, 'Session has expired. Please try again.');
        return false;
      }

      var otpData = _otpStorage[email]!;

      if (!otpData['verified'] || otpData['otp'] != otp) {
        showSnackBar(context, 'Invalid OTP or not verified.');
        return false;
      }

      if (DateTime.now().isAfter(otpData['expiresAt'])) {
        _otpStorage.remove(email);
        showSnackBar(context, 'OTP code has expired.');
        return false;
      }

      // Create reset token from forgot-password API first
      http.Response forgotResponse = await http.post(
        Uri.parse('$uri/api/forgot-password'),
        body: jsonEncode({'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (forgotResponse.statusCode != 200) {
        showSnackBar(
          context,
          'Unable to create reset token. Please try again.',
        );
        return false;
      }

      var forgotData = jsonDecode(forgotResponse.body);
      String resetToken = forgotData['resetToken'];

      // Call actual reset password API
      http.Response res = await http.post(
        Uri.parse('$uri/api/reset-password'),
        body: jsonEncode({'token': resetToken, 'newPassword': newPassword}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHand(
        response: res,
        context: context,
        onSuccess: () {
          // Remove OTP from storage only on success
          _otpStorage.remove(email);
          showSnackBar(context, 'Password changed successfully!');
        },
      );

      return res.statusCode == 200;
    } catch (e) {
      showSnackBar(context, 'Error changing password: ${e.toString()}');
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOTP({
    required BuildContext context,
    required String email,
  }) async {
    // Check for spam (don't allow sending too quickly)
    if (_otpStorage.containsKey(email)) {
      var otpData = _otpStorage[email]!;
      var timeSinceGenerated = DateTime.now().difference(
        otpData['expiresAt'].subtract(Duration(minutes: 10)),
      );

      if (timeSinceGenerated.inSeconds < 60) {
        showSnackBar(context, 'Please wait before requesting a new code.');
        return false;
      }
    }

    return await sendResetOTP(context: context, email: email);
  }

  // forgot password (wrapper function)
  Future<void> forgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    await sendResetOTP(context: context, email: email);
  }
}
