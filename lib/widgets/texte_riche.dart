// lib/widgets/texte_riche.dart
import 'package:flutter/material.dart';

/// Affiche un texte où les passages entre **doubles astérisques** sont en gras
class TexteRiche extends StatelessWidget {
  final String texte;
  final TextStyle? style;
  const TexteRiche(this.texte, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final morceaux = texte.split("**");
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (var i = 0; i < morceaux.length; i++)
            TextSpan(
              text: morceaux[i],
              style: i.isOdd
                  ? const TextStyle(fontWeight: FontWeight.w700)
                  : null,
            ),
        ],
      ),
    );
  }
}
