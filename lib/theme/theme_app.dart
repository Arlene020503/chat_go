// lib/theme/theme_app.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Couleurs et thèmes de Mes Prestataires, centralisés pour un rendu homogène.
/// Les couleurs sont celles d'origine de l'application.
class ThemeApp {
  static const Color vert = Color(0xFF00A859);
  static const Color vertVif = Color.fromARGB(255, 33, 205, 39);
  static const Color vertPale = Color.fromARGB(255, 210, 245, 212);
  static const Color fondSombre = Color(0xFF121212);
  static const Color surfaceSombre = Color(0xFF1E1E1E);
  static const Color bulleSombre = Color(0xFF262D31);

  static const double rayon = 16;

  static bool estSombre(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Fond des bulles de l'assistant et des zones secondaires
  static Color surfaceDouce(BuildContext context) =>
      estSombre(context) ? bulleSombre : const Color(0xFFF2F4F3);

  static Color bordure(BuildContext context) =>
      estSombre(context) ? const Color(0xFF2E3437) : const Color(0xFFE6E9E8);

  static Color texteSecondaire(BuildContext context) =>
      estSombre(context) ? Colors.white60 : Colors.black54;

  static ThemeData clair() => _construire(Brightness.light);
  static ThemeData sombre() => _construire(Brightness.dark);

  static ThemeData _construire(Brightness luminosite) {
    final sombre = luminosite == Brightness.dark;
    final fond = sombre ? fondSombre : Colors.white;
    final surface = sombre ? surfaceSombre : Colors.white;
    final texte = sombre ? Colors.white : const Color(0xFF111827);
    final schema = ColorScheme.fromSeed(
      seedColor: vert,
      brightness: luminosite,
    ).copyWith(primary: vert, surface: surface);
    final base = ThemeData(
      brightness: luminosite,
      useMaterial3: true,
      colorScheme: schema,
      scaffoldBackgroundColor: fond,
      cardColor: surface,
    );
    final bordureChamp = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(
        color: sombre ? const Color(0xFF2E3437) : const Color(0xFFE6E9E8),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(
        base.textTheme,
      ).apply(bodyColor: texte, displayColor: texte),
      appBarTheme: AppBarTheme(
        backgroundColor: fond,
        foregroundColor: texte,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          color: texte,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sombre ? surfaceSombre : const Color(0xFFF7F8F8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: sombre ? Colors.white38 : Colors.black38),
        border: bordureChamp,
        enabledBorder: bordureChamp,
        focusedBorder: bordureChamp.copyWith(
          borderSide: const BorderSide(color: vert, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vert,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: sombre ? Colors.white : const Color(0xFF111827),
          side: BorderSide(
            color: sombre ? const Color(0xFF3A4245) : const Color(0xFFDADFDD),
          ),
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: vert),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayon),
          side: BorderSide(
            color: sombre ? const Color(0xFF2E3437) : const Color(0xFFE6E9E8),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: sombre ? Colors.white70 : const Color(0xFF374151),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      dividerTheme: DividerThemeData(
        color: sombre ? const Color(0xFF2E3437) : const Color(0xFFEDEFEE),
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        side: BorderSide(
          color: sombre ? const Color(0xFF3A4245) : const Color(0xFFDADFDD),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: texte,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: vert),
    );
  }
}
