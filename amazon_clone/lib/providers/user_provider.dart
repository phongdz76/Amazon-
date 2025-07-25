import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    password: '',
    address: '',
    type: '',
    token: '',
    cart: [],
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    _saveUserToPrefs();
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    _saveUserToPrefs();
    notifyListeners();
  }

  // Save user data to SharedPreferences
  void _saveUserToPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', _user.token);
      await prefs.setString('user-data', _user.toJson());
    } catch (e) {
      print('Error saving user to prefs: $e');
    }
  }

  // Load user data from SharedPreferences
  Future<void> loadUserFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      String? userData = prefs.getString('user-data');
      
      if (token != null && userData != null) {
        _user = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from prefs: $e');
    }
  }

  // Clear user data (for logout)
  Future<void> clearUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('x-auth-token');
      await prefs.remove('user-data');
      
      _user = User(
        id: '',
        name: '',
        email: '',
        password: '',
        address: '',
        type: '',
        token: '',
        cart: [],
      );
      notifyListeners();
    } catch (e) {
      print('Error clearing user: $e');
    }
  }

  // Refresh user data from server
  Future<bool> refreshUserData() async {
    try {
      if (_user.token.isEmpty) return false;
      
      final response = await http.get(
        Uri.parse('$uri/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': _user.token,
        },
      );
      
      if (response.statusCode == 200) {
        _user = User.fromJson(response.body);
        _saveUserToPrefs();
        notifyListeners();
        return true;
      } else {
        // Token might be invalid
        await clearUser();
        return false;
      }
    } catch (e) {
      print('Error refreshing user data: $e');
      return false;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _user.token.isNotEmpty;
}