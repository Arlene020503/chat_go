import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ecran_aide.dart';
import 'ecran_historique.dart';
import '../services/service_langue.dart';
import '../services/service_theme.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar_marque.dart';

class EcranParametres extends StatelessWidget {
  const EcranParametres({super.key});

  @override
  Widget build(BuildContext context) {
    // Cet écran entier se reconstruit dès que la langue change
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        final secondaire = ThemeApp.texteSecondaire(context);
        return Scaffold(
          appBar: AppBar(title: Text(ServiceLangue.texte("parametres_titre"))),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // --- En-tête avec le logo de l'application ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const AvatarMarque(taille: 64),
                      const SizedBox(height: 12),
                      Text(
                        ServiceLangue.texte("app_nom"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ServiceLangue.texte("parametres_sous_titre"),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: secondaire),
                      ),
                    ],
                  ),
                ),
              ),

              _Section(
                titre: ServiceLangue.texte("parametres_section_preferences"),
                options: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ServiceTheme.themeNotifier,
                    builder: (context, modeActuel, _) => _Option(
                      icone: Icons.dark_mode_outlined,
                      titre: ServiceLangue.texte("parametres_apparence"),
                      valeur: ServiceTheme.texteAffichage(modeActuel),
                      onTap: () => _afficherChoixApparence(context, modeActuel),
                    ),
                  ),
                  _Option(
                    icone: Icons.translate,
                    titre: ServiceLangue.texte("parametres_langue"),
                    valeur:
                        "${ServiceLangue.drapeau(langueActuelle)}  ${ServiceLangue.nomAffichage(langueActuelle)}",
                    onTap: () => _afficherChoixLangue(context, langueActuelle),
                  ),
                ],
              ),

              _Section(
                titre: ServiceLangue.texte("parametres_section_activite"),
                options: [
                  _Option(
                    icone: Icons.history,
                    titre: ServiceLangue.texte("parametres_historique"),
                    onTap: () async {
                      final recherche = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EcranHistorique(),
                        ),
                      );
                      // Recherche choisie dans l'historique : on la renvoie au chat
                      if (recherche != null && context.mounted) {
                        Navigator.pop(context, recherche);
                      }
                    },
                  ),
                ],
              ),

              _Section(
                titre: ServiceLangue.texte("parametres_section_apropos"),
                options: [
                  _Option(
                    icone: Icons.ios_share,
                    titre: ServiceLangue.texte("parametres_partager"),
                    onTap: () => Share.share(
                      ServiceLangue.texte("parametres_partage_texte"),
                    ),
                  ),
                  _Option(
                    icone: Icons.star_border,
                    titre: ServiceLangue.texte("parametres_noter"),
                    onTap: () async {
                      final url = Uri.parse(
                        "https://play.google.com/store/apps/details?id=com.tonpackage.chatgoapp",
                      );
                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {}
                    },
                  ),
                  _Option(
                    icone: Icons.help_outline,
                    titre: ServiceLangue.texte("parametres_aide"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EcranAide(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  ServiceLangue.texte("parametres_version"),
                  style: TextStyle(fontSize: 12, color: secondaire),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Choix de l'apparence ---

  void _afficherChoixApparence(BuildContext context, ThemeMode modeActuel) {
    final modes = {
      ThemeMode.light: (Icons.light_mode_outlined, "apparence_clair"),
      ThemeMode.dark: (Icons.dark_mode_outlined, "apparence_sombre"),
      ThemeMode.system: (Icons.settings_suggest_outlined, "apparence_systeme"),
    };
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entree in modes.entries)
              _Choix(
                icone: Icon(entree.value.$1),
                libelle: ServiceLangue.texte(entree.value.$2),
                selectionne: entree.key == modeActuel,
                onTap: () {
                  ServiceTheme.changerTheme(entree.key);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- Choix de la langue ---

  void _afficherChoixLangue(BuildContext context, String langueActuelle) {
    final codes = [
      ServiceLangue.fr,
      ServiceLangue.en,
      ServiceLangue.de,
      ServiceLangue.es,
      ServiceLangue.zh,
    ];
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final code in codes)
              _Choix(
                icone: Text(
                  ServiceLangue.drapeau(code),
                  style: const TextStyle(fontSize: 22),
                ),
                libelle: ServiceLangue.nomAffichage(code),
                selectionne: code == langueActuelle,
                onTap: () {
                  ServiceLangue.changerLangue(code);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final List<Widget> options;
  const _Section({required this.titre, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
          child: Text(
            titre.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: ThemeApp.texteSecondaire(context),
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const Divider(indent: 56),
                options[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? valeur;
  final VoidCallback onTap;

  const _Option({
    required this.icone,
    required this.titre,
    required this.onTap,
    this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    final secondaire = ThemeApp.texteSecondaire(context);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: ThemeApp.vert.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icone, size: 19, color: ThemeApp.vert),
      ),
      title: Text(
        titre,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valeur != null)
            Text(valeur!, style: TextStyle(fontSize: 14, color: secondaire)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: secondaire),
        ],
      ),
    );
  }
}

class _Choix extends StatelessWidget {
  final Widget icone;
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  const _Choix({
    required this.icone,
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icone,
      title: Text(
        libelle,
        style: TextStyle(
          fontWeight: selectionne ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      trailing: selectionne
          ? const Icon(Icons.check_circle, color: ThemeApp.vert)
          : null,
      onTap: onTap,
    );
  }
}
