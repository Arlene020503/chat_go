import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContenuPageIntro extends StatelessWidget {
  final Color couleur;
  final String titre;
  final String description;
  final String? cheminImage;

  const ContenuPageIntro({
    super.key,
    required this.couleur,
    required this.titre,
    required this.description,
    this.cheminImage,
  });

  @override
  Widget build(BuildContext context) {
    // L'image s'adapte à la hauteur de l'écran (petits téléphones compris)
    final hauteurImage = MediaQuery.of(context).size.height * 0.34;
    return Container(
      color: couleur,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cheminImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  cheminImage!,
                  height: hauteurImage,
                  fit: BoxFit.contain,
                ),
              )
            else
              const Icon(Icons.rocket_launch, size: 100, color: Colors.green),
            const SizedBox(height: 36),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 26,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 15.5,
                color: Colors.black54,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
