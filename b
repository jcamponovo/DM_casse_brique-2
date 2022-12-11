import pyxel
import random



# taille de la fenetre128*128
# taille du pad24*8
#taille de la balle 6
# taille de la brique16*8*5 rangee donc 40 brique
# ne pas modifier
pyxel.init(128, 128, title="DM_casse_brique")
pyxel.load("briques+plateau.pyxres")

plateau_x = 52
plateau_y = 120

plateau_pas = 3
ballevitessepas= 1
Vitesse_balle= [-1,-1]

#compteur pour augmenter la vitesse toutes les 30 secondes
COMPTEUR_VITESSE = 30*30
compteur = 0

# initialisation des balles
Nb_max_balle= 1
nombre_balle= 0
balle_liste = []
briques_liste = []

debut_jeu = False

#debug
stopDraw = False

def debut_partie():
# 
global nombre_balle,balle_liste,briques_liste
global ballevitessepas,vitesse_pas
nombre_balles = 0
balles_liste = []
briques_liste = []
explosions_liste = []
compteur = 0
ball_speed_step = 1
ball_speed = [-1,-1]


def pad_deplacement(x):
"""déplacement avec les touches de directions"""

if pyxel.btn(pyxel.KEY_RIGHT):
    if (x < (104)) :
        x = x + pad_step
if pyxel.btn(pyxel.KEY_LEFT):
    if (x > 0) :
        x = x - pad_step
return x

# =========================================================
# == CREATION BALLE(s)
# =========================================================
def balle_creation(x, y, balle_liste):
"""création d'une balle avec la barre d'espace"""

global nombre_balle

   if pyxel.btnr(pyxel.KEY_SPACE):
      if (nombre_balle< nb_max_balle):
          balles_liste.append([x+4, y-4])
          nombre_balle = nombre_balle+ 1
return balle_liste

# =========================================================
# == CREATION BRIQUES
# =========================================================
def briques_creation(briques_liste):
global debut_jeu
# Liste de brique crée au départ
if not debut_jeu :
    brique_x= brique_y= 0
    couleur_brique =5

for i in range(41):
    briques_liste.append([brique_x, brique_y, couleur_brique])
    brique_x = brique_x + 16
    if(((i+1)%8) == 0):
        x_brique = 0
        brique_y = brique_y + 8
        couleur_brique = couleur_brique -1
        debut_jeu = True 
return briques_liste


def balle_deplacement(balle_liste, briques_liste):
"""déplacement de la balle """
global premier_contact, contact, stopDraw, nombre_balle

for balle in balle_liste:
    if (balle[0] + vitesse_balle[0] >= 126):
        vitesse_balle [0] = - vitesse_balle [0]

    if (balle[0] + vitesse_balle [0] <= 0 ):
        vitesse_balle [0] = - vitesse_balle [0]

    if (balle[1] + vitesse_balle [1] <= 0 ):
        vitesse_balle [1] = - vitesse_balle [1]


    if (balle[1] + BALLE_TAILLE/2) >= plateau_y :
        if(((balle[0] + BALLE_TAILLE/2) > plateau_x) and ((balle[0] - BALLE_TAILLE/2) < (plateau_x + 24))):
            if not contact :
                premier_contact = True
                contact = True
            if premier_contact:
                if(balle[1]>= plateau_y) and (balle[1] <= plateau_y + 8):
                    vitesse_balle [0] = - vitesse_balle [0]
                    vitesse_balle [1] = - vitesse_balle [1] # dans tous les cas, on remonte la balle
                premier_contact = False
# stopDraw = True
            else:
                 contact = False
                 premier_contact = False


# Balle touche brique ?
for brique in briques_liste:
    if(((balle[0] + BALLE_TAILLE/2) >= brique[0]) and ((balle[0] - BALLE_TAILLE/2) <= brique [0] + 16)):
         if(((balle[1] + BALLE_TAILLE/2) >= brique[1]) and ((balle[1] - BALLE_TAILLE/2) <= brique[1] + TAILLE_BRIQUE_VER)):
             if(balle[1]>= brique[1]) and (balle[1] <= brique[1] + 8):
                    vitesse_balle [0] = - vitesse_balle [0]
             else:
# Contact vertical (au dessous/en dessous)
                     vitesse_balle [1] = - vitesse_balle [1]
# comptabilise le nombre de contacts de la brique
                     brique[2] = brique[2] -1
                     if brique[2] == 0 :
                         briques_liste.remove(brique)

                         balle[0] += vitesse_balle [0]
                         balle[1] += vitesse_balle [1]

    if balle[1]> 122:
       balles_liste.remove(balle)
       nombre_balle= nombre_balle-1

return balle_liste


# =========================================================
# == UPDATE
# =========================================================
def update():
"""mise à jour des variables (30 fois par seconde)"""

global plateau_x, plateau_y, balle_liste, vitesse_balle, ballevitessepas
global nombre_balle, debut_jeu
# Nouvelle partie ?
if not debut_jeu :
    debut_partie()

# mise à jour de la position du pad
plateau_x, plateau_y = plateau_deplacement(plateau_x, plateau_y)

briques_liste= briques_creation(briques_liste)

# creation des balles en fonction de la position du pad
balles_liste = balles_creation(plateau_x, plateau_y, balle_liste)

# mise a jour des positions des balles
balle_liste = balle_deplacement(balle_liste, briques_liste)


# mise à jour de la vitesse de la balle

if nombre_balles == 0:
    debut_jeu = False #Perdu
elif briques_liste == []:
    debut_jeu = False #Gagne

# =========================================================
# == DRAW
# =========================================================
def draw():
"""création des objets (30 fois par seconde)"""
# Debug
global stopDraw, nombre_balles
if not stopDraw:

# vide la fenetre
pyxel.cls(0)

pyxel.blt(pad_x, pad_y, 0, 232, 248,24, 8)

if nombre_balles == 0:
    pyxel.text(11,64, 'GAME OVER - SPACE TO START', 8)

if briques_liste == []:
    pyxel.text(30,64, 'CONGRATS : YOU WON', 7)
else:
    for balle in balles_liste:
        pyxel.circ(balle[0], balle[1], 3,11) 
    for brique in briques_liste:
# Dessin différent en fonction du niveau
         if (brique[2] == 1):
              pyxel.blt(brique[0], brique[1], 0, 240, 232,16, 8)
        elif (brique[2] == 2):
              pyxel.blt(brique[0], brique[1], 0, 240, 208,16, 8)
        elif (brique[2] == 3):
              pyxel.blt(brique[0], brique[1], 0, 240, 216,16, 8)
        elif (brique[2] == 4):
              pyxel.blt(brique[0], brique[1], 0, 240, 224,16, 8)
        elif (brique[2] == 5):
              pyxel.blt(brique[0], brique[1], 0, 240, 200,16, 8)

pyxel.run(update, draw)
