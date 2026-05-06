import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primary = Color(0xFFE50914);    
  static const Color _surface = Color(0xFF1A1A2E);
  static const Color _background = Color(0xFF0F0F1A);
  static const Color _card = Color(0xFF16213E);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _textPrimary = Color(0xFFF5F5F5);
  static const Color _textSecondary = Color(0xFF9E9E9E);

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        surface: _surface,
        onSurface: _textPrimary,
        secondary: _gold,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: _background,
      cardColor: _card,
      appBarTheme: AppBarTheme(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: _textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          letterSpacing: 1.2,
          color: _textSecondary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _card,
        selectedColor: _primary,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: _textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary);
          }
          return const IconThemeData(color: _textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: _primary);
          }
          return GoogleFonts.inter(fontSize: 12, color: _textSecondary);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _card,
        hintStyle: GoogleFonts.inter(color: _textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: _textSecondary,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: _primary),
    );
  }

  static const Color primary = _primary;
  static const Color gold = _gold;
  static const Color cardColor = _card;
  static const Color textPrimary = _textPrimary;
  static const Color textSecondary = _textSecondary;
  static const Color background = _background;
}
