import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandBlue = Color(0xFF144295);
  static const Color darkBackground = Color(0xFF0F172A); // Deep slate blue for premium dark mode
  
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandBlue,
      primary: brandBlue,
      brightness: Brightness.light,
      surface: const Color(0xFFF8FAFC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      iconTheme: IconThemeData(color: brandBlue),
      titleTextStyle: TextStyle(color: brandBlue, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      selectedItemColor: brandBlue,
      unselectedItemColor: Colors.grey,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      indicatorColor: brandBlue.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: brandBlue, fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: Colors.grey);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: brandBlue);
        }
        return const IconThemeData(color: Colors.grey);
      }),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandBlue,
      primary: const Color(0xFF4B83F4), // Slightly lighter blue for dark mode contrast
      brightness: Brightness.dark,
      surface: darkBackground,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4B83F4),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B), // Elevated slightly lighter shade for contrast
      elevation: 8,
      selectedItemColor: Color(0xFF4B83F4),
      unselectedItemColor: Colors.white60,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E293B),
      elevation: 8,
      indicatorColor: const Color(0xFF4B83F4).withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Color(0xFF4B83F4), fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: Colors.white60);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF4B83F4));
        }
        return const IconThemeData(color: Colors.white60);
      }),
    ),
  );
}
