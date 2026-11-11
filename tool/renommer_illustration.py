"""Remplace « CHAT ET GO » par « MES PRESTATAIRES » dans l'illustration de présentation.

Usage : python tool/renommer_illustration.py <image_source> <image_cible>
Seules les deux zones de texte/logo sont repeintes ; le reste de l'image est intact.
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generer_logo import masque_bulle, masque_repere, POLICE_GRAS, SUR  # noqa: E402

VERT_ENTETE = (108, 165, 112)
VERT_ROBOT = (80, 196, 87)
VERT_FONCE = (26, 84, 46)


def texte_ajuste(draw, texte, largeur_max, hauteur_max):
    taille = hauteur_max
    while taille > 8:
        f = ImageFont.truetype(POLICE_GRAS, taille)
        g, h, d, b = draw.textbbox((0, 0), texte, font=f)
        if d - g <= largeur_max and b - h <= hauteur_max:
            return f, (g, h, d, b)
        taille -= 1
    raise ValueError("texte trop long")


def ecrire_centre(img, texte, centre, largeur_max, hauteur_max, couleur):
    d = ImageDraw.Draw(img)
    f, (g, h, dr, b) = texte_ajuste(d, texte, largeur_max, hauteur_max)
    x = centre[0] - (dr - g) / 2 - g
    y = centre[1] - (b - h) / 2 - h
    d.text((x, y), texte, font=f, fill=couleur)


def symbole_fonce(s):
    """Le symbole de l'application, en vert foncé comme le logo d'origine du robot."""
    S = s * SUR
    sym = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sym.paste(Image.new("RGBA", (S, S), VERT_FONCE + (255,)), (0, 0), masque_bulle(S))
    sym.paste(Image.new("RGBA", (S, S), (255, 255, 255, 255)), (0, 0), masque_repere(S))
    return sym.resize((s, s), Image.LANCZOS)


def main(source, cible):
    img = Image.open(source).convert("RGBA")
    d = ImageDraw.Draw(img)

    # 1. En-tête du téléphone
    d.rectangle([674, 120, 884, 158], fill=VERT_ENTETE)
    ecrire_centre(img, "MES PRESTATAIRES", (779, 141), 250, 26, (255, 255, 255))

    # 2. Ventre du robot : ancien logo puis ancien texte
    d.rectangle([302, 628, 494, 752], fill=VERT_ROBOT)
    d.rectangle([272, 758, 504, 799], fill=VERT_ROBOT)
    sym = symbole_fonce(104)
    img.alpha_composite(sym, (398 - 52, 640))
    ecrire_centre(img, "MES PRESTATAIRES", (390, 779), 226, 30, VERT_FONCE)

    img.convert("RGB").save(cible, quality=95)
    print("illustration enregistrée :", cible)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
