import 'package:amazon_clone/constants/global_variables.dart';
import 'package:flutter/material.dart';

class ButtomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  const ButtomBar({super.key});

  @override
  State<ButtomBar> createState() => _ButtomBarState();
}

class _ButtomBarState extends State<ButtomBar> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.selectedNavBarColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: GlobalVariables.backgroundColor,
        iconSize: 28,
        items: [
          BottomNavigationBarItem(
            icon: Container(
            width: bottomBarWidth,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                color: _page == 0 
                ? GlobalVariables.selectedNavBarColor 
                : GlobalVariables.backgroundColor,
                width: bottomBarBorderWidth,
              ),
            ),
          ),
            child: const Icon(
              Icons.home_outlined,
            ),
        ),
      ),
        ],
      ),
    );
  }
}