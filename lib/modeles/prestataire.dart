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
  final bool ouvert;
  final String? imageUrl;

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
  });

  factory Prestataire.fromJson(Map<String, dynamic> json) {
    return Prestataire(
      id: int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      categorie: json['categorie'] ?? '',
      description: json['description'] ?? '',
      telephone: json['telephone'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      note: double.tryParse(json['note'].toString()) ?? 0.0,
      prix: json['prix'] ?? '',
      adresse: json['adresse'] ?? '',
      ouvert: json['ouvert'].toString() == '1',
      imageUrl: json['image_url'],
    );
  }
}