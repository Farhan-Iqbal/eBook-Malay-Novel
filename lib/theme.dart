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

class ThemeProvider with ChangeNotifier {
  double _fontSize = 16.0;
  bool _isBold = false;

  double get fontSize => _fontSize;
  bool get isBold => _isBold;

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void toggleBold(bool value) {
    _isBold = value;
    notifyListeners();
  }
}

ThemeData buildAppTheme(double fontSize, bool isBold) {
  final FontWeight textFontWeight = isBold ? FontWeight.bold : FontWeight.normal;

  return ThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    primaryColor: kPrimaryColor,
    hintColor: kSubtleTextColor,
    brightness: Brightness.light,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: kSoftPink, // Set AppBar background to soft pink
      elevation: 0,
      iconTheme: IconThemeData(color: kTextColor),
      titleTextStyle: TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    
    cardTheme: CardThemeData(
      color: kSurfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    
    // Add the BottomNavigationBar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSoftPink, // Set BottomNavigationBar background to soft pink
      selectedItemColor: kTextColor, // Color for the selected icon/label
      unselectedItemColor: kSubtleTextColor, // Color for unselected icons/labels
      elevation: 4,
    ),
    
    textTheme: TextTheme(
      displayLarge: TextStyle(color: kTextColor, fontWeight: textFontWeight),
      displayMedium: TextStyle(color: kTextColor, fontWeight: textFontWeight),
      displaySmall: TextStyle(color: kTextColor, fontWeight: textFontWeight),
      headlineMedium: TextStyle(color: kTextColor, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600),
      headlineSmall: TextStyle(color: kTextColor, fontWeight: textFontWeight),
      titleLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: kTextColor, fontSize: fontSize, fontWeight: textFontWeight),
      bodyMedium: TextStyle(color: kSubtleTextColor, fontSize: fontSize, fontWeight: textFontWeight),
      labelLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: kSubtleTextColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: kSubtleTextColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: kAccentColor, width: 2),
      ),
      labelStyle: const TextStyle(color: kSubtleTextColor),
      hintStyle: const TextStyle(color: kSubtleTextColor),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: kSurfaceColor,
        backgroundColor: kAccentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}