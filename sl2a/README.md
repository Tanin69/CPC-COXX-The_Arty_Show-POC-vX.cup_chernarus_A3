# SL2A

## Qu'est-ce quoi donc ?

Le SL2A (Système de Localisation Acoustique de tirs d'Artillerie) est inspiré d'un système réel développé par Thalès. Il est en utilisation dans l'armée française depuis le milieu des années 2000 (<https://www.thalesgroup.com/fr/sl2a>). Ses avantages sont sa rusticité, sa rapidité de déploiement, sa totale discrétion (par rapport aux radars) et son faible coût. Il est notamment utilisé pour détecter les départs de tirs et permettre ainsi aux radars de contrebatterie de ne s'allumer que le temps requis pour détecter les trajectoires.

Ce script permet de doter les IA hostiles et les joueurs d'un SL2A. En outre, les IA hostiles peuvent déclencher de tirs de contre batterie.

## Pour les joueurs

### Le SL2A pour les IA hostiles

Arrivé à une certaine précision de localiation, le groupe équipé du SL2A commencera à demander des missions de tir aux pièces de contre-batterie

### Le SL2A pour les joueurs

Le SL2A est un système embarqué dans un véhicule terrestre. Le SL2A ne fonctionne qui s'il y a au moins un opérateur dans le véhicule. Tout personnel dans le véhicule accède au SL2A. Le système est inactif quand le véhicule est en déplacement. En cas de localisation d'un tir :

* Un message informe le ou les opérateurs de la détection (chat du véhicule)
* Un marqueur est posé sur la carte du ou des opérateurs

**Ceci ne fonctionne que pour les personnels embarqués dans le vehicule**.

Une fonction (interaction ACE sur soi-même) permet de purger tout ou partie des marqueurs.

**Important** : la précision de localisation maximale du SL2A est de 50 m. Quand une détection de cette précision est faite, le marqueur a un fond rouge. Il faut obligatoirement purger le SL2A à ce moment, sans quoi aucune autre détection de 50 m. ne sera marquée.

### Caractéristiques techniques

#### Effet lié à la distance entre le système et la pièce qui tire

* Au plus le groupe équipé du SL2A est proche des tirs, au plus la probabilité de localisation des tirs augmente

Hors effets liés au relief et pour un tir de pièce de 82 mm, les caractéristiques par défaut donnent les probabilités de localisation en fonction de la distance suivantes (la sensibilité du système peut être modifiée par le créateur de mission) :

* 0,125 à 4 000 m.
* 0,22 à 3 000 m.
* 0,5 à 2 000 m.
* 0,75 à 1 650 m.

#### Effet lié au nombre de tirs

* Au plus le nombre de tirs localisés pour une pièce donnée augmente, au plus la précision de localisation pour cette pièce augmente, *tant que cette pièce ne change pas de position*.

#### Effet lié au calibre de la pièce de tir

* Au plus le calibre est important, au plus la probabilité de localisation augmente.

#### Effet lié au relief

* Le système est sensible aux effets de relief. Au plus le relief entre le SL2A et le tir est important, au plus la probabilité de localisation diminue.

##### Estimation de l'effet du relief

* L'effet du relief est sensible à partir de 20 m. de dénivelé positif entre le système et la pièce qui tire
* On estime que pour un distance de 1000 m. avec un dénivelé positif de 20 m. ou plus, la probabilité de localisation diminiue de 10%. Une probabilité de 0,5 sera donc réduite à 0,4 dans ces conditions.

**La probabilité de localisation ne peut jamais dépasser 0,75 (3 chances sur 4).**

## Pour les missions makers

### Paramétrage dans l'éditeur de mission

#### Les IA hostiles

Le SL2A : dans l'init du *groupe* de détection IA, insérer la ligne suivante :

    this setVariable ["sl2a_detect_ia", true];

Un seul groupe peut être équipé du SL2A.

La contre-batterie : dans l'init de la ou des *pièces d'artillerie* dédiées aux missions de conrte-batterie, insérer la ligne suivante :

    this setVariable ["sl2a_counter_ia", true];

Il n'y a pas de limite au nombre de pièces de contre-batterie. Les pièces n'ont pas besoin d'être dans le même groupe. Elles peuvent être réparties n'importe où sur la carte. A chaque mission de tir qui leur sera donnée, les pièces de contre batterie tireront de façon synchronisée.

#### Les joueurs

Le SL2A est obligatoirement un équipement de véhicule. Dans l'init du véhicule qui sera équipé, insérer la ligne suivante :

    this setVariable ["sl2a_detect_player", true];

Un seul véhicule peut être équipé du SL2A.

#### Lancer le script

TODO

#### Paramétrer la sensibilité du SL2A

La probabilité de localisation d'un tir varie en fonction de l'inverse du carré de la distance entre le système et le tir :

    probabilité = sensibilité / distance²

Vous pouvez facilement ajuster la sensibilité par rapport à votre contexte de mission avec la formule suivante :

    sensibilité = probabilité * distance².

Par exemple, si vous voulez obtenir la sensibilité pour que la probabilté de localisation soit de 0.5 à 3 kilomètres :

    sensibilité = 0,5 * 3000²

Le paramètre résultant, pour des facilités d'écriture, est divisé par 1 000 000. Ex. Une sensibilité de 4 000 000 doit être paramétrée avec 4.
