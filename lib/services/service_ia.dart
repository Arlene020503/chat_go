import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/prestataire.dart';
import 'service_langue.dart';

class ReponseChat {
  final String message;
  final List<Prestataire> prestataires;
  ReponseChat({required this.message, required this.prestataires});
}

/// Une catégorie de service :
/// - [osm] : filtres OpenStreetMap (clé=valeur) utilisés avec Overpass, qui
///   renvoie les vrais établissements avec leurs numéros quand ils existent ;
/// - [requetes] : recherches Nominatim de secours ({v} = ville) ;
/// - [motsCles] : mots reconnus dans le message, toutes langues confondues.
class _Categorie {
  final String nom;
  final List<String> osm;
  final List<String> requetes;
  final List<String> motsCles;
  const _Categorie(this.nom, this.osm, this.requetes, this.motsCles);
}

class ServiceIA {
  // v2 : les anciennes sauvegardes (sans numéros) sont ignorées
  static const String _clePrestataires = "prestataires_locaux_v2";
  static const String _urlNominatim =
      "https://nominatim.openstreetmap.org/search";
  static const List<String> _urlsOverpass = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
  ];
  // Abidjan (sud, ouest, nord, est) et cache des autres villes déjà cherchées
  static const String _rectangleParDefaut = "5.16,-4.18,5.48,-3.85";
  static final Map<String, String> _rectangles = {};
  // Temps maximum d'attente d'Overpass avant de répondre avec les résultats rapides
  static const Duration _attenteOverpass = Duration(seconds: 20);
  // Les sauvegardes s'enchaînent pour ne jamais s'écraser entre elles
  static Future<void> _sauvegardeEnCours = Future.value();

  // Backend optionnel : `flutter run --dart-define=API_URL=https://mon-serveur.com`.
  // S'il est absent ou injoignable, l'assistant fonctionne entièrement en local.
  static const String _urlBackend = String.fromEnvironment("API_URL");

  // Zone utilisée quand l'utilisateur ne précise pas de ville
  static const String _villeParDefaut = "Abidjan";
  static const String _paysParDefaut = "ci";
  static const int _maxResultats = 15;

  static const List<_Categorie> _categories = [
    _Categorie(
      "Plomberie",
      ["craft=plumber", "shop=plumbing"],
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
      ["shop=massage", "leisure=spa", "amenity=spa"],
      ["massage {v}", "spa {v}"],
      [
        "massage",
        "masser",
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
      "Beauté",
      ["shop=beauty", "shop=cosmetics"],
      ["institut de beaute {v}", "beauty salon in {v}"],
      [
        "maquiller",
        "maquillage",
        "maquilleuse",
        "makeup",
        "beaute",
        "beauty",
        "esthetique",
        "estheticienne",
        "ongles",
        "onglerie",
        "manucure",
        "pedicure",
        "cosmetique",
        "cils",
        "epilation",
        "schminken",
        "maquillaje",
        "化妆",
        "美容",
      ],
    ),
    _Categorie(
      "Restaurant",
      ["amenity=restaurant", "amenity=fast_food"],
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
      ["shop=hairdresser"],
      ["coiffeur {v}", "hairdresser in {v}"],
      [
        "coiffeur",
        "coiffeuse",
        "coiffure",
        "coiffer",
        "salon",
        "tresse",
        "tresser",
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
      ["craft=electrician", "shop=electrical"],
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
      ["shop=car_repair", "craft=car_repair", "shop=tyres"],
      ["garage {v}", "car repair in {v}"],
      [
        "mecanicien",
        "mecanique",
        "garage",
        "garagiste",
        "vulcanisateur",
        "mechanic",
        "werkstatt",
        "mecanico",
        "taller",
        "修车",
      ],
    ),
    _Categorie(
      "Pharmacie",
      ["amenity=pharmacy"],
      ["pharmacie {v}", "pharmacy in {v}"],
      ["pharmacie", "medicament", "pharmacy", "apotheke", "farmacia", "药店"],
    ),
    _Categorie(
      "Santé",
      ["amenity=clinic", "amenity=hospital", "amenity=doctors"],
      ["clinique {v}", "hospital in {v}"],
      [
        "clinique",
        "hopital",
        "medecin",
        "docteur",
        "malade",
        "doctor",
        "hospital",
        "clinic",
        "arzt",
        "krankenhaus",
        "medico",
        "医院",
        "医生",
      ],
    ),
    _Categorie(
      "Couture",
      ["shop=tailor", "craft=tailor", "shop=fabric"],
      ["couturier {v}", "tailor in {v}"],
      [
        "couturier",
        "couturiere",
        "couture",
        "tailleur",
        "pagne",
        "tailor",
        "schneider",
        "sastre",
        "costurera",
        "裁缝",
      ],
    ),
    _Categorie(
      "Hôtel",
      ["tourism=hotel", "tourism=guest_house", "tourism=motel"],
      ["hotel in {v}", "hotel {v}"],
      [
        "hotel",
        "hotels",
        "dormir",
        "chambre",
        "hebergement",
        "residence",
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
    "veu",
    "veut",
    "voudrais",
    "voudrai",
    "aimerais",
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
    "aller",
    "bon",
    "bonne",
    "pres",
    "chez",
    "moi",
    "me",
    "mon",
    "ma",
    "mes",
    "se",
    "te",
    "il",
    "y",
    "est",
    "et",
    "au",
    "aux",
    "en",
    "dans",
    "pour",
    "avec",
    "quel",
    "quelle",
    "svp",
    "stp",
    "bonjour",
    "bonsoir",
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
    "to",
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

  // Messages de politesse : on répond sans lancer de recherche
  static const Set<String> _motsPolitesse = {
    "merci",
    "beaucoup",
    "ok",
    "okay",
    "oki",
    "daccord",
    "accord",
    "super",
    "cool",
    "parfait",
    "top",
    "genial",
    "bien",
    "bye",
    "revoir",
    "thanks",
    "thank",
    "you",
    "great",
    "danke",
    "gracias",
    "vale",
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
    if (categorie == null &&
        (motsUtiles.every(_motsPolitesse.contains) || message.contains("谢谢"))) {
      return ReponseChat(
        message: ServiceLangue.texte("ia_merci"),
        prestataires: [],
      );
    }

    // 1. Ce qui a déjà été trouvé et sauvegardé sur le téléphone
    final zone = ville ?? _normaliser(_villeParDefaut);
    final motsRecherche = motsUtiles
        .where((mot) => !zone.split(' ').contains(mot))
        .toList();
    final stockes = (await _chargerPrestataires())
        .where(
          (prestataire) =>
              (categorie != null
                  ? _normaliser(prestataire.categorie) ==
                        _normaliser(categorie.nom)
                  : _correspond(prestataire, motsRecherche)) &&
              _dansVille(prestataire, zone),
        )
        .toList();
    if (stockes.any(_aUnContact)) {
      return ReponseChat(
        message: ServiceLangue.texte("ia_resultats"),
        prestataires: _trier(stockes).take(_maxResultats).toList(),
      );
    }

    // 2. Sinon, vraie recherche sur Internet (OpenStreetMap), puis sauvegarde.
    // Overpass (établissements avec numéros) et Nominatim (rapide) partent en
    // parallèle. Si Overpass est trop lent, il continue en arrière-plan et ses
    // résultats seront prêts pour la prochaine recherche.
    final chrono = Stopwatch()..start();
    var overpassTermine = categorie == null;
    final overpass = categorie == null
        ? Future.value(<Prestataire>[])
        : _chercherOverpass(categorie, ville).then((liste) async {
            overpassTermine = true;
            await _sauvegarderPrestataires(liste);
            return liste;
          });

    final requetes =
        categorie?.requetes ??
        [
          "${motsRecherche.join(' ')} {v}",
          // Mot par mot si la phrase entière ne donne rien
          for (final mot in motsRecherche.where((m) => m.length > 3).take(2))
            if (motsRecherche.length > 1) "$mot {v}",
        ];
    var rapides = <Prestataire>[];
    for (final requete in requetes) {
      rapides = await _chercherNominatim(
        requete.replaceAll("{v}", ville ?? _villeParDefaut),
        categorie?.nom,
        ville,
      );
      if (rapides.isNotEmpty) break;
      // Politique d'usage de Nominatim : une requête par seconde maximum
      await Future.delayed(const Duration(seconds: 1));
    }

    final attente = _attenteOverpass - chrono.elapsed;
    final avecNumeros = await overpass.timeout(
      attente.isNegative ? Duration.zero : attente,
      onTimeout: () => <Prestataire>[],
    );
    final trouvaille = _trier(
      {
        for (final p in [...rapides, ...avecNumeros]) p.id: p,
      }.values.toList(),
    ).take(_maxResultats).toList();

    if (trouvaille.isNotEmpty) {
      await _sauvegarderPrestataires(trouvaille);
      return ReponseChat(
        message: ServiceLangue.texte(
          trouvaille.any(_aUnContact)
              ? "ia_internet"
              : (overpassTermine
                    ? "ia_internet_sans_numero"
                    : "ia_internet_numeros_en_cours"),
        ),
        prestataires: trouvaille,
      );
    }

    // Résultats sauvegardés sans numéro : mieux que rien
    if (stockes.isNotEmpty) {
      return ReponseChat(
        message: ServiceLangue.texte("ia_resultats"),
        prestataires: stockes,
      );
    }

    return ReponseChat(
      message: ServiceLangue.texte("ia_aucun"),
      prestataires: [],
    );
  }

  @visibleForTesting
  static String? categoriePour(String message) =>
      _trouverCategorie(message)?.nom;

  @visibleForTesting
  static ({String telephone, String whatsapp}) numerosPour(
    Map<String, dynamic> tags, {
    bool coteDIvoire = true,
  }) => _numeros(tags, coteDIvoire);

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
      "${prestataire.nom} ${prestataire.categorie} ${prestataire.description}",
    );
    return mots.any((mot) => mot.length > 2 && contenu.contains(mot));
  }

  static bool _dansVille(Prestataire prestataire, String ville) =>
      _normaliser(prestataire.adresse).contains(ville);

  static bool _aUnContact(Prestataire prestataire) =>
      prestataire.telephone.isNotEmpty || prestataire.whatsapp.isNotEmpty;

  /// Les prestataires joignables d'abord, puis ceux qui ont un vrai nom
  static List<Prestataire> _trier(List<Prestataire> liste) {
    int score(Prestataire p) =>
        (p.whatsapp.isNotEmpty ? 4 : 0) +
        (p.telephone.isNotEmpty ? 2 : 0) +
        (_normaliser(p.nom) != _normaliser(p.categorie) ? 1 : 0);
    return [...liste]..sort((a, b) => score(b).compareTo(score(a)));
  }

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

  /// Extrait téléphone et WhatsApp des tags OpenStreetMap.
  /// En Côte d'Ivoire, les anciens numéros à 8 chiffres sont convertis au
  /// format à 10 chiffres (2021) et les mobiles (01, 05, 07) reçoivent un lien WhatsApp.
  static ({String telephone, String whatsapp}) _numeros(
    Map<String, dynamic> tags,
    bool coteDIvoire,
  ) {
    final brut =
        (tags["phone"] ??
                tags["contact:phone"] ??
                tags["mobile"] ??
                tags["contact:mobile"] ??
                "")
            .toString()
            .split(RegExp(r"[;,/]"))
            .first
            .trim();
    var whatsapp = (tags["contact:whatsapp"] ?? tags["whatsapp"] ?? "")
        .toString()
        .split(";")
        .first
        .replaceAll(RegExp(r"[^0-9]"), "");
    if (brut.isEmpty) {
      return (
        telephone: whatsapp.isEmpty ? "" : "+$whatsapp",
        whatsapp: whatsapp,
      );
    }

    var chiffres = brut.replaceAll(RegExp(r"[^0-9]"), "");
    final international = brut.startsWith("+") || chiffres.startsWith("00");
    if (chiffres.startsWith("00")) chiffres = chiffres.substring(2);

    String? local;
    if (chiffres.startsWith("225") &&
        (chiffres.length == 11 || chiffres.length == 13)) {
      local = chiffres.substring(3);
    } else if (coteDIvoire &&
        !international &&
        (chiffres.length == 8 || chiffres.length == 10)) {
      local = chiffres;
    }
    if (local == null) return (telephone: brut, whatsapp: whatsapp);

    if (local.length == 8) {
      if (local.startsWith("2") || local.startsWith("3")) {
        local = "27$local"; // fixe
      } else {
        final chiffre = int.parse(local[1]);
        local = "${chiffre <= 3 ? "01" : (chiffre <= 6 ? "05" : "07")}$local";
      }
    }
    final mobile = ["01", "05", "07"].any(local.startsWith);
    if (whatsapp.isEmpty && mobile) whatsapp = "225$local";

    final groupes = [
      for (var i = 0; i < local.length; i += 2)
        local.substring(i, i + 2 > local.length ? local.length : i + 2),
    ];
    return (telephone: "+225 ${groupes.join(" ")}", whatsapp: whatsapp);
  }

  /// Rectangle géographique "sud,ouest,nord,est" de la ville, pour Overpass
  /// (bien plus rapide qu'une recherche de zone par nom).
  static Future<String?> _rectangleVille(String? ville) async {
    if (ville == null) return _rectangleParDefaut;
    if (_rectangles.containsKey(ville)) return _rectangles[ville];
    try {
      final reponse = await http
          .get(
            Uri.parse(_urlNominatim).replace(
              queryParameters: {"q": ville, "format": "jsonv2", "limit": "1"},
            ),
            headers: {
              "User-Agent": "ChatGoApp/1.0 (recherche de prestataires)",
            },
          )
          .timeout(const Duration(seconds: 10));
      final donnees = jsonDecode(utf8.decode(reponse.bodyBytes)) as List;
      if (donnees.isEmpty) return null;
      final b = (donnees.first["boundingbox"] as List)
          .map((e) => "$e")
          .toList();
      return _rectangles[ville] = "${b[0]},${b[2]},${b[1]},${b[3]}";
    } catch (_) {
      return null;
    }
  }

  static String _majuscule(String texte) => texte
      .split(" ")
      .map((m) => m.isEmpty ? m : m[0].toUpperCase() + m.substring(1))
      .join(" ");

  static Future<List<Prestataire>> _chercherOverpass(
    _Categorie categorie,
    String? ville,
  ) async {
    final zone = ville ?? _normaliser(_villeParDefaut);
    final rectangle = await _rectangleVille(ville);
    if (rectangle == null) return [];
    final filtres = categorie.osm.map((f) {
      final morceaux = f.split("=");
      return 'nwr["${morceaux[0]}"="${morceaux[1]}"]($rectangle);';
    }).join();
    final requete = '[out:json][timeout:60];($filtres);out center tags 300;';

    for (final url in _urlsOverpass) {
      try {
        final reponse = await http
            .post(
              Uri.parse(url),
              headers: {
                "User-Agent": "ChatGoApp/1.0 (recherche de prestataires)",
              },
              body: {"data": requete},
            )
            .timeout(const Duration(seconds: 70));
        if (reponse.statusCode != 200) continue;
        final elements =
            (jsonDecode(utf8.decode(reponse.bodyBytes))["elements"] as List?) ??
            [];
        final nomZone = _majuscule(zone);
        final liste = elements.map((element) {
          final valeur = Map<String, dynamic>.from(element);
          final tags = Map<String, dynamic>.from(valeur["tags"] ?? {});
          final numeros = _numeros(tags, ville == null);
          final adresse = [
            [
              tags["addr:housenumber"],
              tags["addr:street"],
            ].where((e) => e != null).join(" "),
            tags["addr:suburb"] ?? tags["addr:district"] ?? "",
            tags["addr:city"] ?? "",
            // La ville recherchée est toujours présente, pour retrouver ce résultat ensuite
            if (!_normaliser("${tags["addr:city"]}").contains(zone)) nomZone,
            if (ville == null) "Côte d'Ivoire",
          ].where((e) => e.toString().trim().isNotEmpty).join(", ");
          return Prestataire(
            id:
                -(int.tryParse(valeur["id"].toString()) ??
                    adresse.hashCode.abs()),
            nom: (tags["name"] ?? tags["brand"] ?? categorie.nom).toString(),
            categorie: categorie.nom,
            description: [
              ServiceLangue.texte("ia_description_internet"),
              if (tags["opening_hours"] != null) "⏰ ${tags["opening_hours"]}",
            ].join("\n"),
            telephone: numeros.telephone,
            whatsapp: numeros.whatsapp,
            note: 0,
            prix: "",
            adresse: adresse,
            ouvert: null,
            imageUrl: null,
          );
        }).toList();
        return _trier(liste).take(_maxResultats).toList();
      } catch (_) {
        // Serveur suivant
      }
    }
    return [];
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

  static Future<void> _sauvegarderPrestataires(List<Prestataire> nouveaux) {
    if (nouveaux.isEmpty) return _sauvegardeEnCours;
    return _sauvegardeEnCours = _sauvegardeEnCours.then((_) async {
      final uniques = <int, Prestataire>{};
      for (final prestataire in [
        ...await _chargerPrestataires(),
        ...nouveaux,
      ]) {
        final existant = uniques[prestataire.id];
        // Ne jamais remplacer une fiche qui a un numéro par une fiche sans numéro
        if (existant == null ||
            _aUnContact(prestataire) ||
            !_aUnContact(existant)) {
          uniques[prestataire.id] = prestataire;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _clePrestataires,
        jsonEncode(
          uniques.values.map((prestataire) => prestataire.toJson()).toList(),
        ),
      );
    });
  }

  static Future<List<Prestataire>> _chercherNominatim(
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
        "limit": "15",
        "addressdetails": "1",
        "extratags": "1",
        "accept-language": ServiceLangue.langueNotifier.value,
        if (ville == null) "countrycodes": _paysParDefaut,
      };
      final reponse = await http
          .get(
            Uri.parse(_urlNominatim).replace(queryParameters: parametres),
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
      final liste = donnees
          .map((element) => Map<String, dynamic>.from(element))
          .where(
            (valeur) =>
                !categoriesIgnorees.contains(valeur["category"]) &&
                valeur["extratags"]?["public_transport"] == null,
          )
          .map((valeur) {
            final extras = Map<String, dynamic>.from(valeur["extratags"] ?? {});
            final adresse = valeur["display_name"]?.toString() ?? "";
            final numeros = _numeros(
              extras,
              adresse.contains("Côte d") || ville == null,
            );
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
              telephone: numeros.telephone,
              whatsapp: numeros.whatsapp,
              note: 0,
              prix: "",
              adresse: adresse,
              ouvert: null,
              imageUrl: null,
            );
          })
          .toList();
      return _trier(liste);
    } catch (_) {
      return [];
    }
  }
}
