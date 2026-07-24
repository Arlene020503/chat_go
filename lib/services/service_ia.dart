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
  static String get _baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://localhost:8000";
  }

  static Future<ReponseChat> envoyerMessage(String message) async {
    final url = Uri.parse("$_baseUrl/chat");
    final reponse = await http.post(
      url,
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode({"message": message}),
    );

    final data = jsonDecode(utf8.decode(reponse.bodyBytes));

    if (data["succes"] == true) {
      final liste = (data["prestataires"] as List)
          .map((p) => Prestataire.fromJson(p))
          .toList();
      return ReponseChat(message: data["message"], prestataires: liste);
    } else {
      return ReponseChat(message: "Erreur : ${data["erreur"]}", prestataires: []);
    }
  }
}