import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

// API endpoint
String uri = 'http://yourid:3000';  // yourid go to cmd and type ipconfig, copy ipv4 add to yourid

class GlobalVariables {
  // Deprecated - Use AppColors instead
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  // Deprecated - Use AppColors instead
  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const backgroundColor = Colors.white;
  static const Color greyBackgroundCOlor = Color(0xffebecee);
  static var selectedNavBarColor = Colors.cyan[800]!;
  static const unselectedNavBarColor = Colors.black87;

  // Helper methods for theme-aware colors
  static Color getSelectedNavBarColor(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return themeProvider.getSelectedNavBarColor(context);
  }

  static Color getUnselectedNavBarColor(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return themeProvider.getUnselectedNavBarColor(context);
  }

  static Color getSecondaryColor(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return themeProvider.getSecondaryColor(context);
  }

  static Gradient getAppBarGradient(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return themeProvider.getAppBarGradient(context);
  }

  // Static Images and URLs for the app
  static const List<String> carouselImages = [
    'https://images-eu.ssl-images-amazon.com/images/G/31/img21/Wireless/WLA/TS/D37847648_Accessories_savingdays_Jan22_Cat_PC_1500.jpg',
    'https://images-eu.ssl-images-amazon.com/images/G/31/img2021/Vday/bwl/English.jpg',
    'https://images-eu.ssl-images-amazon.com/images/G/31/img22/Wireless/AdvantagePrime/BAU/14thJan/D37196025_IN_WL_AdvantageJustforPrime_Jan_Mob_ingress-banner_1242x450.jpg',
    'https://images-na.ssl-images-amazon.com/images/G/31/Symbol/2020/00NEW/1242_450Banners/PL31_copy._CB432483346_.jpg',
    'https://images-na.ssl-images-amazon.com/images/G/31/img21/shoes/September/SSW/pc-header._CB641971330_.jpg',
  ];

  static const List<Map<String, String>> categoryImages = [
    {'title': 'Mobiles', 'image': 'assets/images/mobiles.jpeg'},
    {'title': 'Essentials', 'image': 'assets/images/essentials.jpeg'},
    {'title': 'Appliances', 'image': 'assets/images/appliances.jpeg'},
    {'title': 'Books', 'image': 'assets/images/books.jpeg'},
    {'title': 'Fashion', 'image': 'assets/images/fashion.jpeg'},
  ];
}
