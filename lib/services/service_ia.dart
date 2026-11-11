import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/prestataire.dart';
import 'service_langue.dart';

class ReponseChat {
  final String message;
  final List<Prestataire> prestataires;
  final List<LienExterne> liens;
  // Réponses rapides proposées sous le message
  final List<String> suggestions;
  ReponseChat({
    required this.message,
    required this.prestataires,
    this.liens = const [],
    this.suggestions = const [],
  });
}

/// Une catégorie de service ou de produit :
/// - [osm] : filtres OpenStreetMap (clé=valeur) utilisés avec Overpass, qui
///   renvoie les vrais établissements avec leurs numéros quand ils existent ;
/// - [requetes] : recherches Nominatim de secours ({v} = ville) ;
/// - [motsCles] : mots reconnus dans le message, toutes langues confondues ;
/// - [boutique] : produit qu'on peut aussi acheter en ligne (liens Jumia, CoinAfrique).
class _Categorie {
  final String nom;
  final List<String> osm;
  final List<String> requetes;
  final List<String> motsCles;
  final bool boutique;
  const _Categorie(
    this.nom,
    this.osm,
    this.requetes,
    this.motsCles, {
    this.boutique = false,
  });
}

class ServiceIA {
  // v3 : les anciennes sauvegardes (adresses complétées à tort) sont ignorées
  static const String _clePrestataires = "prestataires_locaux_v3";
  static const String _urlNominatim =
      "https://nominatim.openstreetmap.org/search";
  static const List<String> _urlsOverpass = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
  ];
  static const Map<String, String> _entetes = {
    "User-Agent": "MesPrestataires/1.0 (recherche de prestataires)",
  };

  // Backend optionnel : `flutter run --dart-define=API_URL=https://mon-serveur.com`.
  // S'il est absent ou injoignable, l'assistant fonctionne entièrement en local.
  static const String _urlBackend = String.fromEnvironment("API_URL");

  // Zone utilisée quand l'utilisateur ne précise pas de ville
  static const String _villeParDefaut = "Abidjan";
  static const String _paysParDefaut = "ci";
  // Abidjan (sud, ouest, nord, est) et cache des autres villes déjà cherchées
  static const String _rectangleParDefaut = "5.16,-4.18,5.48,-3.85";
  static final Map<String, String> _rectangles = {};
  // Temps maximum d'attente d'Overpass avant de répondre avec les résultats rapides
  static const Duration _attenteOverpass = Duration(seconds: 20);
  static const int _parPage = 10;
  static const int _maxResultats = 40;
  // Les sauvegardes s'enchaînent pour ne jamais s'écraser entre elles
  static Future<void> _sauvegardeEnCours = Future.value();

  // Communes d'Abidjan et grandes villes reconnues n'importe où dans la phrase
  static const List<String> _villesConnues = [
    "cocody",
    "yopougon",
    "marcory",
    "plateau",
    "treichville",
    "adjame",
    "abobo",
    "koumassi",
    "port bouet",
    "attecoube",
    "bingerville",
    "anyama",
    "songon",
    "riviera",
    "angre",
    "deux plateaux",
    "zone 4",
    "abidjan",
    "bouake",
    "yamoussoukro",
    "san pedro",
    "daloa",
    "korhogo",
    "gagnoa",
    "grand bassam",
    "assinie",
    "divo",
    "abengourou",
    "odienne",
    "man",
  ];
  static const List<String> _villesSuggerees = [
    "Cocody",
    "Yopougon",
    "Marcory",
    "Plateau",
    "Abobo",
  ];

  // --- Mémoire de la conversation ---
  static _Categorie? _derniereCategorie;
  static String? _derniereVille;
  static List<Prestataire> _derniersResultats = [];
  static int _pageAffichee = 0;

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
        "cosmetiques",
        "cils",
        "epilation",
        "schminken",
        "maquillaje",
        "belleza",
        "化妆",
        "美容",
      ],
      boutique: true,
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
        "garba",
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
      [
        "pharmacie",
        "medicament",
        "medicaments",
        "pharmacy",
        "apotheke",
        "farmacia",
        "药店",
      ],
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
        "pagnes",
        "tissu",
        "tailor",
        "schneider",
        "sastre",
        "costurera",
        "裁缝",
      ],
      boutique: true,
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
    _Categorie(
      "Sport",
      ["leisure=fitness_centre", "leisure=sports_centre"],
      ["salle de sport {v}", "gym in {v}"],
      [
        "sport",
        "musculation",
        "fitness",
        "gym",
        "salle de sport",
        "gimnasio",
        "健身",
      ],
    ),
    _Categorie(
      "Banque",
      ["amenity=bank", "amenity=bureau_de_change"],
      ["banque {v}", "bank in {v}"],
      ["banque", "bancaire", "guichet", "bank", "banco", "银行"],
    ),
    _Categorie(
      "Boulangerie",
      ["shop=bakery", "shop=pastry"],
      ["boulangerie {v}", "bakery in {v}"],
      [
        "boulangerie",
        "boulanger",
        "pain",
        "patisserie",
        "gateau",
        "bakery",
        "backerei",
        "panaderia",
        "面包",
      ],
    ),
    _Categorie(
      "Pressing",
      ["shop=dry_cleaning", "shop=laundry"],
      ["pressing {v}", "laundry in {v}"],
      [
        "pressing",
        "laverie",
        "blanchisserie",
        "repassage",
        "laundry",
        "reinigung",
        "lavanderia",
        "洗衣",
      ],
    ),
    _Categorie(
      "Station-service",
      ["amenity=fuel"],
      ["station service {v}", "fuel in {v}"],
      [
        "essence",
        "carburant",
        "station service",
        "gasoil",
        "fuel",
        "tankstelle",
        "gasolinera",
        "加油",
      ],
    ),
    // --- Boutiques (produits), aussi cherchés sur les sites de vente en ligne ---
    _Categorie(
      "Chaussures",
      ["shop=shoes"],
      ["chaussures {v}", "shoes in {v}"],
      [
        "chaussure",
        "chaussures",
        "basket",
        "baskets",
        "sandale",
        "sandales",
        "escarpin",
        "shoes",
        "sneakers",
        "schuhe",
        "zapatos",
        "鞋",
      ],
      boutique: true,
    ),
    _Categorie(
      "Vêtements",
      ["shop=clothes", "shop=boutique"],
      ["boutique vetements {v}", "clothes in {v}"],
      [
        "vetement",
        "vetements",
        "habit",
        "habits",
        "robe",
        "robes",
        "chemise",
        "pantalon",
        "jean",
        "tenue",
        "clothes",
        "dress",
        "kleidung",
        "ropa",
        "衣服",
      ],
      boutique: true,
    ),
    _Categorie(
      "Téléphones",
      ["shop=mobile_phone"],
      ["telephone portable {v}", "mobile phone shop in {v}"],
      [
        "portable",
        "smartphone",
        "iphone",
        "samsung",
        "tecno",
        "itel",
        "infinix",
        "cellulaire",
        "handy",
        "movil",
        "手机",
      ],
      boutique: true,
    ),
    _Categorie(
      "Électronique",
      ["shop=electronics", "shop=computer", "shop=appliance"],
      ["electronique {v}", "electronics in {v}"],
      [
        "ordinateur",
        "laptop",
        "informatique",
        "electronique",
        "television",
        "tele",
        "frigo",
        "climatiseur",
        "computer",
        "electronics",
        "elektronik",
        "computadora",
        "电脑",
        "电子",
      ],
      boutique: true,
    ),
    _Categorie(
      "Supermarché",
      ["shop=supermarket", "shop=convenience"],
      ["supermarche {v}", "supermarket in {v}"],
      [
        "supermarche",
        "courses",
        "epicerie",
        "alimentation",
        "supermarket",
        "grocery",
        "supermarkt",
        "supermercado",
        "超市",
      ],
    ),
    _Categorie(
      "Meubles",
      ["shop=furniture", "shop=bed"],
      ["meubles {v}", "furniture in {v}"],
      [
        "meuble",
        "meubles",
        "canape",
        "matelas",
        "armoire",
        "furniture",
        "mobel",
        "muebles",
        "家具",
      ],
      boutique: true,
    ),
    _Categorie(
      "Bijoux",
      ["shop=jewelry"],
      ["bijouterie {v}", "jewelry in {v}"],
      [
        "bijou",
        "bijoux",
        "bijouterie",
        "collier",
        "bague",
        "jewelry",
        "schmuck",
        "joyas",
        "珠宝",
      ],
      boutique: true,
    ),
    _Categorie(
      "Parfums",
      ["shop=perfumery"],
      ["parfumerie {v}", "perfumery in {v}"],
      ["parfum", "parfums", "parfumerie", "perfume", "香水"],
      boutique: true,
    ),
    _Categorie(
      "Livres",
      ["shop=books", "shop=stationery"],
      ["librairie {v}", "bookshop in {v}"],
      [
        "livre",
        "livres",
        "librairie",
        "fournitures",
        "cahier",
        "cahiers",
        "books",
        "bucher",
        "libros",
        "书店",
      ],
      boutique: true,
    ),
    _Categorie(
      "Quincaillerie",
      ["shop=hardware", "shop=doityourself"],
      ["quincaillerie {v}", "hardware store in {v}"],
      [
        "quincaillerie",
        "ciment",
        "outil",
        "outils",
        "peinture",
        "hardware",
        "baumarkt",
        "ferreteria",
        "五金",
      ],
      boutique: true,
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
    "c",
    "qu",
    "quoi",
    "qui",
    "ce",
    "que",
    "what",
    "is",
    "who",
    "was",
    "ist",
    "wer",
    "es",
    "sont",
    "sur",
    "parle",
    "dis",
    "explique",
    "connais",
    "tu",
    "vous",
  };

  // Verbes et mots d'achat : déclenchent la recherche de boutiques en ligne
  static const Set<String> _motsAchat = {
    "acheter",
    "achat",
    "achete",
    "commander",
    "commande",
    "boutique",
    "boutiques",
    "magasin",
    "magasins",
    "vente",
    "vendre",
    "prix",
    "livraison",
    "buy",
    "shop",
    "store",
    "order",
    "kaufen",
    "comprar",
    "tienda",
  };

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

  static const Set<String> _motsSalutation = {
    "bonjour",
    "bonsoir",
    "salut",
    "coucou",
    "hello",
    "hi",
    "hey",
    "hola",
    "hallo",
    "yo",
    "slt",
    "bjr",
  };

  /// Remet la conversation à zéro (bouton "Nouvelle conversation")
  static void reinitialiserConversation() {
    _derniereCategorie = null;
    _derniereVille = null;
    _derniersResultats = [];
    _pageAffichee = 0;
  }

  static Future<ReponseChat> envoyerMessage(String message) async {
    final depuisBackend = await _interrogerBackend(message);
    if (depuisBackend != null) return depuisBackend;

    final texte = _normaliser(message);
    final mots = texte.split(' ').where((m) => m.isNotEmpty).toList();
    final motsUtiles = mots.where((m) => !_motsVides.contains(m)).toList();

    var categorie = _trouverCategorie(message);
    final ville = _trouverVille(texte);

    // --- Petite conversation ---
    if (categorie == null) {
      final intention = _petiteConversation(message, texte, mots, motsUtiles);
      if (intention != null) return intention;

      // "Plus de résultats" : page suivante de la dernière recherche
      if (_demandeLaSuite(message, texte) && _derniersResultats.isNotEmpty) {
        return _pageSuivante();
      }
      // "Et à Yopougon ?" : on garde le sujet précédent
      if (ville != null &&
          _derniereCategorie != null &&
          motsUtiles.every((m) => ville.split(' ').contains(m))) {
        categorie = _derniereCategorie;
      }
    }

    if (categorie != null) {
      // Pour un produit, on cherche en ligne exactement ce qui est demandé ("iphone 13")
      final produit = motsUtiles
          .where((m) => !_motsAchat.contains(m))
          .where((m) => !(ville ?? '').split(' ').contains(m))
          .join(' ');
      return _chercherCategorie(
        categorie,
        ville,
        termeEnLigne: produit.isEmpty ? null : produit,
      );
    }

    final motsRecherche = motsUtiles
        .where((m) => !(ville ?? '').split(' ').contains(m))
        .where((m) => !_motsAchat.contains(m))
        .toList();
    final achat = mots.any(_motsAchat.contains);

    // Achat d'un produit inconnu : boutiques en ligne réelles
    if (achat && motsRecherche.isNotEmpty) {
      final terme = motsRecherche.join(' ');
      return ReponseChat(
        message: ServiceLangue.texteAvec("ia_boutiques_en_ligne", {
          "terme": terme,
        }),
        prestataires: [],
        liens: _liensBoutiques(terme),
        suggestions: _suggestionsAccueil(),
      );
    }

    // Question générale : vraie réponse depuis Wikipédia
    if (_estUneQuestion(message, texte) && motsRecherche.isNotEmpty) {
      final article = await _chercherWikipedia(motsRecherche.join(' '));
      if (article != null) return article;
    }

    // Lieu ou service non répertorié : recherche libre sur OpenStreetMap
    if (motsRecherche.isNotEmpty) {
      final libre = await _rechercheLibre(motsRecherche, ville);
      if (libre != null) return libre;
      final article = await _chercherWikipedia(motsRecherche.join(' '));
      if (article != null) return article;
    }

    return ReponseChat(
      message: ServiceLangue.texte("ia_aucun"),
      prestataires: [],
      suggestions: _suggestionsAccueil(),
    );
  }

  // ---------------------------------------------------------------------------
  // Conversation
  // ---------------------------------------------------------------------------

  static ReponseChat? _petiteConversation(
    String message,
    String texte,
    List<String> mots,
    List<String> motsUtiles,
  ) {
    ReponseChat simple(String cle, {List<String>? suggestions}) => ReponseChat(
      message: ServiceLangue.texte(cle),
      prestataires: [],
      suggestions: suggestions ?? _suggestionsAccueil(),
    );

    if (mots.isEmpty || mots.every(_motsSalutation.contains)) {
      return simple(
        texte.contains("bonsoir") ||
                (!texte.contains("bonjour") && DateTime.now().hour >= 18)
            ? "ia_salutation_soir"
            : "ia_salutation",
      );
    }
    const quiEsTu = [
      "qui es tu",
      "tu es qui",
      "t es qui",
      "qui etes vous",
      "que sais tu",
      "tu sais faire quoi",
      "tu fais quoi",
      "comment ca marche",
      "aide moi",
      "who are you",
      "what can you do",
      "how does it work",
      "wer bist du",
      "quien eres",
      "que puedes hacer",
    ];
    if (quiEsTu.any(texte.contains) ||
        texte == "aide" ||
        texte == "help" ||
        message.contains("你是谁")) {
      return simple("ia_presentation");
    }
    const caVa = [
      "ca va",
      "comment vas tu",
      "comment allez vous",
      "how are you",
      "wie geht",
      "como estas",
    ];
    if (caVa.any(texte.contains) && motsUtiles.length <= 3) {
      return simple("ia_ca_va");
    }
    if ((motsUtiles.isNotEmpty && motsUtiles.every(_motsPolitesse.contains)) ||
        message.contains("谢谢")) {
      return simple("ia_merci", suggestions: const []);
    }
    return null;
  }

  static bool _demandeLaSuite(String message, String texte) {
    const suite = [
      "plus de resultats",
      "plus",
      "encore",
      "d autres",
      "autres",
      "suivant",
      "la suite",
      "voir plus",
      "more",
      "more results",
      "next",
      "mehr",
      "weitere",
      "mas",
      "mas resultados",
    ];
    return suite.contains(texte) ||
        texte.startsWith("plus de") ||
        texte.startsWith("d autres") ||
        message.contains("更多");
  }

  static bool _estUneQuestion(String message, String texte) {
    const debuts = [
      "c est quoi",
      "qu est ce",
      "qui est",
      "qui etait",
      "pourquoi",
      "comment",
      "quand",
      "combien",
      "quel est",
      "quelle est",
      "definition",
      "parle moi",
      "dis moi",
      "explique",
      "what",
      "who",
      "why",
      "how",
      "when",
      "tell me",
      "was ist",
      "wer ist",
      "warum",
      "wie",
      "que es",
      "quien",
      "por que",
      "como",
    ];
    return message.trim().endsWith("?") ||
        message.contains("什么") ||
        message.contains("谁") ||
        debuts.any((d) => texte.startsWith(d));
  }

  static List<String> _suggestionsAccueil() => [
    ServiceLangue.texte("suggestion_pharmacie"),
    ServiceLangue.texte("suggestion_restaurant"),
    ServiceLangue.texte("suggestion_chaussures"),
  ];

  static String _nomCategorie(_Categorie categorie) =>
      ServiceLangue.texte("cat_${categorie.nom}");

  // ---------------------------------------------------------------------------
  // Recherche par catégorie
  // ---------------------------------------------------------------------------

  static Future<ReponseChat> _chercherCategorie(
    _Categorie categorie,
    String? ville, {
    String? termeEnLigne,
  }) async {
    final zone = ville ?? _normaliser(_villeParDefaut);
    _derniereCategorie = categorie;
    _derniereVille = ville;

    // 1. Ce qui a déjà été trouvé et sauvegardé sur le téléphone
    final stockes = (await _chargerPrestataires())
        .where(
          (p) =>
              _normaliser(p.categorie) == _normaliser(categorie.nom) &&
              _dansVille(p, zone),
        )
        .toList();
    if (stockes.any(_aUnContact)) {
      return _repondreAvecResultats(
        categorie,
        ville,
        _sansAnonymes(_trier(stockes), categorie),
        true,
        termeEnLigne: termeEnLigne,
      );
    }

    // 2. Sinon, vraie recherche sur Internet (OpenStreetMap), puis sauvegarde.
    // Overpass (établissements avec numéros) et Nominatim (rapide) partent en
    // parallèle. Si Overpass est trop lent, il continue en arrière-plan et ses
    // résultats seront prêts pour la prochaine recherche.
    final chrono = Stopwatch()..start();
    var overpassTermine = false;
    final overpass = _chercherOverpass(categorie, ville).then((liste) async {
      overpassTermine = true;
      await _sauvegarderPrestataires(liste);
      return liste;
    });

    var rapides = <Prestataire>[];
    for (final requete in categorie.requetes) {
      rapides = await _chercherNominatim(
        requete.replaceAll("{v}", ville ?? _villeParDefaut),
        categorie.nom,
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
    final trouvaille = _sansAnonymes(
      _trier(
        {
          for (final p in [...stockes, ...rapides, ...avecNumeros]) p.id: p,
        }.values.toList(),
      ),
      categorie,
    ).take(_maxResultats).toList();

    await _sauvegarderPrestataires(trouvaille);
    if (trouvaille.isEmpty && !categorie.boutique) {
      return ReponseChat(
        message: ServiceLangue.texteAvec("ia_rien_categorie", {
          "cat": _nomCategorie(categorie),
          "ville": _majuscule(zone),
        }),
        prestataires: [],
        suggestions: _suggestionsVilles(ville),
      );
    }
    return _repondreAvecResultats(
      categorie,
      ville,
      trouvaille,
      false,
      numerosEnCours: !overpassTermine && !trouvaille.any(_aUnContact),
      termeEnLigne: termeEnLigne,
    );
  }

  static ReponseChat _repondreAvecResultats(
    _Categorie categorie,
    String? ville,
    List<Prestataire> resultats,
    bool depuisSauvegarde, {
    bool numerosEnCours = false,
    String? termeEnLigne,
  }) {
    final terme = termeEnLigne ?? _nomCategorie(categorie);
    _derniersResultats = resultats;
    _pageAffichee = 1;
    final joignables = resultats.where(_aUnContact).length;
    final valeurs = {
      "n": resultats.length,
      "tel": joignables,
      "cat": _nomCategorie(categorie),
      "ville": _majuscule(ville ?? _villeParDefaut),
    };

    final phrases = <String>[];
    if (resultats.isEmpty) {
      phrases.add(
        ServiceLangue.texteAvec("ia_boutiques_en_ligne", {"terme": terme}),
      );
    } else {
      phrases.add(ServiceLangue.texteAvec("ia_trouve", valeurs));
      phrases.add(
        joignables > 0
            ? ServiceLangue.texteAvec("ia_joignables", valeurs)
            : ServiceLangue.texte(
                numerosEnCours ? "ia_numeros_en_cours" : "ia_sans_numero",
              ),
      );
      if (!depuisSauvegarde && !numerosEnCours) {
        phrases.add(ServiceLangue.texte("ia_sauvegarde"));
      }
      if (categorie.boutique) {
        phrases.add(ServiceLangue.texte("ia_aussi_en_ligne"));
      }
    }

    return ReponseChat(
      message: phrases.join("\n\n"),
      prestataires: resultats.take(_parPage).toList(),
      liens: categorie.boutique ? _liensBoutiques(terme) : const [],
      suggestions: [
        if (resultats.length > _parPage) ServiceLangue.texte("suggestion_plus"),
        ..._suggestionsVilles(ville),
      ],
    );
  }

  static List<String> _suggestionsVilles(String? ville) => _villesSuggerees
      .where((v) => _normaliser(v) != ville)
      .take(3)
      .map((v) => ServiceLangue.texteAvec("suggestion_ville", {"ville": v}))
      .toList();

  static ReponseChat _pageSuivante() {
    final debut = _pageAffichee * _parPage;
    if (debut >= _derniersResultats.length) {
      return ReponseChat(
        message: ServiceLangue.texte("ia_fin_resultats"),
        prestataires: [],
        suggestions: _suggestionsVilles(_derniereVille),
      );
    }
    _pageAffichee++;
    final page = _derniersResultats.skip(debut).take(_parPage).toList();
    final reste = _derniersResultats.length - debut - page.length;
    return ReponseChat(
      message: ServiceLangue.texteAvec("ia_page_suivante", {"n": page.length}),
      prestataires: page,
      suggestions: [
        if (reste > 0) ServiceLangue.texte("suggestion_plus"),
        ..._suggestionsVilles(_derniereVille),
      ],
    );
  }

  /// Liens de recherche sur de vraies boutiques en ligne de Côte d'Ivoire
  static List<LienExterne> _liensBoutiques(String terme) {
    final q = Uri.encodeQueryComponent(terme);
    return [
      LienExterne(
        titre: "Jumia Côte d'Ivoire",
        sousTitre: ServiceLangue.texteAvec("lien_jumia", {"terme": terme}),
        url: "https://www.jumia.ci/catalog/?q=$q",
      ),
      LienExterne(
        titre: "CoinAfrique",
        sousTitre: ServiceLangue.texteAvec("lien_coinafrique", {
          "terme": terme,
        }),
        url: "https://ci.coinafrique.com/search?keyword=$q",
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Recherche libre et Wikipédia
  // ---------------------------------------------------------------------------

  static Future<ReponseChat?> _rechercheLibre(
    List<String> motsRecherche,
    String? ville,
  ) async {
    final zone = ville ?? _normaliser(_villeParDefaut);
    final stockes = (await _chargerPrestataires())
        .where((p) => _correspond(p, motsRecherche) && _dansVille(p, zone))
        .toList();
    var trouvaille = stockes;
    if (trouvaille.isEmpty) {
      final requetes = [
        "${motsRecherche.join(' ')} {v}",
        // Mot par mot si la phrase entière ne donne rien
        for (final mot in motsRecherche.where((m) => m.length > 3).take(2))
          if (motsRecherche.length > 1) "$mot {v}",
      ];
      for (final requete in requetes) {
        trouvaille = await _chercherNominatim(
          requete.replaceAll("{v}", ville ?? _villeParDefaut),
          null,
          ville,
        );
        if (trouvaille.isNotEmpty) break;
        await Future.delayed(const Duration(seconds: 1));
      }
      await _sauvegarderPrestataires(trouvaille);
    }
    if (trouvaille.isEmpty) return null;

    _derniereCategorie = null;
    _derniereVille = ville;
    _derniersResultats = _trier(trouvaille);
    _pageAffichee = 1;
    final joignables = trouvaille.where(_aUnContact).length;
    final valeurs = {
      "n": trouvaille.length,
      "tel": joignables,
      "cat": motsRecherche.join(' '),
      "ville": _majuscule(zone),
    };
    return ReponseChat(
      message: [
        ServiceLangue.texteAvec("ia_trouve", valeurs),
        joignables > 0
            ? ServiceLangue.texteAvec("ia_joignables", valeurs)
            : ServiceLangue.texte("ia_sans_numero"),
      ].join("\n\n"),
      prestataires: _derniersResultats.take(_parPage).toList(),
      suggestions: [
        if (trouvaille.length > _parPage)
          ServiceLangue.texte("suggestion_plus"),
      ],
    );
  }

  static Future<ReponseChat?> _chercherWikipedia(String sujet) async {
    final langue = ServiceLangue.langueNotifier.value;
    try {
      final recherche = await http
          .get(
            Uri.https("$langue.wikipedia.org", "/w/api.php", {
              "action": "query",
              "list": "search",
              "srsearch": sujet,
              "format": "json",
              "origin": "*",
              "srlimit": "1",
            }),
            headers: _entetes,
          )
          .timeout(const Duration(seconds: 10));
      final resultats =
          jsonDecode(utf8.decode(recherche.bodyBytes))["query"]?["search"]
              as List?;
      if (resultats == null || resultats.isEmpty) return null;
      final titre = resultats.first["title"].toString();
      // L'article doit vraiment parler du sujet demandé, sinon on ne répond pas
      final motsTitre = _normaliser(titre).split(' ');
      final pertinent = _normaliser(sujet)
          .split(' ')
          .where((m) => m.length > 3)
          .any(
            (m) => motsTitre.any(
              (t) =>
                  t == m ||
                  (t.length > 4 &&
                      m.length > 4 &&
                      t.substring(0, 5) == m.substring(0, 5)),
            ),
          );
      if (!pertinent) return null;

      final resume = await http
          .get(
            Uri.https(
              "$langue.wikipedia.org",
              // Uri.https encode lui-même le chemin
              "/api/rest_v1/page/summary/${titre.replaceAll(' ', '_')}",
            ),
            headers: _entetes,
          )
          .timeout(const Duration(seconds: 10));
      if (resume.statusCode != 200) return null;
      final donnees = jsonDecode(utf8.decode(resume.bodyBytes));
      var extrait = donnees["extract"]?.toString().trim() ?? "";
      if (extrait.isEmpty) return null;
      if (extrait.length > 700) {
        final coupe = extrait.substring(0, 700);
        extrait = "${coupe.substring(0, coupe.lastIndexOf(' '))}…";
      }
      final url =
          donnees["content_urls"]?["mobile"]?["page"]?.toString() ??
          "https://$langue.wikipedia.org/wiki/${Uri.encodeComponent(titre)}";
      return ReponseChat(
        message: "**$titre**\n\n$extrait",
        prestataires: [],
        liens: [
          LienExterne(
            titre: "Wikipédia",
            sousTitre: ServiceLangue.texteAvec("lien_article", {
              "titre": titre,
            }),
            url: url,
            type: "article",
          ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Outils de compréhension
  // ---------------------------------------------------------------------------

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

  /// Repère une ville connue n'importe où dans la phrase, ou écrite après
  /// "à", "in", "en", "sur" ou "vers" (ex: "plombier à Bonoua")
  static String? _trouverVille(String texte) {
    final entoure = " $texte ";
    for (final ville in _villesConnues) {
      if (entoure.contains(" $ville ")) return ville;
    }
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
              // Faute de frappe tolérée, mais pas un autre mot ("electrique" ≠ "electronique")
              (motTexte.length > 3 &&
                  (motTexte.length - mot.length).abs() <= 1 &&
                  _distance(motTexte, mot) <= tolerance),
        );
  }

  static bool _correspond(Prestataire prestataire, List<String> mots) {
    final contenu = _normaliser(
      "${prestataire.nom} ${prestataire.categorie} ${prestataire.description}",
    );
    return mots.any((mot) => mot.length > 2 && contenu.contains(mot));
  }

  static bool _dansVille(Prestataire prestataire, String ville) =>
      prestataire.zone == ville ||
      _normaliser(prestataire.adresse).contains(ville);

  static bool _aUnContact(Prestataire prestataire) => prestataire.aUnContact;

  /// Retire les lieux sans vrai nom ("Restaurant", "Pharmacie"…) ni contact,
  /// inutiles pour l'utilisateur, dès qu'il reste assez de vrais résultats
  static List<Prestataire> _sansAnonymes(
    List<Prestataire> liste,
    _Categorie categorie,
  ) {
    final generiques = {
      _normaliser(categorie.nom),
      _normaliser(_nomCategorie(categorie)),
      ...categorie.motsCles.map(_normaliser),
    };
    bool utile(Prestataire p) =>
        p.aUnContact ||
        p.siteWeb.isNotEmpty ||
        !generiques.contains(_normaliser(p.nom));
    final utiles = liste.where(utile).toList();
    return utiles.length >= 3 ? utiles : liste;
  }

  /// Les prestataires joignables d'abord, puis ceux qui ont un site ou un vrai nom
  static List<Prestataire> _trier(List<Prestataire> liste) {
    int score(Prestataire p) =>
        (p.whatsapp.isNotEmpty ? 8 : 0) +
        (p.telephone.isNotEmpty ? 4 : 0) +
        (p.siteWeb.isNotEmpty ? 2 : 0) +
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

  /// Site web ou page de réseau social publiés pour l'établissement
  static String _siteWeb(Map<String, dynamic> tags) {
    for (final cle in [
      "website",
      "contact:website",
      "url",
      "contact:facebook",
      "facebook",
      "contact:instagram",
    ]) {
      final valeur = tags[cle]?.toString().split(";").first.trim() ?? "";
      if (valeur.isEmpty) continue;
      if (valeur.startsWith("http")) return valeur;
      if (cle.contains("facebook")) return "https://www.facebook.com/$valeur";
      if (cle.contains("instagram")) return "https://www.instagram.com/$valeur";
      return "https://$valeur";
    }
    return "";
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
              queryParameters: {
                "q": _villesConnues.contains(ville)
                    ? "$ville, Côte d'Ivoire"
                    : ville,
                "format": "jsonv2",
                "limit": "1",
              },
            ),
            headers: _entetes,
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
            .post(Uri.parse(url), headers: _entetes, body: {"data": requete})
            .timeout(const Duration(seconds: 70));
        if (reponse.statusCode != 200) continue;
        final elements =
            (jsonDecode(utf8.decode(reponse.bodyBytes))["elements"] as List?) ??
            [];
        final liste = elements.map((element) {
          final valeur = Map<String, dynamic>.from(element);
          final tags = Map<String, dynamic>.from(valeur["tags"] ?? {});
          final numeros = _numeros(tags, ville == null);
          final centre = valeur["center"] ?? valeur;
          final adresse = [
            [
              tags["addr:housenumber"],
              tags["addr:street"],
            ].where((e) => e != null).join(" "),
            tags["addr:suburb"] ?? tags["addr:district"] ?? "",
            tags["addr:city"] ?? "",
          ].where((e) => e.toString().trim().isNotEmpty).join(", ");
          return Prestataire(
            id:
                -(int.tryParse(valeur["id"].toString()) ??
                    adresse.hashCode.abs()),
            nom: (tags["name"] ?? tags["brand"] ?? categorie.nom).toString(),
            categorie: categorie.nom,
            description: (tags["description"] ?? "").toString(),
            telephone: numeros.telephone,
            whatsapp: numeros.whatsapp,
            note: 0,
            prix: "",
            adresse: adresse,
            ouvert: null,
            imageUrl: null,
            siteWeb: _siteWeb(tags),
            horaires: (tags["opening_hours"] ?? "").toString(),
            latitude: double.tryParse("${centre["lat"]}"),
            longitude: double.tryParse("${centre["lon"]}"),
            // Trouvé dans le rectangle géographique de la zone : c'est vérifié
            zone: zone,
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
        if (ville == null || _villesConnues.contains(ville))
          "countrycodes": _paysParDefaut,
      };
      final reponse = await http
          .get(
            Uri.parse(_urlNominatim).replace(queryParameters: parametres),
            headers: _entetes,
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
      final zone = ville ?? _normaliser(_villeParDefaut);
      final liste = donnees
          .map((element) => Map<String, dynamic>.from(element))
          .where(
            (valeur) =>
                !categoriesIgnorees.contains(valeur["category"]) &&
                valeur["extratags"]?["public_transport"] == null &&
                // Seulement les lieux réellement situés dans la zone demandée
                _normaliser("${valeur["display_name"]}").contains(zone),
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
              description: "",
              telephone: numeros.telephone,
              whatsapp: numeros.whatsapp,
              note: 0,
              prix: "",
              adresse: adresse,
              ouvert: null,
              imageUrl: null,
              siteWeb: _siteWeb(extras),
              horaires: (extras["opening_hours"] ?? "").toString(),
              latitude: double.tryParse("${valeur["lat"]}"),
              longitude: double.tryParse("${valeur["lon"]}"),
              zone: zone,
            );
          })
          .toList();
      return _trier(liste);
    } catch (_) {
      return [];
    }
  }
}
