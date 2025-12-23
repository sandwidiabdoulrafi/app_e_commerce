import 'package:flutter/material.dart';

/// Couleurs principales
const Color primaryColor = Color(0xFFF27438);
const Color accentColor = Color(0xFFF9968B);
const Color darkBlue = Color(0xFF26474E);
const Color lightTurquoise = Color(0xFF76CDCD);
const Color turquoise = Color(0xFF2CCED2);

///  Thème global de l'application
final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: Colors.white,

  /// Couleurs
  primaryColor: primaryColor,

  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: turquoise,
  ),

  /// AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),

  /// Textes
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: darkBlue,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: darkBlue,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: darkBlue,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      color: Colors.grey,
    ),
  ),

  /// Boutons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
