import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modeles/prestataire.dart';

class ReponseChat {
  final String message;
  final List<Prestataire> prestataires;
  ReponseChat({required this.message, required this.prestataires});
}

class ServiceIA {
  // Le backend est maintenant hébergé sur Render, accessible depuis
  // n'importe quel réseau (Wi-Fi, 4G, 5G...) — plus besoin de distinguer
  // web / émulateur / vrai téléphone, ni de gérer une IP locale.
  static const String _baseUrl = "https://backend-chatgo.onrender.com";

  static Future<ReponseChat> envoyerMessage(String message) async {
    final url = Uri.parse("$_baseUrl/chat");

    try {
      final reponse = await http
          .post(
            url,
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: jsonEncode({"message": message}),
          )
          // Délai généreux : le plan gratuit de Render met le serveur en
          // veille après inactivité, la toute première requête peut donc
          // prendre jusqu'à 50 secondes le temps qu'il "se réveille".
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(utf8.decode(reponse.bodyBytes));

      if (data["succes"] == true) {
        final liste = (data["prestataires"] as List)
            .map((p) => Prestataire.fromJson(p))
            .toList();
        return ReponseChat(message: data["message"], prestataires: liste);
      } else {
        return ReponseChat(message: "Erreur : ${data["erreur"]}", prestataires: []);
      }
    } catch (e) {
      return ReponseChat(
        message: "Impossible de contacter le serveur. "
            "Si c'est la première requête depuis un moment, le serveur peut "
            "mettre jusqu'à 50 secondes à se réveiller — réessaie dans "
            "quelques instants. Détail : $e",
        prestataires: [],
      );
    }
  }
}