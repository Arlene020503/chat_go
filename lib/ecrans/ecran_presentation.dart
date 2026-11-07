import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_langue.dart';
import '../widgets/contenu_page_intro.dart';
import 'ecran_connexion.dart';

class EcranPresentation extends StatefulWidget {
  const EcranPresentation({super.key});

  static const String clePresentationVue = "presentation_vue";

  @override
  State<EcranPresentation> createState() => _EcranPresentationState();
}

class _EcranPresentationState extends State<EcranPresentation> {
  final PageController _pageController = PageController();
  int _pageActuelle = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _terminer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(EcranPresentation.clePresentationVue, true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EcranConnexion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_pageActuelle != 1)
            TextButton(
              onPressed: _terminer,
              child: Text(
                ServiceLangue.texte("intro_passer"),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 33, 205, 39),
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _pageActuelle = page;
              });
            },
            children: [
              ContenuPageIntro(
                couleur: Colors.white,
                titre: ServiceLangue.texte("intro_titre_1"),
                description: ServiceLangue.texte("intro_description_1"),
                cheminImage: "assets/img1.jpeg",
              ),
              ContenuPageIntro(
                couleur: Colors.white,
                titre: ServiceLangue.texte("intro_titre_2"),
                description: ServiceLangue.texte("intro_description_2"),
                cheminImage: "assets/img2.jpg",
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => _construirePoint(index),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_pageActuelle < 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _terminer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 33, 205, 39),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      ServiceLangue.texte(
                        _pageActuelle == 1
                            ? "intro_commencer"
                            : "intro_suivant",
                      ),
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirePoint(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _pageActuelle == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _pageActuelle == index
            ? const Color.fromARGB(255, 33, 205, 39)
            : const Color.fromARGB(255, 210, 245, 212),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
