// lib/widgets/avatar_marque.dart
import 'package:flutter/material.dart';
import '../theme/theme_app.dart';

/// Symbole de « Mes Prestataires » dans un rond vert (avatar de l'assistant)
class AvatarMarque extends StatelessWidget {
  final double taille;
  const AvatarMarque({super.key, required this.taille});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      padding: EdgeInsets.all(taille * 0.2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [ThemeApp.vertVif, ThemeApp.vert],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Image.asset('assets/logo_symbole_blanc.png'),
    );
  }
}
