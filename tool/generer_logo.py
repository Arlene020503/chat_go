"""Génère le logo et les icônes de « Mes Prestataires ».

Usage (depuis la racine du projet) :  python tool/generer_logo.py
Couleurs : celles de l'application (#21CD27 -> #00A859, texte bleu nuit).
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

RACINE = Path(__file__).resolve().parent.parent
VERT_VIF = (33, 205, 39)
VERT = (0, 168, 89)
BLEU_NUIT = (22, 48, 78)
POLICE_GRAS = "C:/Windows/Fonts/segoeuib.ttf"
POLICE_LEGERE = "C:/Windows/Fonts/segoeuisl.ttf"
SUR = 4  # suréchantillonnage pour des bords lisses


def degrade(taille):
    """Dégradé diagonal vert vif -> vert."""
    l, h = taille
    petit = Image.new("RGB", (64, 64))
    for y in range(64):
        for x in range(64):
            t = (x + y) / 126
            petit.putpixel((x, y), tuple(int(VERT_VIF[i] + (VERT[i] - VERT_VIF[i]) * t) for i in range(3)))
    return petit.resize((l, h), Image.BICUBIC)


def masque_bulle(s):
    """Bulle de discussion avec sa pointe, dans un carré s x s."""
    m = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0.06 * s, 0.06 * s, 0.94 * s, 0.80 * s], radius=0.24 * s, fill=255)
    d.polygon([(0.22 * s, 0.70 * s), (0.15 * s, 0.96 * s), (0.46 * s, 0.76 * s)], fill=255)
    return m


def masque_repere(s):
    """Repère de localisation (épingle) centré dans la bulle, avec son trou."""
    m = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(m)
    cx, cy, r = 0.5 * s, 0.36 * s, 0.17 * s
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    d.polygon([(cx - 0.148 * s, cy + 0.085 * s), (cx + 0.148 * s, cy + 0.085 * s), (cx, 0.70 * s)], fill=255)
    rt = 0.068 * s
    d.ellipse([cx - rt, cy - rt, cx + rt, cy + rt], fill=0)
    return m


def marque(s, bulle_blanche=False):
    """Le symbole : bulle verte + repère blanc (ou bulle blanche + repère vert)."""
    S = s * SUR
    bulle, repere = masque_bulle(S), masque_repere(S)
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    if bulle_blanche:
        img.paste(Image.new("RGBA", (S, S), (255, 255, 255, 255)), (0, 0), bulle)
        img.paste(degrade((S, S)).convert("RGBA"), (0, 0), repere)
    else:
        img.paste(degrade((S, S)).convert("RGBA"), (0, 0), bulle)
        img.paste(Image.new("RGBA", (S, S), (255, 255, 255, 255)), (0, 0), repere)
    return img.resize((s, s), Image.LANCZOS)


def logo_complet(largeur=1662, hauteur=600, fond=None):
    """Symbole + « Mes Prestataires » + slogan, ratio des écrans de lancement."""
    L, H = largeur * SUR, hauteur * SUR
    img = Image.new("RGBA", (L, H), fond or (0, 0, 0, 0))
    taille_marque = int(H * 0.78)
    sym = marque(taille_marque // SUR).resize((taille_marque, taille_marque), Image.LANCZOS)
    img.alpha_composite(sym, (int(H * 0.06), (H - taille_marque) // 2))

    x0 = int(H * 0.06) + taille_marque + int(H * 0.10)
    disponible = L - x0 - int(H * 0.06)
    d = ImageDraw.Draw(img)
    # Taille de police maximale qui tient dans la largeur disponible
    taille = int(H * 0.30)
    while True:
        f = ImageFont.truetype(POLICE_GRAS, taille)
        if d.textlength("Mes Prestataires", font=f) <= disponible:
            break
        taille -= 4
    f_slogan = ImageFont.truetype(POLICE_LEGERE, int(taille * 0.42))
    haut_titre = f.getbbox("MP")[3]
    haut_slogan = f_slogan.getbbox("Tp")[3]
    espace = int(taille * 0.18)
    y = (H - (haut_titre + espace + haut_slogan)) // 2 - int(taille * 0.08)
    d.text((x0, y), "Mes ", font=f, fill=BLEU_NUIT)
    d.text((x0 + d.textlength("Mes ", font=f), y), "Prestataires", font=f, fill=VERT)
    d.text((x0 + int(taille * 0.04), y + haut_titre + espace), "Trouvez le bon prestataire", font=f_slogan, fill=BLEU_NUIT)
    return img.resize((largeur, hauteur), Image.LANCZOS)


def icone_app(s, arrondi=0.0, opaque=True, echelle=0.62):
    """Icône d'application : fond vert en dégradé + bulle blanche et repère vert."""
    fond = degrade((s, s)).convert("RGBA")
    if arrondi:
        m = Image.new("L", (s * SUR, s * SUR), 0)
        ImageDraw.Draw(m).rounded_rectangle([0, 0, s * SUR - 1, s * SUR - 1], radius=int(arrondi * s * SUR), fill=255)
        fond.putalpha(m.resize((s, s), Image.LANCZOS))
    t = int(s * echelle)
    sym = marque(t, bulle_blanche=True)
    fond.alpha_composite(sym, ((s - t) // 2, (s - t) // 2 + int(s * 0.02)))
    if opaque:
        return fond.convert("RGB")
    return fond


def enregistrer(img, chemin, mode=None):
    chemin = RACINE / chemin
    chemin.parent.mkdir(parents=True, exist_ok=True)
    if mode:
        img = img.convert(mode)
    img.save(chemin)
    print("  ", chemin.relative_to(RACINE), img.size)


def main():
    print("Logos :")
    enregistrer(logo_complet(), "assets/splash.png")
    # Écrans de lancement natifs : l'image est lue comme du 4x -> 250 px de large à l'écran
    enregistrer(logo_complet(1000, 361), "assets/splash_natif.png")
    sym = Image.new("RGBA", (1152, 1152), (0, 0, 0, 0))
    sym.alpha_composite(marque(640), (256, 256))  # zone sûre de l'écran Android 12
    enregistrer(sym, "assets/splash_icon.png")
    enregistrer(marque(512), "assets/logo_symbole.png")
    enregistrer(marque(512, bulle_blanche=True), "assets/logo_symbole_blanc.png")

    print("Icônes Android :")
    for dossier, s in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        enregistrer(icone_app(s, arrondi=0.22, opaque=False), f"android/app/src/main/res/mipmap-{dossier}/ic_launcher.png")

    print("Icône adaptative Android 8+ (fond vert + symbole, découpée par le téléphone) :")
    for dossier, s in {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}.items():
        avant = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        t = int(s * 0.46)  # reste dans la zone sûre (66 dp sur 108)
        avant.alpha_composite(marque(t, bulle_blanche=True), ((s - t) // 2, (s - t) // 2 + int(s * 0.015)))
        enregistrer(avant, f"android/app/src/main/res/mipmap-{dossier}/ic_launcher_foreground.png")
        enregistrer(degrade((s, s)), f"android/app/src/main/res/mipmap-{dossier}/ic_launcher_background.png")
    xml = (RACINE / "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml")
    xml.parent.mkdir(parents=True, exist_ok=True)
    xml.write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
""",
        encoding="utf-8",
    )
    print("  ", xml.relative_to(RACINE))

    print("Icônes iOS :")
    dossier_ios = RACINE / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for f in sorted(dossier_ios.glob("*.png")):
        s = Image.open(f).size[0]
        enregistrer(icone_app(s), f.relative_to(RACINE))

    print("Icônes web :")
    for s in (192, 512):
        enregistrer(icone_app(s), f"web/icons/Icon-{s}.png")
        enregistrer(icone_app(s, echelle=0.5, opaque=False), f"web/icons/Icon-maskable-{s}.png")
    enregistrer(icone_app(16, arrondi=0.22, opaque=False, echelle=0.8), "web/favicon.png")

    print("Icône Windows :")
    ico = icone_app(256, arrondi=0.22, opaque=False)
    chemin_ico = RACINE / "windows/runner/resources/app_icon.ico"
    ico.save(chemin_ico, sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    print("  ", chemin_ico.relative_to(RACINE))


if __name__ == "__main__":
    main()
