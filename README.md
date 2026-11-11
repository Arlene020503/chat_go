# Mes Prestataires

Application Flutter qui trouve de **vrais** prestataires et boutiques en Côte d'Ivoire
à partir d'une conversation, avec leurs numéros et WhatsApp quand ils existent.

## Fonctionnalités

- conversation naturelle : salutations, « qui es-tu ? », remerciements, mémoire du
  sujet (« et à Yopougon ? »), « plus de résultats » ;
- 26 catégories reconnues dans 5 langues, services (plombier, pharmacie, coiffure,
  garage, banque…) et produits (chaussures, téléphones, vêtements, meubles…) ;
- quartier ou ville détectés dans la phrase (Cocody, Yopougon, Bouaké…), Abidjan par défaut ;
- sources réelles uniquement :
  - OpenStreetMap (Overpass et Nominatim) pour les établissements, numéros, sites web,
    horaires et position ;
  - Jumia Côte d'Ivoire et CoinAfrique pour les achats en ligne ;
  - Wikipédia pour les questions générales (« c'est quoi l'attiéké ? ») ;
- numéros ivoiriens normalisés (10 chiffres) et lien WhatsApp pour les mobiles ;
- résultats sauvegardés sur le téléphone : la recherche suivante est instantanée ;
- fiches avec Appeler, WhatsApp, Itinéraire, Site web et Partager ;
- historique (relance en un geste, suppression par glissement) ;
- thèmes clair, sombre ou système ; interface en français, anglais, allemand,
  espagnol et chinois.

## Logo et icônes

Le logo, l'icône de l'application (Android adaptative, iOS, web, Windows) et
l'illustration de présentation sont générés par des scripts Python (Pillow) :

```powershell
python tool/generer_logo.py
dart run flutter_native_splash:create
```

## Prérequis

- Flutter installé et ajouté au `PATH` ;
- Dart fourni avec Flutter ;
- Android Studio et un émulateur Android, ou un appareil physique ;
- Python 3 uniquement si le serveur de test local est utilisé.

Vérifier l'installation Flutter :

```powershell
flutter doctor
```

## Installation et lancement

Depuis la racine du projet :

```powershell
flutter pub get
flutter run
```

Pour lancer les tests :

```powershell
flutter test
```

Pour générer une version Android :

```powershell
flutter build apk --release
```

L'application active `DevicePreview` en mode debug afin de tester plusieurs tailles
d'écran. Cette fonctionnalité est désactivée dans une version release.

## Serveur de test local

Le dossier `backend` contient un serveur Flask **optionnel** : l'application fonctionne
sans lui. Il expose `GET /health` et `POST /chat` (catalogue + mots-clés). S'il ne
renvoie aucun résultat ou est injoignable, l'application bascule sur sa propre recherche.

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python server.py
```

Le serveur écoute sur `http://localhost:5000`. Tester l'endpoint :

```powershell
curl -X POST http://localhost:5000/chat `
  -H "Content-Type: application/json" `
  -d '{"message":"Je cherche un plombier"}'
```

Depuis un appareil Android physique, `localhost` désigne l'appareil lui-même.
Utiliser l'adresse IP locale de l'ordinateur, par exemple
`http://192.168.1.42:5000`, et lancer l'application avec :

```powershell
flutter run --dart-define=API_URL=http://192.168.1.42:5000
```

> L'ancien serveur `https://backend-chatgo.onrender.com` ne répond plus : c'est ce qui
> empêchait l'IA de répondre. L'application n'en dépend plus.

## Organisation du projet

```text
lib/
  ecrans/       écrans et parcours de l'application
  modeles/      modèles de données, notamment Prestataire
  services/     recherche, langue, thème et persistance
  widgets/      composants réutilisables
  main.dart     initialisation et configuration Flutter
assets/         ressources graphiques et splash screen
backend/        serveur Flask de test
test/           tests Flutter
```

## Recherche et données

La logique de recherche se trouve dans `lib/services/service_ia.dart` :

1. le message est normalisé et sa catégorie est détectée, y compris avec de petites
   fautes de frappe ;
2. les prestataires intégrés et ceux sauvegardés localement sont filtrés ;
3. si aucun résultat n'est trouvé, une requête Nominatim est effectuée (Côte d'Ivoire
   par défaut, ou la ville indiquée), en écartant arrêts de bus et routes ;
4. les nouveaux résultats sont enregistrés avec `shared_preferences`.

Les données de démonstration sont donc embarquées dans l'application. Les recherches
Internet dépendent de la connexion réseau et des conditions d'utilisation de
Nominatim.

## Développement

Après une modification du code, les commandes les plus utiles sont :

```powershell
dart format lib test
flutter analyze
flutter test
```

Le projet utilise Material 3, `google_fonts`, `http`, `shared_preferences`,
`url_launcher`, `share_plus` et `device_preview`.
