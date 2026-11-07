// lib/services/service_historique.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceHistorique {
  static const String _cle = "historique_recherches";

  /// Ajoute une nouvelle recherche à l'historique
  static Future<void> ajouterRecherche(String texte) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = await obtenirHistorique();

    // Ajoute la nouvelle recherche en tête de liste, avec la date/heure
    liste.insert(0, {"texte": texte, "date": DateTime.now().toIso8601String()});

    // Limite à 50 recherches max, pour ne pas surcharger le stockage
    final listeLimitee = liste.take(50).toList();

    await prefs.setString(_cle, jsonEncode(listeLimitee));
  }

  /// Récupère tout l'historique, du plus récent au plus ancien
  static Future<List<Map<String, dynamic>>> obtenirHistorique() async {
    final prefs = await SharedPreferences.getInstance();
    final contenu = prefs.getString(_cle);
    if (contenu == null) return [];

    try {
      final liste = jsonDecode(contenu) as List;
      return liste.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Vide complètement l'historique
  static Future<void> effacerHistorique() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cle);
  }
}
