import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color.fromARGB(255, 29, 201, 192);
  static const Color lightSecondary = Color.fromRGBO(255, 153, 0, 1);
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.black;
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black;
  static const Color lightSelectedNavBar = Color(0xFF00838f);
  static const Color lightUnselectedNavBar = Colors.black87;
  static const Color lightGreyBackground = Color(0xffebecee);
  static const Color lightCardColor = Colors.white;
  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color lightShadowColor = Color(0x1A000000);

  // Dark Theme Colors
  static const Color darkPrimary = Color.fromARGB(255, 29, 201, 192);
  static const Color darkSecondary = Color.fromRGBO(255, 153, 0, 1);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnPrimary = Colors.white;
  static const Color darkOnSecondary = Colors.black;
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white;
  static const Color darkSelectedNavBar = Color(0xFF00ACC1);
  static const Color darkUnselectedNavBar = Colors.white70;
  static const Color darkGreyBackground = Color(0xFF2C2C2C);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  static const Color darkDividerColor = Color(0xFF424242);
  static const Color darkShadowColor = Color(0x33000000);

  // Gradients
  static const Gradient lightAppBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  static const Gradient darkAppBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 20, 140, 133),
      Color.fromARGB(255, 85, 170, 165),
    ],
    stops: [0.5, 1.0],
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCardColor,
    dividerColor: AppColors.lightDividerColor,
    shadowColor: AppColors.lightShadowColor,

    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.lightSelectedNavBar,
      unselectedItemColor: AppColors.lightUnselectedNavBar,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    cardTheme: const CardThemeData(
      color: AppColors.lightCardColor,
      elevation: 2,
      shadowColor: AppColors.lightShadowColor,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.lightOnBackground),
      displayMedium: TextStyle(color: AppColors.lightOnBackground),
      displaySmall: TextStyle(color: AppColors.lightOnBackground),
      headlineLarge: TextStyle(color: AppColors.lightOnBackground),
      headlineMedium: TextStyle(color: AppColors.lightOnBackground),
      headlineSmall: TextStyle(color: AppColors.lightOnBackground),
      titleLarge: TextStyle(color: AppColors.lightOnBackground),
      titleMedium: TextStyle(color: AppColors.lightOnBackground),
      titleSmall: TextStyle(color: AppColors.lightOnBackground),
      bodyLarge: TextStyle(color: AppColors.lightOnBackground),
      bodyMedium: TextStyle(color: AppColors.lightOnBackground),
      bodySmall: TextStyle(color: AppColors.lightOnBackground),
      labelLarge: TextStyle(color: AppColors.lightOnBackground),
      labelMedium: TextStyle(color: AppColors.lightOnBackground),
      labelSmall: TextStyle(color: AppColors.lightOnBackground),
    ),

    iconTheme: const IconThemeData(color: AppColors.lightOnBackground),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 2,
        shadowColor: AppColors.lightShadowColor,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGreyBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCardColor,
    dividerColor: AppColors.darkDividerColor,
    shadowColor: AppColors.darkShadowColor,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkSelectedNavBar,
      unselectedItemColor: AppColors.darkUnselectedNavBar,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    cardTheme: const CardThemeData(
      color: AppColors.darkCardColor,
      elevation: 4,
      shadowColor: AppColors.darkShadowColor,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkOnBackground),
      displayMedium: TextStyle(color: AppColors.darkOnBackground),
      displaySmall: TextStyle(color: AppColors.darkOnBackground),
      headlineLarge: TextStyle(color: AppColors.darkOnBackground),
      headlineMedium: TextStyle(color: AppColors.darkOnBackground),
      headlineSmall: TextStyle(color: AppColors.darkOnBackground),
      titleLarge: TextStyle(color: AppColors.darkOnBackground),
      titleMedium: TextStyle(color: AppColors.darkOnBackground),
      titleSmall: TextStyle(color: AppColors.darkOnBackground),
      bodyLarge: TextStyle(color: AppColors.darkOnBackground),
      bodyMedium: TextStyle(color: AppColors.darkOnBackground),
      bodySmall: TextStyle(color: AppColors.darkOnBackground),
      labelLarge: TextStyle(color: AppColors.darkOnBackground),
      labelMedium: TextStyle(color: AppColors.darkOnBackground),
      labelSmall: TextStyle(color: AppColors.darkOnBackground),
    ),

    iconTheme: const IconThemeData(color: AppColors.darkOnBackground),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 4,
        shadowColor: AppColors.darkShadowColor,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkGreyBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
    ),
  );
}

// Theme Provider để quản lý theme state
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeKey);
    if (themeModeString != null) {
      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    }
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    switch (_themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, themeModeString);
  }

  // Helper methods để lấy màu theo theme hiện tại
  Color getAppBarGradientStart(BuildContext context) {
    return isDarkMode
        ? AppColors.darkAppBarGradient.colors.first
        : AppColors.lightAppBarGradient.colors.first;
  }

  Color getAppBarGradientEnd(BuildContext context) {
    return isDarkMode
        ? AppColors.darkAppBarGradient.colors.last
        : AppColors.lightAppBarGradient.colors.last;
  }

  Gradient getAppBarGradient(BuildContext context) {
    return isDarkMode
        ? AppColors.darkAppBarGradient
        : AppColors.lightAppBarGradient;
  }

  Color getSelectedNavBarColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkSelectedNavBar
        : AppColors.lightSelectedNavBar;
  }

  Color getUnselectedNavBarColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkUnselectedNavBar
        : AppColors.lightUnselectedNavBar;
  }

  Color getGreyBackgroundColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkGreyBackground
        : AppColors.lightGreyBackground;
  }

  Color getSecondaryColor(BuildContext context) {
    return isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;
  }
}
