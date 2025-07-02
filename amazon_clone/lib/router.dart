import 'package:amazon_clone/features/auth/screens/auth_screen.dart';
import 'package:amazon_clone/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSetting){
  switch(routeSetting.name) {
     case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const AuthScreen(),
      );

    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const HomeScreen(),
      );
      default:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        ),
      );
  }
}