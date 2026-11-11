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

  group('ServiceIA — compréhension', () {
    test('reconnaît la catégorie, même avec une faute', () {
      expect(ServiceIA.categoriePour("Je recherche un plombiere"), "Plomberie");
      expect(ServiceIA.categoriePour("je veu me maquiller"), "Beauté");
    });

    test('comprend les suggestions dans les autres langues', () {
      expect(ServiceIA.categoriePour("I'm looking for a plumber"), "Plomberie");
      expect(ServiceIA.categoriePour("Ich suche einen Klempner"), "Plomberie");
      expect(ServiceIA.categoriePour("Busco un fontanero"), "Plomberie");
      expect(ServiceIA.categoriePour("我在找水管工"), "Plomberie");
      expect(ServiceIA.categoriePour("Where can I get a massage"), "Massage");
      expect(ServiceIA.categoriePour("我想在餐厅吃饭"), "Restaurant");
    });

    test('répond poliment sans lancer de recherche', () async {
      final bonjour = await ServiceIA.envoyerMessage("Bonjour");
      expect(bonjour.message, ServiceLangue.texte("ia_salutation"));
      final merci = await ServiceIA.envoyerMessage("okay merci");
      expect(merci.message, ServiceLangue.texte("ia_merci"));
      expect(merci.prestataires, isEmpty);
    });
  });

  group('ServiceIA — numéros ivoiriens', () {
    test('convertit les anciens numéros et ajoute WhatsApp aux mobiles', () {
      final mobile = ServiceIA.numerosPour({"phone": "+22547811698"});
      expect(mobile.telephone, "+225 07 47 81 16 98");
      expect(mobile.whatsapp, "2250747811698");

      final fixe = ServiceIA.numerosPour({"phone": "20371525"});
      expect(fixe.telephone, "+225 27 20 37 15 25");
      expect(fixe.whatsapp, isEmpty);

      final nouveau = ServiceIA.numerosPour({"phone": "+225 05 20 16 82 11"});
      expect(nouveau.whatsapp, "2250520168211");
    });

    test('garde un numéro étranger tel quel', () {
      final etranger = ServiceIA.numerosPour({
        "phone": "+33 6 12 34 56 78",
      }, coteDIvoire: false);
      expect(etranger.telephone, "+33 6 12 34 56 78");
      expect(etranger.whatsapp, isEmpty);
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
