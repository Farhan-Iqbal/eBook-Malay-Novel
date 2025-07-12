import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFB0C4DE); // Light Steel Blue
const Color kSecondaryColor = Color(0xFFD3D3D3); // Light Gray
const Color kBackgroundColor = Color(0xFF1E212D); // Dark Slate
const Color kSurfaceColor = Color(0xFF2B2E3A); // Medium Slate
const Color kAccentColor = Color(0xFF7B68EE); // Medium Slate Blue
const Color kTextColor = Color(0xFFEAEAEA); // Light Gray
const Color kSubtleTextColor = Color(0xFFA0A0A0); // Gray

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: kBackgroundColor,
  primaryColor: kPrimaryColor,
  hintColor: kSubtleTextColor,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: kSurfaceColor,
    elevation: 0,
    iconTheme: IconThemeData(color: kTextColor),
    titleTextStyle: TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  cardTheme: CardThemeData(
    color: kSurfaceColor,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: kTextColor),
    headlineMedium: TextStyle(color: kTextColor, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: kTextColor),
    titleLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: kTextColor),
    bodyMedium: TextStyle(color: kSubtleTextColor),
    labelLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    labelStyle: const TextStyle(color: kSubtleTextColor),
    hintStyle: const TextStyle(color: kSubtleTextColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: kTextColor,
      backgroundColor: kAccentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
);