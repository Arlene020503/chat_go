import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_go_app/ecrans/ecran_chat.dart';
import 'package:chat_go_app/modeles/prestataire.dart';
import 'package:chat_go_app/services/service_ia.dart';
import 'package:chat_go_app/services/service_langue.dart';
import 'package:chat_go_app/widgets/carte_prestataire.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ServiceLangue.langueNotifier.value = ServiceLangue.fr;
    ServiceIA.reinitialiserConversation();
  });

  group('ServiceIA — compréhension', () {
    test('reconnaît la catégorie, même avec une faute', () {
      expect(ServiceIA.categoriePour("Je recherche un plombiere"), "Plomberie");
      expect(ServiceIA.categoriePour("je veu me maquiller"), "Beauté");
      expect(
        ServiceIA.categoriePour("je veux acheter des chaussures"),
        "Chaussures",
      );
      expect(ServiceIA.categoriePour("un iphone pas cher"), "Téléphones");
    });

    test('comprend les autres langues', () {
      expect(ServiceIA.categoriePour("I'm looking for a plumber"), "Plomberie");
      expect(ServiceIA.categoriePour("Ich suche einen Klempner"), "Plomberie");
      expect(ServiceIA.categoriePour("Busco un fontanero"), "Plomberie");
      expect(ServiceIA.categoriePour("我在找水管工"), "Plomberie");
      expect(ServiceIA.categoriePour("Where can I get a massage"), "Massage");
      expect(ServiceIA.categoriePour("我想在餐厅吃饭"), "Restaurant");
    });

    test('les catégories affichées sur l\'accueil sont comprises', () {
      for (final langue in ["fr", "en", "de", "es", "zh"]) {
        ServiceLangue.langueNotifier.value = langue;
        for (final cat in [
          "Pharmacie",
          "Restaurant",
          "Coiffure",
          "Beauté",
          "Plomberie",
          "Mécanique",
          "Hôtel",
          "Chaussures",
        ]) {
          expect(
            ServiceIA.categoriePour(ServiceLangue.texte("cat_$cat")),
            cat,
            reason: "$langue : ${ServiceLangue.texte("cat_$cat")}",
          );
        }
      }
    });

    test('converse poliment sans lancer de recherche', () async {
      final bonjour = await ServiceIA.envoyerMessage("Bonjour");
      expect(bonjour.prestataires, isEmpty);
      expect(bonjour.suggestions, isNotEmpty);

      final quiEsTu = await ServiceIA.envoyerMessage("qui es-tu ?");
      expect(quiEsTu.message, ServiceLangue.texte("ia_presentation"));

      final merci = await ServiceIA.envoyerMessage("okay merci");
      expect(merci.message, ServiceLangue.texte("ia_merci"));
    });

    test('un achat inconnu propose de vraies boutiques en ligne', () async {
      final reponse = await ServiceIA.envoyerMessage(
        "je veux acheter une trottinette",
      );
      expect(reponse.liens.map((l) => l.url).join(" "), contains("jumia.ci"));
      expect(reponse.liens.first.url, contains("trottinette"));
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
      "latitude": "5.3",
    });
    expect(p.id, 7);
    expect(p.note, 0);
    expect(p.ouvert, isTrue);
    expect(p.latitude, 5.3);
    expect(Prestataire.fromJson(p.toJson()).nom, "Test");
  });

  group('Affichage', () {
    final long = Prestataire(
      id: 1,
      nom: "Pharmacie Saint-Jean de Cocody et des Deux Plateaux Vallons",
      categorie: "Pharmacie",
      description: "",
      telephone: "+225 27 22 44 62 49",
      whatsapp: "2250747811698",
      note: 4.5,
      prix: "",
      adresse:
          "Boulevard André Latrille, Vieux Cocody, Cocody, Abidjan, Côte d'Ivoire, très longue adresse",
      ouvert: null,
      siteWeb: "https://exemple.ci",
      horaires: "Mo-Sa 08:00-21:00; Su 09:00-13:00",
    );

    testWidgets('la fiche compacte tient dans le carrousel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: CartePrestataire.hauteurCompacte,
                child: CartePrestataire(prestataire: long, compacte: true),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text("WhatsApp"), findsOneWidget);
    });

    testWidgets("l'écran d'accueil du chat s'affiche", (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: EcranChat()));
      expect(tester.takeException(), isNull);
      expect(find.text(ServiceLangue.texte("chat_accueil_titre")), findsOne);
      expect(find.text(ServiceLangue.texte("cat_Pharmacie")), findsOne);
    });
  });
}
