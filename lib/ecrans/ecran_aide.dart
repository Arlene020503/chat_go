import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/service_langue.dart';
import '../theme/theme_app.dart';

class EcranAide extends StatelessWidget {
  const EcranAide({super.key});

  final List<Map<String, String>> _faq = const [
    {"question": "aide_question_1", "reponse": "aide_reponse_1"},
    {"question": "aide_question_2", "reponse": "aide_reponse_2"},
    {"question": "aide_question_3", "reponse": "aide_reponse_3"},
    {"question": "aide_question_4", "reponse": "aide_reponse_4"},
    {"question": "aide_question_5", "reponse": "aide_reponse_5"},
  ];

  Future<void> _contacterSupport() async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'audreyassoua22@gmail.com',
      query: 'subject=Besoin d\'aide - Mes Prestataires',
    );
    try {
      await launchUrl(email);
    } catch (_) {
      // Aucune application e-mail installée : rien à faire
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        final secondaire = ThemeApp.texteSecondaire(context);

        return Scaffold(
          appBar: AppBar(title: Text(ServiceLangue.texte("aide_titre"))),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                child: Text(
                  ServiceLangue.texte("aide_sous_titre").toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: secondaire,
                  ),
                ),
              ),
              for (final item in _faq)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      // Retire les traits ajoutés par défaut par ExpansionTile
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: ThemeApp.vert,
                        ),
                        title: Text(
                          ServiceLangue.texte(item["question"]!),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        iconColor: ThemeApp.vert,
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        children: [
                          Text(
                            ServiceLangue.texte(item["reponse"]!),
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaire,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton.icon(
                onPressed: _contacterSupport,
                icon: const Icon(Icons.mail_outline),
                label: Text(ServiceLangue.texte("aide_contacter_support")),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
