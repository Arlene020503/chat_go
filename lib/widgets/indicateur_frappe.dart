// lib/widgets/indicateur_frappe.dart
import 'package:flutter/material.dart';
import '../theme/theme_app.dart';

/// Trois points animés affichés pendant que l'assistant cherche
class IndicateurFrappe extends StatefulWidget {
  const IndicateurFrappe({super.key});

  @override
  State<IndicateurFrappe> createState() => _IndicateurFrappeState();
}

class _IndicateurFrappeState extends State<IndicateurFrappe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: ThemeApp.surfaceDouce(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controleur,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Chaque point s'allume avec un léger décalage
            final phase = ((_controleur.value * 3) - i).clamp(0.0, 1.0);
            final intensite = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeApp.vert.withValues(alpha: 0.3 + 0.7 * intensite),
              ),
            );
          }),
        ),
      ),
    );
  }
}
