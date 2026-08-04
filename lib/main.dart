import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // pour kReleaseMode
import 'package:device_preview/device_preview.dart';
import 'services/service_theme.dart';
import 'services/service_langue.dart';
import 'ecrans/ecran_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceTheme.chargerThemeSauvegarde();
  await ServiceLangue.chargerLangueSauvegardee();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ServiceTheme.themeNotifier,
      builder: (context, modeActuel, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: modeActuel,

          // --- THÈME CLAIR ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00A859),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardColor: Colors.white,
          ),

          // --- THÈME SOMBRE ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00A859),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: const Color(0xFF1E1E1E),
          ),

          home: const EcranSplash(),
        );
      },
    );
  }
}