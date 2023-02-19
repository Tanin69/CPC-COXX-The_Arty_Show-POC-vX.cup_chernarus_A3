Qu'est-ce quoi donc ?

SL2A (système de localisation acoustique d'artillerie) est inspiré d'un système réel développé par THalès. Il est en utilisation dans l'armée française depuis le milieu des années 2000 (https://www.thalesgroup.com/fr/sl2a). Ses avantages sont sa rusticité, sa rapidité de déploiement, sa totale discrétion (par rapport aux radars) et son faible coût. Il est notamment utilisé pour détecter les départs de tirs et permettre ainsi aux radars de contrebatterie de ne s'allumer que le temps requis pour détecter les trajectoires.

L'implémentation ne peut pas reposer sur les fonctions du moteur knowsAbout et targetKnoledge car celles-ci sont limitées par la viewdistance. Augmenter la viewdistance n'est pas une bonne solution car toutes les IA sont simulées dans le rayon de la viewdsitance, ce qui sginifie qu'une grande viewdistance et beaucoup d'IA écroulent complètement les performances du jeu.

J'ai donc réimplémenté un système from scratch.

1) A chaque tir et en fonction de la distance, la probabilité pour qu'un tir soit enregistré est définie.
2) La probabilité varie de 0 à 0.75. La précision varie de 1000 à 100.
Lorsque le tir est effectivement enregistré par le système, la précision de la détection dépend de la distance et du niveau de détection en cours. Chaque enregistrement réussi fait augmenter progressivement la précision de la détection. Lorsque la précision arrive à un certain niveau, l'unité de détection inscrit une mission de tir dans la liste.

Une unité d'artillerie dédiée à la contre batterie effectue les tirs de cette liste au fur et à mesure.


Implémentation pour les IA (pour le moment, tout ça est très monolythique)

* Une unité équipée, identifiée par une variable attachée au groupe concerné : _group setVariable ["sl2a_detect", true]
* Une unité de contre-batterie identifée par une variable attachée au groupe de contre-batterie _group setVariable ["sl2a_counter", true]
* On utilise l'event handler "fired" pour détecter les tirs des pièces à traquer
* A chaque tir détecté, la connaissance de la position de tir par l'unité de détection SL2A s'améliore, tant que les tirs sont suffisamment rapprochés. En effet, après un certain temps sans tir, l'unité de détection "oublie" ce qu'elle a appris sur la position de tir (lié au fonctionnement de la commande knowsAbout, mais plutôt intéressant en termes de game play)
* La probabilité de détection dépend :
  * de la distance entre le groupe SL2A et le départ de tir (fonction inverse du carré de la distance)
  * du nombre de tirs
  * de la fréquence de tir
* Une fois qu'un certain niveau de précision est atteint, le groupe de détection demande une frappe à l'unité de contre batterie.
* L'unité de contre-batterie arrose dans le rayon égale à la précision transmise par l'unité de détection. Elle s'assure qu'aucune unité amie n'est dans ce rayon, augmenté de 100 m. Si oui, l'ordre de tir est annulé.
