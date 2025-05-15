import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) return Colors.teal.shade100;
        return Colors.teal;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      elevation: WidgetStateProperty.resolveWith<double>((states) => states.contains(WidgetState.pressed) ? 6 : 2),
      shadowColor: WidgetStateProperty.all<Color>(Colors.tealAccent),
    ),
  ),

  // Text Theme
  textTheme: GoogleFonts.poppinsTextTheme(),
);
