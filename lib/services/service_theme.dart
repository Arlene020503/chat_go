// lib/services/service_theme.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_langue.dart';

class ServiceTheme {
  static const String _cle = "mode_apparence";

  // Notifie automatiquement MaterialApp dès que la valeur change
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  /// À appeler au tout début de l'app (dans main()) pour charger le choix sauvegardé
  static Future<void> chargerThemeSauvegarde() async {
    final prefs = await SharedPreferences.getInstance();
    final valeur = prefs.getString(_cle) ?? "system";
    themeNotifier.value = _texteVersThemeMode(valeur);
  }

  /// Change le thème et le sauvegarde immédiatement
  static Future<void> changerTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, _themeModeVersTexte(mode));
  }

  static ThemeMode _texteVersThemeMode(String texte) {
    switch (texte) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeVersTexte(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "light";
      case ThemeMode.dark:
        return "dark";
      default:
        return "system";
    }
  }

  /// Texte à afficher dans les Paramètres selon le mode actuel
  static String texteAffichage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return ServiceLangue.texte("apparence_clair");
      case ThemeMode.dark:
        return ServiceLangue.texte("apparence_sombre");
      default:
        return ServiceLangue.texte("apparence_systeme");
    }
  }
}
