import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/service_langue.dart';

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
      query: 'subject=Besoin d\'aide - Chat&Go',
    );
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        final estSombre = Theme.of(context).brightness == Brightness.dark;

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
              ServiceLangue.texte("aide_titre"),
              style: GoogleFonts.roboto(
                color: estSombre ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _faq.length,
                  itemBuilder: (context, index) {
                    final item = _faq[index];
                    return ExpansionTile(
                      title: Text(
                        ServiceLangue.texte(item["question"]!),
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: estSombre ? Colors.white : Colors.black87,
                        ),
                      ),
                      iconColor: estSombre ? Colors.white70 : Colors.black87,
                      collapsedIconColor: estSombre ? Colors.white54 : Colors.black54,
                      childrenPadding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                      children: [
                        Text(
                          ServiceLangue.texte(item["reponse"]!),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: estSombre ? Colors.white60 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _contacterSupport,
                    icon: const Icon(Icons.mail_outline, color: Colors.white),
                    label: Text(
                      ServiceLangue.texte("aide_contacter_support"),
                      style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 33, 205, 39),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}