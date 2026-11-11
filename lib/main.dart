import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // pour kReleaseMode
import 'package:device_preview/device_preview.dart';
import 'services/service_theme.dart';
import 'services/service_langue.dart';
import 'ecrans/ecran_splash.dart';
import 'theme/theme_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceTheme.chargerThemeSauvegarde();
  await ServiceLangue.chargerLangueSauvegardee();

  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
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
          title: 'Mes Prestataires',
          theme: ThemeApp.clair(),
          darkTheme: ThemeApp.sombre(),
          home: const EcranSplash(),
        );
      },
    );
  }
}
