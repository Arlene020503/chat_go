# Chat Go App

Application Flutter de recherche de prestataires locaux à partir d'une conversation.
L'utilisateur peut demander un plombier, un massage, un restaurant ou un service
similaire, puis consulter les résultats et leurs informations de contact.

## Fonctionnalités

- écran d'accueil et parcours de présentation ;
- recherche conversationnelle de prestataires ;
- catégories reconnues dans les 5 langues : plomberie, massage, restaurant, coiffure,
  électricité, mécanique, pharmacie et hôtel (ainsi que toute recherche libre) ;
- précision de la ville dans le message (ex. « plombier à Cocody ») ; Abidjan par défaut ;
- recherche complémentaire sur OpenStreetMap/Nominatim lorsque les données locales
  ne suffisent pas ;
- sauvegarde locale des résultats trouvés pour les recherches suivantes ;
- consultation de l'historique ;
- actions Appeler, WhatsApp et Itinéraire selon les informations du prestataire ;
- thèmes clair, sombre ou système ;
- interface disponible en français, anglais, allemand, espagnol et chinois ;
- écran d'aide et paramètres.

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
