import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../modeles/prestataire.dart';

class ReponseChat {
  final String message;
  final List<Prestataire> prestataires;
  ReponseChat({required this.message, required this.prestataires});
}

class ServiceIA {
  // ⚠️ IMPORTANT : remplace cette valeur par l'adresse IPv4 locale de TON PC,
  // trouvée avec la commande "ipconfig" dans PowerShell (ex: "192.168.1.42").
  // Nécessaire pour tester depuis un VRAI téléphone : l'émulateur utilise
  // 10.0.2.2, mais un appareil physique doit accéder au PC sur le réseau local.
  static const String _ipLocalePC = "192.168.1.85"; // IP locale de ton PC
  static const String _ipEmulateurAndroid = "10.0.2.2";

  static String get _baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) {
      if (_ipLocalePC == "192.168.1.XX") {
        return "http://$_ipEmulateurAndroid:8000";
      }
      return "http://$_ipLocalePC:8000";
    }
    return "http://localhost:8000";
  }

  static Future<ReponseChat> envoyerMessage(String message) async {
    final url = Uri.parse("$_baseUrl/chat");

    try {
      final reponse = await http
          .post(
            url,
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: jsonEncode({"message": message}),
          )
          // Délai maximum d'attente : évite que l'app reste bloquée
          // indéfiniment si le serveur est injoignable (mauvaise IP,
          // pare-feu bloquant, PC éteint, etc.)
          .timeout(const Duration(seconds: 15));

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
      // Avant, une erreur réseau ne remontait nulle part de façon visible :
      // maintenant le message d'erreur exact s'affiche dans le chat,
      // ce qui aide à diagnostiquer (mauvaise IP, pare-feu, serveur éteint...)
      return ReponseChat(
        message: "Impossible de contacter le serveur ($_baseUrl). "
            "Vérifie que le serveur Python tourne, que le pare-feu autorise "
            "le port 8000, que ton téléphone et ton PC sont sur le même réseau, "
            "et que l'IP de ton PC est correctement renseignée dans ServiceIA. "
            "Détail : $e",
        prestataires: [],
      );
    }
  }
}