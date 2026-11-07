// lib/widgets/carte_prestataire.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modeles/prestataire.dart';
import '../services/service_langue.dart';

class CartePrestataire extends StatelessWidget {
  final Prestataire prestataire;

  const CartePrestataire({super.key, required this.prestataire});

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

  void _ouvrirItineraire(BuildContext context) => _ouvrir(
    context,
    Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': "${prestataire.nom}, ${prestataire.adresse}",
    }),
  );

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;
    final aTelephone = prestataire.telephone.trim().isNotEmpty;
    final aWhatsapp = prestataire.whatsapp.trim().isNotEmpty;

    final details = [
      if (prestataire.note > 0) "${prestataire.note}",
      if (prestataire.prix.isNotEmpty) prestataire.prix,
      if (prestataire.categorie.isNotEmpty) prestataire.categorie,
    ].join("  •  ");

    return Container(
      width: 280,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: estSombre ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: estSombre
                ? const Color.fromRGBO(0, 0, 0, 0.4)
                : const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prestataire.imageUrl != null && prestataire.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                prestataire.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prestataire.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: estSombre ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prestataire.adresse,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: estSombre ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (prestataire.note > 0)
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                      Expanded(
                        child: Text(
                          " $details",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: estSombre ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  prestataire.ouvert == null
                      ? ServiceLangue.texte("carte_horaires_inconnus")
                      : ServiceLangue.texte(
                          prestataire.ouvert! ? "carte_ouvert" : "carte_ferme",
                        ),
                  style: TextStyle(
                    color: prestataire.ouvert == null
                        ? (estSombre ? Colors.white38 : Colors.black45)
                        : prestataire.ouvert!
                        ? (estSombre ? Colors.greenAccent[400] : Colors.green)
                        : (estSombre ? Colors.redAccent[100] : Colors.red),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: aTelephone ? () => _appeler(context) : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          side: BorderSide(
                            color: estSombre
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          ServiceLangue.texte("carte_appeler"),
                          style: TextStyle(
                            color: aTelephone
                                ? (estSombre ? Colors.white : Colors.black87)
                                : (estSombre ? Colors.white24 : Colors.black26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: aWhatsapp
                            ? () => _ouvrirWhatsapp(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A859),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: const Text(
                          "WhatsApp",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: ServiceLangue.texte("carte_itineraire"),
                      onPressed: () => _ouvrirItineraire(context),
                      icon: Icon(
                        Icons.directions_outlined,
                        color: estSombre
                            ? Colors.white70
                            : const Color(0xFF00A859),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
