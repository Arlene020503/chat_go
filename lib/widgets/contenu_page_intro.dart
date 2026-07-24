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
    return Container(
      color: couleur,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cheminImage != null)
            Image.asset(cheminImage!, height: 220, fit: BoxFit.contain)
          else
            const Icon(Icons.rocket_launch, size: 100, color: Colors.green),
          const SizedBox(height: 40),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}