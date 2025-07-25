import 'package:amazon_clone/common/widgets/bottom_bar.dart';
import 'package:amazon_clone/features/address/screens/address_screen.dart';
import 'package:amazon_clone/features/admin/screens/add_product_screen.dart';
import 'package:amazon_clone/features/admin/screens/admin_screen.dart';
import 'package:amazon_clone/features/auth/screens/OTPVerificationScreen.dart';
import 'package:amazon_clone/features/auth/screens/ResetPasswordScreen.dart';
import 'package:amazon_clone/features/auth/screens/auth_screen.dart';
import 'package:amazon_clone/features/auth/screens/forgot_password_screen.dart';
import 'package:amazon_clone/features/home/screens/category_deals_screen.dart';
import 'package:amazon_clone/features/home/screens/home_screen.dart';
import 'package:amazon_clone/features/order_details/screens/order_details.dart';
import 'package:amazon_clone/features/product_details/screens/product_details_screen.dart';
import 'package:amazon_clone/features/search/screens/search_screen.dart';
import 'package:amazon_clone/features/splash/screens/splash_screen.dart';
import 'package:amazon_clone/models/order.dart';
import 'package:amazon_clone/models/product.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSetting) {
  switch (routeSetting.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const SplashScreen(),
      );

    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const AuthScreen(),
      );

    case ForgotPasswordScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const ForgotPasswordScreen(),
      );

    case '/admin':
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const AdminScreen(),
      );

    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const HomeScreen(),
      );

    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const BottomBar(),
      );

    case AddProductScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const AddProductScreen(),
      );

    case CategoryDealsScreen.routeName:
      var category = routeSetting.arguments as String;
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => CategoryDealsScreen(category: category),
      );

    case SearchScreen.routeName:
      var searchQuery = routeSetting.arguments as String;
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => SearchScreen(searchQuery: searchQuery),
      );

    case ProductDetailsScreen.routeName:
      var product = routeSetting.arguments as Product;
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => ProductDetailsScreen(product: product),
      );

    case AddressScreen.routeName:
      var totalAmount = routeSetting.arguments as String;
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => AddressScreen(totalAmount: totalAmount),
      );

    case OrderDetailScreen.routeName:
      var order = routeSetting.arguments as Order;
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => OrderDetailScreen(order: order),
      );
    case '/otp-verification':
      var email = routeSetting.arguments as String;
      return MaterialPageRoute(
        builder: (_) => OTPVerificationScreen(email: email),
      );

    case '/reset-password':
      var args = routeSetting.arguments as Map<String, String>;
      return MaterialPageRoute(
        builder: (_) =>
            ResetPasswordScreen(email: args['email']!, otp: args['otp']!),
      );
    default:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Page not found'))),
      );
  }
}
