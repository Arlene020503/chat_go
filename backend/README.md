Serveur de test local pour `chat_go_app`

Installation et exécution (Windows PowerShell) :

1. Créer un environnement virtuel et l'activer :

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. Installer les dépendances :

```powershell
pip install -r requirements.txt
```

3. Lancer le serveur :

```powershell
python server.py
```

Le serveur écoute sur `http://0.0.0.0:5000` et expose `POST /chat`.
Test avec `curl` :

```powershell
curl -X POST http://localhost:5000/chat -H "Content-Type: application/json" -d '{"message":"test"}'
```

Si vous testez depuis un appareil Android réel, remplacez `localhost` par l'IP de votre machine (ex: `http://192.168.1.42:5000`) puis lancez l'application avec `flutter run --dart-define=API_URL=http://192.168.1.42:5000`.
