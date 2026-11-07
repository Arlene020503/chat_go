import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_go_app/modeles/prestataire.dart';
import 'package:chat_go_app/services/service_ia.dart';
import 'package:chat_go_app/services/service_langue.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ServiceLangue.langueNotifier.value = ServiceLangue.fr;
  });

  group('ServiceIA', () {
    test('trouve un plombier en français, même avec une faute', () async {
      final reponse = await ServiceIA.envoyerMessage(
        "Je recherche un plombiere",
      );
      expect(
        reponse.prestataires.map((p) => p.categorie),
        contains("Plomberie"),
      );
    });

    test('comprend les suggestions dans les autres langues', () async {
      for (final message in [
        "I'm looking for a plumber",
        "Ich suche einen Klempner",
        "Busco un fontanero",
        "我在找水管工",
        "Where can I get a massage",
        "我想在餐厅吃饭",
      ]) {
        final reponse = await ServiceIA.envoyerMessage(message);
        expect(reponse.prestataires, isNotEmpty, reason: message);
      }
    });

    test('répond à une simple salutation sans chercher', () async {
      final reponse = await ServiceIA.envoyerMessage("Bonjour");
      expect(reponse.prestataires, isEmpty);
      expect(reponse.message, ServiceLangue.texte("ia_salutation"));
    });
  });

  test('Prestataire.fromJson accepte des valeurs manquantes ou booléennes', () {
    final p = Prestataire.fromJson({
      "id": "7",
      "nom": "Test",
      "note": null,
      "ouvert": true,
    });
    expect(p.id, 7);
    expect(p.note, 0);
    expect(p.ouvert, isTrue);
    expect(Prestataire.fromJson(p.toJson()).nom, "Test");
  });
}
