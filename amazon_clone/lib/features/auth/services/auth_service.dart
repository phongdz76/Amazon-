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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Generate 6-digit OTP
  String _generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // Gửi OTP reset password - SỬA LẠI
  Future<bool> sendResetOTP({
    required BuildContext context,
    required String email,
  }) async {
    try {
      String otp = _generateOTP();

      // Lưu OTP vào bộ nhớ
      _otpStorage[email] = {
        'otp': otp,
        'expiresAt': DateTime.now().add(Duration(minutes: 10)),
        'verified': false,
      };

      print('Sending OTP to: $email');
      print('OTP: $otp');
      print('API URL: ${NetworkConfig.emailApi}');

      // Gọi Bun server API - SỬA LẠI BODY
      http.Response res = await http
          .post(
            Uri.parse(NetworkConfig.emailApi),
            body: jsonEncode({
              'to': email, // Đảm bảo field này khớp với Bun server
              'subject': 'Mã OTP đặt lại mật khẩu - Amazon Clone',
              'message':
                  '''Xin chào,

Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Amazon Clone.

Mã OTP của bạn là: $otp

Mã này có hiệu lực trong 10 phút.

Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.

Trân trọng,
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
        showSnackBar(context, 'Mã OTP đã được gửi đến email của bạn!');
        return true;
      } else {
        print('Error response: ${res.body}');
        showSnackBar(
          context,
          'Không thể gửi email. Vui lòng thử lại. (Status: ${res.statusCode})',
        );
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      showSnackBar(context, 'Lỗi kết nối server: ${e.toString()}');
      return false;
    }
  }

  // Xác thực OTP
  Future<bool> verifyResetOTP({
    required BuildContext context,
    required String email,
    required String otp,
  }) async {
    try {
      if (!_otpStorage.containsKey(email)) {
        showSnackBar(
          context,
          'Không tìm thấy mã OTP. Vui lòng yêu cầu mã mới.',
        );
        return false;
      }

      var otpData = _otpStorage[email]!;

      if (DateTime.now().isAfter(otpData['expiresAt'])) {
        _otpStorage.remove(email);
        showSnackBar(context, 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.');
        return false;
      }

      if (otpData['otp'] != otp) {
        showSnackBar(context, 'Mã OTP không đúng. Vui lòng thử lại.');
        return false;
      }

      _otpStorage[email]!['verified'] = true;
      showSnackBar(context, 'Xác thực OTP thành công!');
      return true;
    } catch (e) {
      showSnackBar(context, 'Lỗi khi xác thực OTP.');
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
        showSnackBar(context, 'Phiên làm việc đã hết hạn. Vui lòng thử lại.');
        return false;
      }

      var otpData = _otpStorage[email]!;

      if (!otpData['verified'] || otpData['otp'] != otp) {
        showSnackBar(context, 'Mã OTP không hợp lệ hoặc chưa được xác thực.');
        return false;
      }

      if (DateTime.now().isAfter(otpData['expiresAt'])) {
        _otpStorage.remove(email);
        showSnackBar(context, 'Mã OTP đã hết hạn.');
        return false;
      }

      // Tạo reset token từ forgot-password API trước
      http.Response forgotResponse = await http.post(
        Uri.parse('$uri/api/forgot-password'),
        body: jsonEncode({'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (forgotResponse.statusCode != 200) {
        showSnackBar(context, 'Không thể tạo token reset. Vui lòng thử lại.');
        return false;
      }

      var forgotData = jsonDecode(forgotResponse.body);
      String resetToken = forgotData['resetToken'];

      // Gọi API reset password thực sự
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
          // Xóa OTP khỏi storage chỉ khi thành công
          _otpStorage.remove(email);
          showSnackBar(context, 'Đổi mật khẩu thành công!');
        },
      );

      return res.statusCode == 200;
    } catch (e) {
      showSnackBar(context, 'Lỗi khi đổi mật khẩu: ${e.toString()}');
      return false;
    }
  }

  // Gửi lại OTP
  Future<bool> resendOTP({
    required BuildContext context,
    required String email,
  }) async {
    // Kiểm tra spam (không cho gửi quá nhanh)
    if (_otpStorage.containsKey(email)) {
      var otpData = _otpStorage[email]!;
      var timeSinceGenerated = DateTime.now().difference(
        otpData['expiresAt'].subtract(Duration(minutes: 10)),
      );

      if (timeSinceGenerated.inSeconds < 60) {
        showSnackBar(context, 'Vui lòng đợi trước khi yêu cầu mã mới.');
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
