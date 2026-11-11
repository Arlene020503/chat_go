// lib/ecrans/ecran_splash.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_langue.dart';
import 'ecran_chat.dart';
import 'ecran_presentation.dart';

class EcranSplash extends StatefulWidget {
  const EcranSplash({super.key});

  @override
  State<EcranSplash> createState() => _EcranSplashState();
}

class _EcranSplashState extends State<EcranSplash> {
  double _progress = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // 2,5 secondes de chargement (25 × 100 ms)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      setState(() {
        _progress = (timer.tick / 25).clamp(0, 1);
      });
      if (timer.tick >= 25) {
        timer.cancel();
        // La présentation n'est montrée qu'au premier lancement
        final prefs = await SharedPreferences.getInstance();
        final dejaVue =
            prefs.getBool(EcranPresentation.clePresentationVue) ?? false;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  dejaVue ? const EcranChat() : const EcranPresentation(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Même logo, même taille et même position que l'écran de lancement
          // natif : la transition entre les deux est invisible
          Center(
            child: Image.asset(
              'assets/splash.png',
              width: 250,
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.45),
            child: SizedBox(
              width: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF00A859),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ServiceLangue.texte("splash_chargement"),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
