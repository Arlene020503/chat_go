// lib/widgets/carte_prestataire.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modeles/prestataire.dart';
import '../services/service_langue.dart';
import '../theme/theme_app.dart';

class CartePrestataire extends StatelessWidget {
  final Prestataire prestataire;
  // Version compacte (largeur et hauteur fixes) pour le carrousel du chat
  final bool compacte;

  static const double hauteurCompacte = 292;

  const CartePrestataire({
    super.key,
    required this.prestataire,
    this.compacte = false,
  });

  static const Map<String, IconData> _icones = {
    "Plomberie": Icons.plumbing,
    "Massage": Icons.spa_outlined,
    "Beauté": Icons.face_retouching_natural,
    "Restaurant": Icons.restaurant_outlined,
    "Coiffure": Icons.content_cut,
    "Électricité": Icons.electrical_services,
    "Mécanique": Icons.car_repair,
    "Pharmacie": Icons.local_pharmacy_outlined,
    "Santé": Icons.local_hospital_outlined,
    "Couture": Icons.checkroom,
    "Hôtel": Icons.hotel_outlined,
    "Sport": Icons.fitness_center,
    "Banque": Icons.account_balance_outlined,
    "Boulangerie": Icons.bakery_dining_outlined,
    "Pressing": Icons.local_laundry_service_outlined,
    "Station-service": Icons.local_gas_station_outlined,
    "Chaussures": Icons.shopping_bag_outlined,
    "Vêtements": Icons.checkroom,
    "Téléphones": Icons.smartphone,
    "Électronique": Icons.devices_other,
    "Supermarché": Icons.local_grocery_store_outlined,
    "Meubles": Icons.chair_outlined,
    "Bijoux": Icons.diamond_outlined,
    "Parfums": Icons.water_drop_outlined,
    "Livres": Icons.menu_book_outlined,
    "Quincaillerie": Icons.handyman_outlined,
  };

  String get _categorieAffichee {
    final traduite = ServiceLangue.texte("cat_${prestataire.categorie}");
    return traduite.startsWith("cat_") ? prestataire.categorie : traduite;
  }

  Future<void> _ouvrir(BuildContext context, Uri uri) async {
    final messager = ScaffoldMessenger.of(context);
    var ouvert = false;
    try {
      ouvert = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ouvert = false;
    }
    if (!ouvert) {
      messager.showSnackBar(
        SnackBar(content: Text(ServiceLangue.texte("carte_erreur_lien"))),
      );
    }
  }

  void _appeler(BuildContext context) => _ouvrir(
    context,
    Uri(scheme: 'tel', path: prestataire.telephone.replaceAll(' ', '')),
  );

  void _ouvrirWhatsapp(BuildContext context) =>
      _ouvrir(context, Uri.parse("https://wa.me/${prestataire.whatsapp}"));

  void _ouvrirItineraire(BuildContext context) {
    final aPosition =
        prestataire.latitude != null && prestataire.longitude != null;
    _ouvrir(
      context,
      aPosition
          ? Uri.https('www.google.com', '/maps/dir/', {
              'api': '1',
              'destination': "${prestataire.latitude},${prestataire.longitude}",
            })
          : Uri.https('www.google.com', '/maps/search/', {
              'api': '1',
              'query': "${prestataire.nom}, ${prestataire.adresse}",
            }),
    );
  }

  void _partager() {
    Share.share(
      ServiceLangue.texteAvec("carte_partage_texte", {
        "nom": prestataire.nom,
        "adresse": prestataire.adresse,
        "telephone": prestataire.telephone,
      }).replaceAll("\n\n", "\n"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaire = ThemeApp.texteSecondaire(context);
    final aTelephone = prestataire.telephone.trim().isNotEmpty;
    final aWhatsapp = prestataire.whatsapp.trim().isNotEmpty;
    final aSite = prestataire.siteWeb.trim().isNotEmpty;

    final contenu = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- En-tête : icône de catégorie, nom, catégorie ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ThemeApp.vert.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _icones[prestataire.categorie] ?? Icons.storefront_outlined,
                color: ThemeApp.vert,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prestataire.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _categorieAffichee,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeApp.vert,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (prestataire.note > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(
                          " ${prestataire.note}",
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // --- Informations ---
        _Ligne(
          icone: Icons.place_outlined,
          texte: prestataire.adresse.isNotEmpty
              ? prestataire.adresse
              : ServiceLangue.texte("carte_adresse_inconnue"),
          attenue: prestataire.adresse.isEmpty,
          lignes: 2,
        ),
        _Ligne(
          icone: aWhatsapp ? Icons.chat_outlined : Icons.phone_outlined,
          texte: aTelephone
              ? prestataire.telephone
              : (aWhatsapp
                    ? "+${prestataire.whatsapp}"
                    : ServiceLangue.texte("carte_pas_de_numero")),
          gras: aTelephone || aWhatsapp,
          attenue: !aTelephone && !aWhatsapp,
          selectionnable: aTelephone || aWhatsapp,
        ),
        if (prestataire.horaires.isNotEmpty)
          _Ligne(icone: Icons.schedule, texte: prestataire.horaires),
        if (compacte) const Spacer() else const SizedBox(height: 12),
        // --- Actions principales ---
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: aTelephone ? () => _appeler(context) : null,
                icon: const Icon(Icons.call_outlined, size: 18),
                label: Text(ServiceLangue.texte("carte_appeler")),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 40),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: aWhatsapp ? () => _ouvrirWhatsapp(context) : null,
                icon: const Icon(Icons.chat_bubble_outline, size: 17),
                label: const Text("WhatsApp"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 40),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // --- Actions secondaires ---
        Row(
          children: [
            Flexible(
              child: _ActionDiscrete(
                icone: Icons.directions_outlined,
                libelle: ServiceLangue.texte("carte_itineraire"),
                onTap: () => _ouvrirItineraire(context),
              ),
            ),
            const Spacer(),
            if (aSite)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: ServiceLangue.texte("carte_site"),
                onPressed: () =>
                    _ouvrir(context, Uri.parse(prestataire.siteWeb)),
                icon: const Icon(
                  Icons.language,
                  size: 19,
                  color: ThemeApp.vert,
                ),
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: ServiceLangue.texte("carte_partager"),
              onPressed: _partager,
              icon: Icon(Icons.share_outlined, size: 19, color: secondaire),
            ),
          ],
        ),
      ],
    );

    return SizedBox(
      width: compacte ? 290 : double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 6),
          child: contenu,
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final IconData icone;
  final String texte;
  final int lignes;
  final bool gras;
  final bool attenue;
  final bool selectionnable;

  const _Ligne({
    required this.icone,
    required this.texte,
    this.lignes = 1,
    this.gras = false,
    this.attenue = false,
    this.selectionnable = false,
  });

  @override
  Widget build(BuildContext context) {
    final secondaire = ThemeApp.texteSecondaire(context);
    final style = TextStyle(
      fontSize: 13,
      height: 1.35,
      fontWeight: gras ? FontWeight.w600 : FontWeight.w400,
      color: attenue ? secondaire : null,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icone, size: 16, color: secondaire),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: selectionnable
                ? SelectableText(texte, maxLines: lignes, style: style)
                : Text(
                    texte,
                    maxLines: lignes,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionDiscrete extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  const _ActionDiscrete({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icone, size: 18),
      label: Text(
        libelle,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}
