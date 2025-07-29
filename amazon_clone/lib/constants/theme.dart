import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  // Light Theme Colors - Amazon-inspired
  static const Color lightPrimary = Color.fromARGB(255, 29, 201, 192);
  static const Color lightSecondary = Color.fromRGBO(255, 153, 0, 1);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.black;
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightSelectedNavBar = Color(0xFF00838f);
  static const Color lightUnselectedNavBar = Color(0xFF757575);
  static const Color lightGreyBackground = Color(0xFFF5F5F5);
  static const Color lightCardColor = Colors.white;
  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color lightShadowColor = Color(0x1A000000);
  static const Color lightBorderColor = Color(0xFFE1E1E1);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextTertiary = Color(0xFFBDBDBD);
  static const Color lightSuccessColor = Color(0xFF4CAF50);
  static const Color lightErrorColor = Color(0xFFF44336);
  static const Color lightWarningColor = Color(0xFFFF9800);

  // Dark Theme Colors - Modern dark UI
  static const Color darkPrimary = Color.fromARGB(255, 29, 201, 192);
  static const Color darkSecondary = Color.fromRGBO(255, 153, 0, 1);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkOnPrimary = Colors.white;
  static const Color darkOnSecondary = Colors.black;
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkSelectedNavBar = Color(0xFF00ACC1);
  static const Color darkUnselectedNavBar = Color(0xFF8E8E93);
  static const Color darkGreyBackground = Color(0xFF2C2C2E);
  static const Color darkCardColor = Color(0xFF1C1C1E);
  static const Color darkDividerColor = Color(0xFF38383A);
  static const Color darkShadowColor = Color(0x66000000);
  static const Color darkBorderColor = Color(0xFF38383A);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextTertiary = Color(0xFF636366);
  static const Color darkErrorColor = Color(0xFFFF453A);
  static const Color darkSuccessColor = Color(0xFF30D158);
  static const Color darkWarningColor = Color(0xFFFF9F0A);

  // Gradients
  static const Gradient lightAppBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient darkAppBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 18, 120, 115),
      Color.fromARGB(255, 65, 150, 145),
    ],
    stops: [0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Special Amazon colors
  static const Color lightAmazonOrange = Color(0xFFFF9900);
  static const Color darkAmazonOrange = Color(0xFFFF9F0A);
  static const Color lightAmazonBlue = Color(0xFF232F3E);
  static const Color darkAmazonBlue = Color(0xFF37475A);
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
      tertiary: AppColors.lightAmazonOrange,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.lightErrorColor,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onSurface: AppColors.lightOnSurface,
      onBackground: AppColors.lightOnBackground,
      onError: Colors.white,
      surfaceVariant: AppColors.lightGreyBackground,
      outline: AppColors.lightBorderColor,
      shadow: AppColors.lightShadowColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black87, size: 24),
      actionsIconTheme: IconThemeData(color: Colors.black87, size: 24),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      centerTitle: false,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.lightSelectedNavBar,
      unselectedItemColor: AppColors.lightUnselectedNavBar,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.lightCardColor,
      elevation: 2,
      shadowColor: AppColors.lightShadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.lightBorderColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: AppColors.lightShadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 16,
        height: 1.4,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      headlineSmall: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.lightOnBackground,
      size: 24,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 2,
        shadowColor: AppColors.lightShadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightPrimary, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGreyBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.lightBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.lightBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.lightErrorColor,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.lightErrorColor,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        color: AppColors.lightTextTertiary,
        fontSize: 16,
      ),
      errorStyle: const TextStyle(
        color: AppColors.lightErrorColor,
        fontSize: 12,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightGreyBackground,
      selectedColor: AppColors.lightPrimary.withOpacity(0.12),
      disabledColor: AppColors.lightTextTertiary.withOpacity(0.12),
      deleteIconColor: AppColors.lightTextSecondary,
      labelStyle: const TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 14,
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.lightPrimary,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightPrimary;
        }
        return AppColors.lightTextTertiary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightPrimary.withOpacity(0.5);
        }
        return AppColors.lightTextTertiary.withOpacity(0.3);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.lightTextSecondary, width: 2),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightPrimary;
        }
        return AppColors.lightTextSecondary;
      }),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.lightDividerColor,
      thickness: 1,
      space: 1,
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
      tertiary: AppColors.darkAmazonOrange,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.darkErrorColor,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onSurface: AppColors.darkOnSurface,
      onBackground: AppColors.darkOnBackground,
      onError: Colors.black,
      surfaceVariant: AppColors.darkSurfaceVariant,
      outline: AppColors.darkBorderColor,
      shadow: AppColors.darkShadowColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white, size: 24),
      actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      centerTitle: false,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkSelectedNavBar,
      unselectedItemColor: AppColors.darkUnselectedNavBar,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkCardColor,
      elevation: 4,
      shadowColor: AppColors.darkShadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.darkBorderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: AppColors.darkShadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
        height: 1.4,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.darkOnBackground, size: 24),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 4,
        shadowColor: AppColors.darkShadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkPrimary, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkGreyBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkErrorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkErrorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        color: AppColors.darkTextTertiary,
        fontSize: 16,
      ),
      errorStyle: const TextStyle(
        color: AppColors.darkErrorColor,
        fontSize: 12,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkGreyBackground,
      selectedColor: AppColors.darkPrimary.withOpacity(0.12),
      disabledColor: AppColors.darkTextTertiary.withOpacity(0.12),
      deleteIconColor: AppColors.darkTextSecondary,
      labelStyle: const TextStyle(color: AppColors.darkOnSurface, fontSize: 14),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.darkPrimary,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary;
        }
        return AppColors.darkTextTertiary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary.withOpacity(0.5);
        }
        return AppColors.darkTextTertiary.withOpacity(0.3);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.darkTextSecondary, width: 2),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary;
        }
        return AppColors.darkTextSecondary;
      }),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkDividerColor,
      thickness: 1,
      space: 1,
    ),
  );
}

// Theme Provider để quản lý theme state với nhiều tính năng hơn
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

  bool get isLightMode => !isDarkMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeToPrefs();
      notifyListeners();
    }
  }

  void setLightTheme() => setThemeMode(ThemeMode.light);
  void setDarkTheme() => setThemeMode(ThemeMode.dark);
  void setSystemTheme() => setThemeMode(ThemeMode.system);

  Future<void> _loadThemeFromPrefs() async {
    try {
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
    } catch (e) {
      // Handle error, default to system theme
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> _saveThemeToPrefs() async {
    try {
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
    } catch (e) {
      // Handle error
    }
  }

  // Helper methods cho màu sắc theo theme
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

  Color getErrorColor(BuildContext context) {
    return isDarkMode ? AppColors.darkErrorColor : AppColors.lightErrorColor;
  }

  Color getSuccessColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkSuccessColor
        : AppColors.lightSuccessColor;
  }

  Color getWarningColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkWarningColor
        : AppColors.lightWarningColor;
  }

  Color getTextSecondaryColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
  }

  Color getTextTertiaryColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkTextTertiary
        : AppColors.lightTextTertiary;
  }

  Color getSurfaceVariantColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkSurfaceVariant
        : AppColors.lightGreyBackground;
  }

  Color getBorderColor(BuildContext context) {
    return isDarkMode ? AppColors.darkBorderColor : AppColors.lightBorderColor;
  }

  Color getAmazonOrangeColor(BuildContext context) {
    return isDarkMode
        ? AppColors.darkAmazonOrange
        : AppColors.lightAmazonOrange;
  }

  Color getAmazonBlueColor(BuildContext context) {
    return isDarkMode ? AppColors.darkAmazonBlue : AppColors.lightAmazonBlue;
  }

  // Helper methods cho styling
  BoxShadow getCardShadow(BuildContext context) {
    return BoxShadow(
      color: isDarkMode
          ? AppColors.darkShadowColor
          : AppColors.lightShadowColor,
      blurRadius: isDarkMode ? 8 : 4,
      offset: const Offset(0, 2),
      spreadRadius: isDarkMode ? 0 : 1,
    );
  }

  BorderSide getBorderSide(BuildContext context, {double width = 1}) {
    return BorderSide(color: getBorderColor(context), width: width);
  }

  // Helper methods cho text styling
  TextStyle getHeadingStyle(BuildContext context, {double? fontSize}) {
    return TextStyle(
      color: Theme.of(context).textTheme.headlineMedium?.color,
      fontSize: fontSize ?? 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    );
  }

  TextStyle getBodyStyle(BuildContext context, {double? fontSize}) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    );
  }

  TextStyle getCaptionStyle(BuildContext context, {double? fontSize}) {
    return TextStyle(
      color: getTextSecondaryColor(context),
      fontSize: fontSize ?? 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    );
  }

  // Animation duration cho theme transition
  Duration get animationDuration => const Duration(milliseconds: 300);

  // Theme mode descriptions
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }
}
