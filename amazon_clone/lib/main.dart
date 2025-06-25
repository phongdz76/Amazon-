import 'package:amazon_clone/constants/global_variables.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amazon Clone',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amazon Clone'),
          backgroundColor: Colors.cyan,
        ),
        body: Center(
          child: Text(
            'Flutter Demo Home Page',
          ),
        ),
      ),
    );
  }
}

