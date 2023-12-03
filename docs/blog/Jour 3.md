## Ce que j'ai retenu des épisodes précédents

Il faut que je me calme avec `regex`.

Il faut que je crée plus de petites fonctions nommées plutôt que d'attaquer le problème "de l'extérieur".

## Partie 1

Un moteur d'Elfe à réparer. Typique.

OK, on a une matrice de caractères qui ressemble à ça :

```
$ 467..114..
$ ...*......
$ ..35..633.
$ ......#...
$ 617*......
$ .....+.58.
$ ..592.....
$ ......755.
$ ...$.*....
$ .664.598..
```

Et il faut identifier tous les chiffres qui sont adjacents (même en diagonale) à un symbole autre que "." (ou un autre chiffre).

Au moins, aujourd'hui pas d'excude de difficulté de _parsing_ ! Après le découpage en lignes il me suffit d'enlever les boîtes superflues (comme toutes les lignes ont la même longueur) avec `unbox` :

```
$ 467..114..
$ ...*......
$ ..35..633.
$ ......#...
$ 617*......
$ .....+.58.
$ ..592.....
$ ......755.
$ ...$.*....
$ .664.598..

Parse ← ≡⊔Lines
Parse
```

Il y aurait plus direct sans utiliser ma fonction toute faite `Lines` mais je n'ai pas envie de passer du temps là-dessus.

Ah tiens, j'ai mal lu : il faut trouver des _nombres_ écrits horizontalement (dans l'exemple ils font tous deux ou trois chiffres; je vérifie dans l'entrée et je constate que ça va de un à trois chiffres) qui touchent un symbole, c'est un peu plus compliqué.

Comment faire ? Déjà, je devrais pouvoir facilement, sur une ligne donnée, isoler les nombres. Hmm, si j'ai trouvé les coordonnées d'un nombre dans la matrice (ex. `(3,3)-(4,3)`) je devrais pouvoir agrandir ce rectangle d'une case tout autour (donc `(2,2)-(5,4)`), et vérifier dans cette zone si un symbole est présent.

Je pourrais aussi faire l'inverse : pour chaque symbole trouvé dans la matrice, marquer les 8 cases qui l'entourent. Ensuite un nombre n'est valide que s'il recouvre au moins une case marquée. Cette dernière option me paraît un peu plus simple, alors allons-y.

```
$ ....
$ ....
$ .*..
$ .12.
$ ....

Parse

FindSymbols ← ¬∊: "0123456789."

FindSymbols
```

J'ai utilié `member` dont j'inverse les arguments avec `:`. L'opération s'applique de façon "pervasive", c'est-à-dire qu'elle va automatiquement descendre dans ma matrice de caractères et faire le test demandé sur chaque élément, en reconstruisant une matrice de `0` et de `1` de la même forme. J'applique ensuite une négation avec `not` qui s'applique de même élément par élément.

Maintenant il faut trouver les voisins des `1` dans cette matrice.


