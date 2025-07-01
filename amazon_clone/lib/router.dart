import 'package:amazon_clone/features/auth/screens/auth_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSetting){
  switch(routeSetting.name) {
     case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (context) => const AuthScreen(),
      );
     
      default:
      return MaterialPageRoute(
        settings: routeSetting,
        builder: (context) => const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        ),
      );
  }
}