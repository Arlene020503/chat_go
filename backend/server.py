"""Backend optionnel de Chat&Go.

L'application fonctionne sans lui. S'il est lancé, démarrer l'app avec :
    flutter run --dart-define=API_URL=http://<ip-de-la-machine>:5000
"""
import os
import unicodedata

from flask import Flask, jsonify, request

app = Flask(__name__)

PRESTATAIRES = [
    {
        "id": 1, "nom": "Atelier Martin", "categorie": "Plomberie",
        "description": "Dépannage et rénovation de plomberie.",
        "telephone": "0123456789", "whatsapp": "33612345678", "note": 4.8,
        "prix": "€€", "adresse": "10 rue de la République", "ouvert": 1, "image_url": None,
    },
    {
        "id": 2, "nom": "L'Instant Zen", "categorie": "Massage",
        "description": "Massages relaxants et soins bien-être.",
        "telephone": "0123456790", "whatsapp": "33612345679", "note": 4.7,
        "prix": "€€€", "adresse": "24 avenue Victor Hugo", "ouvert": 1, "image_url": None,
    },
    {
        "id": 3, "nom": "Le Jardin Gourmand", "categorie": "Restaurant",
        "description": "Cuisine maison, produits frais et locaux.",
        "telephone": "0123456791", "whatsapp": "33612345680", "note": 4.6,
        "prix": "€€", "adresse": "5 place du Marché", "ouvert": 1, "image_url": None,
    },
]

MOTS_CLES = {
    "Plomberie": ["plombier", "plomberie", "fuite", "tuyau", "robinet", "plumber"],
    "Massage": ["massage", "masseur", "spa", "bien etre", "masaje"],
    "Restaurant": ["restaurant", "manger", "repas", "diner", "dejeuner", "eat", "food"],
}


def normaliser(texte):
    sans_accents = unicodedata.normalize("NFD", texte.lower())
    return "".join(c for c in sans_accents if unicodedata.category(c) != "Mn")


@app.get("/health")
def sante():
    return jsonify({"succes": True})


@app.post("/chat")
def chat():
    data = request.get_json(force=True, silent=True) or {}
    message = normaliser(str(data.get("message", "")))
    if not message.strip():
        return jsonify({"succes": False, "erreur": "Message vide"}), 400

    categories = [nom for nom, mots in MOTS_CLES.items() if any(mot in message for mot in mots)]
    resultats = [p for p in PRESTATAIRES if p["categorie"] in categories]

    # Une liste vide laisse l'application faire sa propre recherche (locale puis Internet)
    return jsonify({
        "succes": True,
        "message": "Voici les prestataires disponibles près de chez vous." if resultats else "",
        "prestataires": resultats,
    })


if __name__ == "__main__":
    # Écoute sur toutes les interfaces pour être accessible depuis un appareil physique
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)),
            debug=os.environ.get("FLASK_DEBUG") == "1")
