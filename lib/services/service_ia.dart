import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/prestataire.dart';
import 'service_langue.dart';

class ReponseChat {
  final String message;
  final List<Prestataire> prestataires;
  ReponseChat({required this.message, required this.prestataires});
}

/// Une catégorie de service : mots-clés reconnus (toutes langues) et requêtes
/// OpenStreetMap essayées dans l'ordre ({v} = ville). Nominatim réagit très
/// différemment selon la formulation, d'où une requête de secours.
class _Categorie {
  final String nom;
  final List<String> requetes;
  final List<String> motsCles;
  const _Categorie(this.nom, this.requetes, this.motsCles);
}

class ServiceIA {
  static const String _clePrestataires = "prestataires_locaux";
  static const String _urlRecherche =
      "https://nominatim.openstreetmap.org/search";

  // Backend optionnel : `flutter run --dart-define=API_URL=https://mon-serveur.com`.
  // S'il est absent ou injoignable, l'assistant fonctionne entièrement en local.
  static const String _urlBackend = String.fromEnvironment("API_URL");

  // Zone utilisée quand l'utilisateur ne précise pas de ville
  static const String _villeParDefaut = "Abidjan";
  static const String _paysParDefaut = "ci";

  static final List<Prestataire> _prestataires = [
    Prestataire(
      id: 1,
      nom: "Atelier Martin",
      categorie: "Plomberie",
      description: "Dépannage et rénovation de plomberie.",
      telephone: "0123456789",
      whatsapp: "33612345678",
      note: 4.8,
      prix: "€€",
      adresse: "10 rue de la République",
      ouvert: true,
      imageUrl: null,
    ),
    Prestataire(
      id: 2,
      nom: "L'Instant Zen",
      categorie: "Massage",
      description: "Massages relaxants et soins bien-être.",
      telephone: "0123456790",
      whatsapp: "33612345679",
      note: 4.7,
      prix: "€€€",
      adresse: "24 avenue Victor Hugo",
      ouvert: true,
      imageUrl: null,
    ),
    Prestataire(
      id: 3,
      nom: "Le Jardin Gourmand",
      categorie: "Restaurant",
      description: "Cuisine maison, produits frais et locaux.",
      telephone: "0123456791",
      whatsapp: "33612345680",
      note: 4.6,
      prix: "€€",
      adresse: "5 place du Marché",
      ouvert: true,
      imageUrl: null,
    ),
  ];

  static const List<_Categorie> _categories = [
    _Categorie(
      "Plomberie",
      ["plombier {v}", "plomberie {v}"],
      [
        "plombier",
        "plomberie",
        "fuite",
        "tuyau",
        "robinet",
        "plumber",
        "plumbing",
        "klempner",
        "installateur",
        "fontanero",
        "fontaneria",
        "水管工",
        "管道",
      ],
    ),
    _Categorie(
      "Massage",
      ["massage {v}", "spa {v}"],
      [
        "massage",
        "masseur",
        "masseuse",
        "bien etre",
        "bienetre",
        "spa",
        "masaje",
        "wellness",
        "按摩",
      ],
    ),
    _Categorie(
      "Restaurant",
      ["restaurant {v}", "restaurant in {v}"],
      [
        "restaurant",
        "restaurants",
        "manger",
        "repas",
        "diner",
        "dejeuner",
        "maquis",
        "eat",
        "food",
        "lunch",
        "dinner",
        "essen",
        "restaurante",
        "comer",
        "餐厅",
        "吃饭",
      ],
    ),
    _Categorie(
      "Coiffure",
      ["coiffeur {v}", "hairdresser in {v}"],
      [
        "coiffeur",
        "coiffeuse",
        "coiffure",
        "salon",
        "tresse",
        "barbier",
        "hairdresser",
        "barber",
        "haircut",
        "friseur",
        "peluqueria",
        "peluquero",
        "理发",
      ],
    ),
    _Categorie(
      "Électricité",
      ["electricien {v}", "electrician in {v}"],
      [
        "electricien",
        "electricite",
        "electrician",
        "elektriker",
        "electricista",
        "电工",
      ],
    ),
    _Categorie(
      "Mécanique",
      ["garage {v}", "car repair in {v}"],
      [
        "mecanicien",
        "mecanique",
        "garage",
        "garagiste",
        "mechanic",
        "werkstatt",
        "mecanico",
        "taller",
        "修车",
      ],
    ),
    _Categorie(
      "Pharmacie",
      ["pharmacie {v}", "pharmacy in {v}"],
      ["pharmacie", "medicament", "pharmacy", "apotheke", "farmacia", "药店"],
    ),
    _Categorie(
      "Hôtel",
      ["hotel in {v}", "hotel {v}"],
      [
        "hotel",
        "hotels",
        "dormir",
        "chambre",
        "hebergement",
        "unterkunft",
        "alojamiento",
        "酒店",
      ],
    ),
  ];

  // Mots courants retirés avant une recherche libre sur Internet
  static const Set<String> _motsVides = {
    "je",
    "j",
    "cherche",
    "recherche",
    "veux",
    "voudrais",
    "besoin",
    "trouver",
    "un",
    "une",
    "des",
    "le",
    "la",
    "les",
    "l",
    "de",
    "du",
    "d",
    "ou",
    "puis",
    "peux",
    "faire",
    "bon",
    "bonne",
    "pres",
    "chez",
    "moi",
    "dans",
    "pour",
    "svp",
    "stp",
    "bonjour",
    "salut",
    "i",
    "m",
    "im",
    "am",
    "looking",
    "for",
    "a",
    "an",
    "the",
    "want",
    "need",
    "where",
    "can",
    "get",
    "find",
    "please",
    "ich",
    "suche",
    "einen",
    "eine",
    "busco",
    "quiero",
    "donde",
    "puedo",
    "hello",
    "hi",
    "hola",
    "hallo",
  };

  static Future<ReponseChat> envoyerMessage(String message) async {
    final depuisBackend = await _interrogerBackend(message);
    if (depuisBackend != null) return depuisBackend;

    final texte = _normaliser(message);
    final categorie = _trouverCategorie(message);
    final ville = _trouverVille(texte);
    final motsUtiles = texte
        .split(' ')
        .where((mot) => mot.isNotEmpty && !_motsVides.contains(mot))
        .toList();

    if (categorie == null && motsUtiles.isEmpty) {
      return ReponseChat(
        message: ServiceLangue.texte("ia_salutation"),
        prestataires: [],
      );
    }

    final stockes = await _chargerPrestataires();
    final resultats =
        <int, Prestataire>{
              for (final prestataire in [..._prestataires, ...stockes])
                if (categorie != null
                    ? _normaliser(prestataire.categorie) ==
                          _normaliser(categorie.nom)
                    : _correspond(prestataire, motsUtiles))
                  prestataire.id: prestataire,
            }.values
            .where(
              (prestataire) => ville == null || _dansVille(prestataire, ville),
            )
            .toList();

    if (resultats.isNotEmpty) {
      return ReponseChat(
        message: ServiceLangue.texte("ia_resultats"),
        prestataires: resultats,
      );
    }

    final requetes =
        categorie?.requetes ??
        [
          "${motsUtiles.where((mot) => !(ville ?? '').split(' ').contains(mot)).join(' ')} {v}",
        ];
    var trouvaille = <Prestataire>[];
    for (final requete in requetes) {
      trouvaille = await _chercherSurInternet(
        requete.replaceAll("{v}", ville ?? _villeParDefaut),
        categorie?.nom,
        ville,
      );
      if (trouvaille.isNotEmpty) break;
      // Politique d'usage de Nominatim : une requête par seconde maximum
      await Future.delayed(const Duration(seconds: 1));
    }
    if (trouvaille.isNotEmpty) {
      await _sauvegarderPrestataires(trouvaille);
      return ReponseChat(
        message: ServiceLangue.texte("ia_internet"),
        prestataires: trouvaille,
      );
    }

    return ReponseChat(
      message: ServiceLangue.texte("ia_aucun"),
      prestataires: [],
    );
  }

  static Future<ReponseChat?> _interrogerBackend(String message) async {
    if (_urlBackend.isEmpty) return null;
    try {
      final reponse = await http
          .post(
            Uri.parse("$_urlBackend/chat"),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: jsonEncode({
              "message": message,
              "langue": ServiceLangue.langueNotifier.value,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (reponse.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(reponse.bodyBytes));
      if (data["succes"] != true) return null;
      final liste = (data["prestataires"] as List? ?? [])
          .map((p) => Prestataire.fromJson(Map<String, dynamic>.from(p)))
          .toList();
      // Un backend sans résultat laisse la main à la recherche locale / Internet
      if (liste.isEmpty) return null;
      return ReponseChat(
        message: data["message"]?.toString() ?? "",
        prestataires: liste,
      );
    } catch (_) {
      return null;
    }
  }

  static String _normaliser(String valeur) {
    const accents = "àáâäãåçèéêëìíîïñòóôöõùúûüýÿ";
    const simples = "aaaaaaceeeeiiiinooooouuuuyy";
    var resultat = valeur.toLowerCase();
    for (var index = 0; index < accents.length; index++) {
      resultat = resultat.replaceAll(accents[index], simples[index]);
    }
    return resultat
        .replaceAll(RegExp(r"[^a-z0-9 ]"), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  static _Categorie? _trouverCategorie(String message) {
    final texte = _normaliser(message);
    for (final categorie in _categories) {
      final trouve = categorie.motsCles.any((mot) {
        final motNormalise = _normaliser(mot);
        // Mots non latins (chinois) : recherche directe dans le message brut
        if (motNormalise.isEmpty) return message.contains(mot);
        if (motNormalise.contains(' ')) return texte.contains(motNormalise);
        return _motProche(texte, motNormalise);
      });
      if (trouve) return categorie;
    }
    return null;
  }

  /// Repère une ville écrite après "à", "a", "in", "en", "sur" ou "vers" (ex: "plombier à Cocody")
  static String? _trouverVille(String texte) {
    final correspondance = RegExp(
      r"(?:^| )(?:a|in|en|sur|vers|near|pres de) ([a-z][a-z0-9 ]+)$",
    ).firstMatch(texte);
    final ville = correspondance?.group(1)?.trim();
    if (ville == null || ville.length < 3 || _trouverCategorie(ville) != null) {
      return null;
    }
    return ville;
  }

  static bool _motProche(String texte, String mot) {
    final tolerance = mot.length <= 4 ? 0 : (mot.length > 6 ? 2 : 1);
    return texte
        .split(' ')
        .any(
          (motTexte) =>
              motTexte == mot ||
              (motTexte.length > 3 && _distance(motTexte, mot) <= tolerance),
        );
  }

  static bool _correspond(Prestataire prestataire, List<String> mots) {
    final contenu = _normaliser(
      "${prestataire.nom} ${prestataire.categorie} ${prestataire.adresse}",
    );
    return mots.any((mot) => mot.length > 2 && contenu.contains(mot));
  }

  static bool _dansVille(Prestataire prestataire, String ville) =>
      _normaliser(prestataire.adresse).contains(ville);

  static int _distance(String premier, String second) {
    final ligne = List<int>.generate(second.length + 1, (index) => index);
    for (var i = 1; i <= premier.length; i++) {
      var diagonale = ligne[0];
      ligne[0] = i;
      for (var j = 1; j <= second.length; j++) {
        final auDessus = ligne[j];
        ligne[j] = premier[i - 1] == second[j - 1]
            ? diagonale
            : 1 +
                  [
                    diagonale,
                    ligne[j - 1],
                    auDessus,
                  ].reduce((a, b) => a < b ? a : b);
        diagonale = auDessus;
      }
    }
    return ligne[second.length];
  }

  static Future<List<Prestataire>> _chargerPrestataires() async {
    final prefs = await SharedPreferences.getInstance();
    final contenu = prefs.getString(_clePrestataires);
    if (contenu == null) return [];
    try {
      return (jsonDecode(contenu) as List)
          .map(
            (element) =>
                Prestataire.fromJson(Map<String, dynamic>.from(element)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _sauvegarderPrestataires(
    List<Prestataire> nouveaux,
  ) async {
    final tous = [...await _chargerPrestataires(), ...nouveaux];
    final uniques = <int, Prestataire>{
      for (final prestataire in tous) prestataire.id: prestataire,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _clePrestataires,
      jsonEncode(
        uniques.values.map((prestataire) => prestataire.toJson()).toList(),
      ),
    );
  }

  static Future<List<Prestataire>> _chercherSurInternet(
    String requete,
    String? categorie,
    String? ville,
  ) async {
    if (requete.replaceAll(ville ?? _villeParDefaut, "").trim().isEmpty) {
      return [];
    }
    try {
      final parametres = {
        "q": requete,
        "format": "jsonv2",
        "limit": "10",
        "addressdetails": "1",
        "extratags": "1",
        "accept-language": ServiceLangue.langueNotifier.value,
        if (ville == null) "countrycodes": _paysParDefaut,
      };
      final reponse = await http
          .get(
            Uri.parse(_urlRecherche).replace(queryParameters: parametres),
            headers: {
              "User-Agent": "ChatGoApp/1.0 (recherche de prestataires)",
            },
          )
          .timeout(const Duration(seconds: 10));
      if (reponse.statusCode != 200) return [];
      final donnees = jsonDecode(utf8.decode(reponse.bodyBytes)) as List;
      // Écarte les arrêts de bus, routes, quartiers… qui portent juste le nom du service
      const categoriesIgnorees = {
        "highway",
        "public_transport",
        "railway",
        "boundary",
        "place",
        "landuse",
        "natural",
        "waterway",
      };
      return donnees
          .map((element) => Map<String, dynamic>.from(element))
          .where(
            (valeur) =>
                !categoriesIgnorees.contains(valeur["category"]) &&
                valeur["extratags"]?["public_transport"] == null,
          )
          .map((valeur) {
            final extras = Map<String, dynamic>.from(valeur["extratags"] ?? {});
            final adresse = valeur["display_name"]?.toString() ?? "";
            final telephone = (extras["phone"] ?? extras["contact:phone"] ?? "")
                .toString()
                .split(";")
                .first
                .trim();
            final whatsapp = (extras["contact:whatsapp"] ?? "")
                .toString()
                .replaceAll(RegExp(r"[^0-9]"), "");
            final nom = valeur["name"]?.toString();
            return Prestataire(
              // Identifiant stable basé sur l'objet OpenStreetMap : pas de doublons entre recherches
              id:
                  -(int.tryParse(valeur["osm_id"].toString()) ??
                      adresse.hashCode.abs()),
              nom: (nom == null || nom.isEmpty)
                  ? adresse.split(",").first
                  : nom,
              categorie: categorie ?? "Service",
              description: ServiceLangue.texte("ia_description_internet"),
              telephone: telephone,
              whatsapp: whatsapp,
              note: 0,
              prix: "",
              adresse: adresse,
              ouvert: null,
              imageUrl: null,
            );
          })
          .toList();
    } catch (_) {
      return [];
    }
  }
}
