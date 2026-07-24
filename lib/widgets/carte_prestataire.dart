// lib/widgets/carte_prestataire.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modeles/prestataire.dart';

class CartePrestataire extends StatelessWidget {
  final Prestataire prestataire;

  const CartePrestataire({super.key, required this.prestataire});

  Future<void> _appeler() async {
    final uri = Uri(scheme: 'tel', path: prestataire.telephone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _ouvrirWhatsapp() async {
    final uri = Uri.parse("https://wa.me/${prestataire.whatsapp}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

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
        children: [
          if (prestataire.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                prestataire.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prestataire.nom,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: estSombre ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prestataire.adresse,
                  style: TextStyle(
                    color: estSombre ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(
                      " ${prestataire.note}  •  ${prestataire.prix}",
                      style: TextStyle(
                        fontSize: 13,
                        color: estSombre ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  prestataire.ouvert ? "Ouvert maintenant" : "Fermé",
                  style: TextStyle(
                    color: prestataire.ouvert
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
                        onPressed: _appeler,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: estSombre ? Colors.grey[600]! : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          "Appeler",
                          style: TextStyle(color: estSombre ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _ouvrirWhatsapp,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A859)),
                        child: const Text("WhatsApp", style: TextStyle(color: Colors.white)),
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