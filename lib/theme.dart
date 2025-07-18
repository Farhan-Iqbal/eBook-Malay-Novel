// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isDarkMode = false; // Add _isDarkMode

  double get fontSize => _fontSize;
  bool get isBold => _isBold;
  bool get isDarkMode => _isDarkMode; // Add getter for isDarkMode

  ThemeProvider() {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _isBold = prefs.getBool('isBold') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Load dark mode setting
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  // Corrected toggleDarkMode to accept a boolean value
  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  // Corrected toggleBold to accept a boolean value
  Future<void> toggleBold(bool value) async {
    _isBold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBold', value);
    notifyListeners();
  }
}


ThemeData buildAppTheme(double fontSize, bool isBold, bool isDark) {
  // Define colors based on theme
  final Color primaryColor = isDark ? kDarkPrimaryColor : kPrimaryColor;
  final Color secondaryColor = isDark ? kDarkSecondaryColor : kSecondaryColor;
  final Color backgroundColor = isDark ? kDarkBackgroundColor : kBackgroundColor;
  final Color surfaceColor = isDark ? kDarkSurfaceColor : kSurfaceColor;
  final Color accentColor = isDark ? kDarkAccentColor : kAccentColor;
  final Color textColor = isDark ? kDarkTextColor : kTextColor;
  final Color subtleTextColor = isDark ? kDarkSubtleTextColor : kSubtleTextColor;

  FontWeight textFontWeight = isBold ? FontWeight.bold : FontWeight.normal;

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    canvasColor: backgroundColor,
    highlightColor: accentColor.withOpacity(0.1),
    splashColor: accentColor.withOpacity(0.1),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: backgroundColor,
      onBackground: textColor,
      surface: surfaceColor,
      onSurface: textColor,
    ),
    appBarTheme: AppBarTheme(
      color: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: fontSize + 4,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryColor, // Apply primary color
      // OPTION 1: High contrast selected item color
      selectedItemColor: isDark ? Colors.white : Colors.amber,
      unselectedItemColor: Colors.white.withOpacity(0.7),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: textFontWeight),
      unselectedLabelStyle: TextStyle(fontWeight: textFontWeight),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textColor, fontSize: fontSize * 2.5, fontWeight: textFontWeight),
      displayMedium: TextStyle(color: textColor, fontSize: fontSize * 2, fontWeight: textFontWeight),
      displaySmall: TextStyle(color: textColor, fontSize: fontSize * 1.8, fontWeight: textFontWeight),
      headlineLarge: TextStyle(color: textColor, fontSize: fontSize * 1.7, fontWeight: textFontWeight),
      headlineMedium: TextStyle(color: textColor, fontSize: fontSize * 1.5, fontWeight: textFontWeight),
      headlineSmall: TextStyle(color: textColor, fontSize: fontSize * 1.3, fontWeight: textFontWeight),
      titleLarge: TextStyle(color: textColor, fontSize: fontSize + 4, fontWeight: textFontWeight),
      titleMedium: TextStyle(color: textColor, fontSize: fontSize + 2, fontWeight: textFontWeight),
      titleSmall: TextStyle(color: textColor, fontSize: fontSize, fontWeight: textFontWeight),
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
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: textFontWeight,
        ),
      ),
    ),
    // Add these properties for consistent styling of cards and dialogs
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    ),
  );
}