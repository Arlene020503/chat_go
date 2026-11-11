// lib/modeles/prestataire.dart
class Prestataire {
  final int id;
  final String nom;
  final String categorie;
  final String description;
  final String telephone;
  final String whatsapp;
  final double note;
  final String prix;
  final String adresse;
  // null = horaires inconnus (ex: résultat trouvé sur Internet)
  final bool? ouvert;
  final String? imageUrl;
  final String siteWeb;
  final String horaires;
  final double? latitude;
  final double? longitude;
  // Zone de recherche (ville/quartier) où ce résultat a été trouvé : sert
  // uniquement à le retrouver ensuite, jamais affiché comme adresse
  final String zone;

  Prestataire({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.telephone,
    required this.whatsapp,
    required this.note,
    required this.prix,
    required this.adresse,
    required this.ouvert,
    this.imageUrl,
    this.siteWeb = '',
    this.horaires = '',
    this.latitude,
    this.longitude,
    this.zone = '',
  });

  factory Prestataire.fromJson(Map<String, dynamic> json) {
    final ouvert = json['ouvert']?.toString().toLowerCase();
    return Prestataire(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nom: json['nom']?.toString() ?? '',
      categorie: json['categorie']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      note: double.tryParse(json['note'].toString()) ?? 0.0,
      prix: json['prix']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      ouvert: ouvert == '1' || ouvert == 'true'
          ? true
          : (ouvert == '0' || ouvert == 'false' ? false : null),
      imageUrl: json['image_url']?.toString(),
      siteWeb: json['site_web']?.toString() ?? '',
      horaires: json['horaires']?.toString() ?? '',
      latitude: double.tryParse('${json['latitude']}'),
      longitude: double.tryParse('${json['longitude']}'),
      zone: json['zone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'categorie': categorie,
    'description': description,
    'telephone': telephone,
    'whatsapp': whatsapp,
    'note': note,
    'prix': prix,
    'adresse': adresse,
    'ouvert': ouvert == null ? null : (ouvert! ? 1 : 0),
    'image_url': imageUrl,
    'site_web': siteWeb,
    'horaires': horaires,
    'latitude': latitude,
    'longitude': longitude,
    'zone': zone,
  };

  bool get aUnContact => telephone.isNotEmpty || whatsapp.isNotEmpty;
}

/// Lien vers une source externe réelle (boutique en ligne, article…)
class LienExterne {
  final String titre;
  final String sousTitre;
  final String url;
  final String type; // "boutique", "article", "carte"

  const LienExterne({
    required this.titre,
    required this.sousTitre,
    required this.url,
    this.type = "boutique",
  });
}
