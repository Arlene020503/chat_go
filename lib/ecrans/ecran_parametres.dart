import 'ecran_aide.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ecran_historique.dart';
import '../services/service_theme.dart';
import '../services/service_langue.dart';

class EcranParametres extends StatelessWidget {
  const EcranParametres({super.key});

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    // Cet écran entier se reconstruit dès que la langue change
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: estSombre ? Colors.white : Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              ServiceLangue.texte("parametres_titre"),
              style: GoogleFonts.roboto(
                color: estSombre ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          body: ListView(
            children: [
              _buildOption(
                context: context,
                icon: Icons.person_outline,
                titre: ServiceLangue.texte("parametres_historique"),
                trailing: Icon(
                  Icons.chevron_right,
                  color: estSombre ? Colors.white38 : Colors.black38,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EcranHistorique()),
                  );
                },
              ),

              // --- BLOC APPARENCE ---
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ServiceTheme.themeNotifier,
                builder: (context, modeActuel, _) {
                  return _buildOption(
                    context: context,
                    icon: Icons.wb_sunny_outlined,
                    titre: ServiceLangue.texte("parametres_apparence"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ServiceTheme.texteAffichage(modeActuel),
                          style: GoogleFonts.roboto(
                            color: estSombre ? Colors.white54 : Colors.black45,
                            fontSize: 15,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: estSombre ? Colors.white54 : Colors.black45,
                        ),
                      ],
                    ),
                    onTap: () => _afficherChoixApparence(context, modeActuel),
                  );
                },
              ),

              // --- BLOC LANGUE, MAINTENANT DYNAMIQUE ---
              _buildOption(
                context: context,
                icon: Icons.translate,
                titre: ServiceLangue.texte("parametres_langue"),
                trailing: Text(
                  ServiceLangue.drapeau(langueActuelle),
                  style: const TextStyle(fontSize: 20),
                ),
                onTap: () => _afficherChoixLangue(context, langueActuelle),
              ),
              // --- FIN BLOC LANGUE ---

              _buildOption(
                context: context,
                icon: Icons.ios_share,
                titre: ServiceLangue.texte("parametres_partager"),
                onTap: () {
                  Share.share(
                    "Découvre Chat&Go, l'assistant IA qui te trouve le bon prestataire en Côte d'Ivoire ! 📲",
                  );
                },
              ),
              _buildOption(
                context: context,
                icon: Icons.star_border,
                titre: ServiceLangue.texte("parametres_noter"),
                onTap: () async {
                  final Uri url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.tonpackage.chatgoapp",
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _buildOption(
                context: context,
                icon: Icons.help_outline,
                titre: ServiceLangue.texte("parametres_aide"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EcranAide()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String titre,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: estSombre ? Colors.white70 : Colors.black87, size: 22),
      title: Text(
        titre,
        style: GoogleFonts.roboto(
          fontSize: 15,
          color: estSombre ? Colors.white70 : Colors.black87,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  // --- MÉTHODES POUR LE CHOIX D'APPARENCE ---

  void _afficherChoixApparence(BuildContext context, ThemeMode modeActuel) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: estSombre ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _optionApparence(context, ServiceLangue.texte("apparence_clair"), ThemeMode.light, modeActuel),
              _optionApparence(context, ServiceLangue.texte("apparence_sombre"), ThemeMode.dark, modeActuel),
              _optionApparence(context, ServiceLangue.texte("apparence_systeme"), ThemeMode.system, modeActuel),
            ],
          ),
        );
      },
    );
  }

  Widget _optionApparence(
    BuildContext context,
    String label,
    ThemeMode mode,
    ThemeMode modeActuel,
  ) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: estSombre ? Colors.white : Colors.black87),
      ),
      trailing: mode == modeActuel ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        ServiceTheme.changerTheme(mode);
        Navigator.pop(context);
      },
    );
  }

  // --- NOUVELLES MÉTHODES POUR LE CHOIX DE LANGUE ---

  void _afficherChoixLangue(BuildContext context, String langueActuelle) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    final codesDisponibles = [
      ServiceLangue.fr,
      ServiceLangue.en,
      ServiceLangue.de,
      ServiceLangue.es,
      ServiceLangue.zh,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: estSombre ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: codesDisponibles
                .map((code) => _optionLangue(context, code, langueActuelle))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _optionLangue(BuildContext context, String code, String langueActuelle) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Text(ServiceLangue.drapeau(code), style: const TextStyle(fontSize: 22)),
      title: Text(
        ServiceLangue.nomAffichage(code),
        style: TextStyle(color: estSombre ? Colors.white : Colors.black87),
      ),
      trailing: code == langueActuelle ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        ServiceLangue.changerLangue(code);
        Navigator.pop(context);
      },
    );
  }
}