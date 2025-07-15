import 'package:flutter/material.dart';

// Define your color palette, including the new soft pink
const Color kPrimaryColor = Color(0xFF4682B4); // Steel Blue
const Color kSecondaryColor = Color(0xFFADD8E6); // Light Blue
const Color kBackgroundColor = Color(0xFFF0F2F5); // Light Grayish Blue
const Color kSurfaceColor = Color(0xFFFFFFFF); // White
const Color kAccentColor = Color(0xFF1E90FF); // Dodger Blue
const Color kTextColor = Color(0xFF2C3E50); // Dark Slate Gray
const Color kSubtleTextColor = Color(0xFF7F8C8D); // Asbestos

// New color for AppBar and Bottom Navigation Bar
const Color kSoftPink = Color(0xFFF8BBD0); // Soft Pink

// Dark Theme Colors
const Color kDarkPrimaryColor = Color(0xFF33587A);
const Color kDarkSecondaryColor = Color(0xFF5A7EA8);
const Color kDarkBackgroundColor = Color(0xFF121212);
const Color kDarkSurfaceColor = Color(0xFF1E1E1E);
const Color kDarkAccentColor = Color(0xFF42A5F5);
const Color kDarkTextColor = Color(0xFFE0E0E0);
const Color kDarkSubtleTextColor = Color(0xFFB0B0B0);

class ThemeProvider with ChangeNotifier {
  double _fontSize = 16.0;
  bool _isBold = false;
  bool _isDarkMode = false; // New property for dark mode

  double get fontSize => _fontSize;
  bool get isBold => _isBold;
  bool get isDarkMode => _isDarkMode;

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void toggleBold(bool value) {
    _isBold = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

ThemeData buildAppTheme(double fontSize, bool isBold, bool isDarkMode) {
  final FontWeight textFontWeight = isBold ? FontWeight.bold : FontWeight.normal;

  // Use the correct colors based on the mode
  final Color primaryColor = isDarkMode ? kDarkPrimaryColor : kPrimaryColor;
  final Color secondaryColor = isDarkMode ? kDarkSecondaryColor : kSecondaryColor;
  final Color backgroundColor = isDarkMode ? kDarkBackgroundColor : kBackgroundColor;
  final Color surfaceColor = isDarkMode ? kDarkSurfaceColor : kSurfaceColor;
  final Color accentColor = isDarkMode ? kDarkAccentColor : kAccentColor;
  final Color textColor = isDarkMode ? kDarkTextColor : kTextColor;
  final Color subtleTextColor = isDarkMode ? kDarkSubtleTextColor : kSubtleTextColor;
  final Color softPink = isDarkMode ? kDarkPrimaryColor : kSoftPink;

  return ThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      onPrimary: surfaceColor,
      onSecondary: surfaceColor,
      onSurface: textColor,
      onBackground: textColor,
      error: Colors.red,
      onError: Colors.white,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: softPink,
      foregroundColor: textColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: softPink,
      selectedItemColor: primaryColor,
      unselectedItemColor: subtleTextColor,
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textColor, fontSize: fontSize, fontWeight: textFontWeight),
      bodyMedium: TextStyle(color: subtleTextColor, fontSize: fontSize, fontWeight: textFontWeight),
      labelLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: subtleTextColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: subtleTextColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      labelStyle: TextStyle(color: subtleTextColor),
      hintStyle: TextStyle(color: subtleTextColor),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: surfaceColor,
        backgroundColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}