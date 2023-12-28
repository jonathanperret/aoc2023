##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) 11 [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 

# Jour 11

## Partie 1

Nous voilà dans un observatoire.

Et voici ce qu'on observe :

```no_run
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
```

Le chercheur Elfe voudrait connaître la somme des longueurs de chemins minimaux entre chaque paire de galaxies. Déjà ça serait du travail, mais en plus l'univers s'étend.

Mais pas uniformément : seules les lignes et colonnes ne contenant pas de galaxies doublent de taille, donnant cette image modifiée :

```no_run
....#........
.........#...
#............
.............
.............
........#....
.#...........
............#
.............
.............
.........#...
#....#.......
```

Ensuite, pour chaque paire de galaxies on veut calculer le plus court chemin qui n'implique des mouvements horizontaux et verticaux, soit ici 9 :

```no_run
....1........
.........2...
3............
.............
.............
........4....
.5...........
.##.........6
..##.........
...##........
....##...7...
8....9.......
```

Et la réponse finale est la somme de ces longueurs de chemins.

Commençons par la lecture de l'entrée. Je me demande s'il y a une raison d'utiliser une autre représentation que la grille qui est suggérée, et je me dis que pour la partie "expansion de l'univers" en tout cas, ça devrait être le plus pratique de rester comme ça.

Je remplace simplement les `#` et `.` par des `1` et `0`.

```
$ ...#......
$ .......#..
$ #.........
$ ..........
$ ......#...
$ .#........
$ .........#
$ ..........
$ .......#..
$ #...#.....

Parse ← ⊜(=@#)≠@\n.
```

L'expansion de l'univers, ensuite.

Commençons par les lignes. Pour identifier les lignes vides un `reduce``maximum` devrait suffire, mais comment remplacer une ligne par deux ?

Je tâtonne un moment avec des variantes de `under``keep` puis je finis enfin par me souvenir que `keep` peut prendre un masque avec des nombres supérieurs à `1`, auquel cas elle répète les éléments indiqués. Il me suffit donc d'identifier les lignes à dupliquer avec `≡(¬/↥)` — ce qui me donne une liste de `0` et de `1` — puis d'incrémenter cette liste de `1`, pour obtenir le nombre de répétitions de chaque ligne à effectuer :

```
[0_0_0_0_1_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_1_0_0
 1_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_1_0_0_0
 0_1_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0_0_0]
▽ +1 ⊃≡(¬/↥)∘
```

Une fois les lignes répétées, il me suffit de transposer la matrice et de répéter l'opération.

```
Expand ← ⍥(⍉ ▽ +1 ⊃≡(¬/↥)∘)2

[0_0_0_1_0_0_0_0_0_0
 0_0_0_0_0_0_0_1_0_0
 1_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_1_0_0_0
 0_1_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_1
 0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_1_0_0
 1_0_0_0_1_0_0_0_0_0]
Expand
```

Ensuite, énumérer les paires de galaxies.

J'obtiens d'abord une liste de coordonnées avec `where`.

```
[0_0_0_1_0_0_0
 0_0_0_0_0_0_0
 0_0_0_0_0_0_0
 1_0_0_0_0_0_0
 0_0_0_0_0_0_1]
⊚
```

Pour calculer la distance entre deux galaxies, l'astuce est de repérer qu'un chemin qui va complètement à la verticale, puis complètement à l'horizontale, est de même longueur que "l'escalier" donné dans l'exemple :

```no_run
.5...........
.#...........
.#...........
.#...........
.#...........
.####9.......
```

Et la longueur de ce chemin est bien plus évidente : c'est la somme des valeurs absolues des différence de coordonnées. On appelle aussi ça "distance de Manhattan".

Bref, voici ma fonction `Distance` :

```
Distance ← /+⌵-

Distance 6_1 11_5
```

Reste à calculer ça sur toutes les paires de galaxies.

La fonction `cross` ma paraît indiquée. Le seul inconvénient c'est qu'elle va calculer chaque paire deux fois. Pas de problème, je diviserai la somme par 2.

```
AllDistances ← ⊠Distance.⊚
AllDistances
```

Et voici donc `PartOne` :

```
Parse ← ⊜(=@#)≠@\n.
Expand ← ⍥(⍉ ▽ +1 ⊃≡(¬/↥)∘)2
Distance ← /+⌵-
AllDistances ← ⊠Distance.⊚
PartOne ← ÷2/+♭AllDistances Expand Parse

$ ...#......
$ .......#..
$ #.........
$ ..........
$ ......#...
$ .#........
$ .........#
$ ..........
$ .......#..
$ #...#.....

⍤⊃⋅∘≍ 374 PartOne
```

## Partie 2

L'univers s'étend plus que prévu. Il ne faut plus remplacer chaque ligne vide par deux, mais par un million de lignes.

C'est là que je regrette d'avoir fait l'expansion sur la forme matricielle.

Qu'à cela ne tienne, refaisons-là sur la liste des coordonnées de galaxies plutôt.

Je devrais pouvoir calculer pour chaque ligne sa nouvelle position dans l'univers : c'est sa position initiale, plus 999999 fois le nombre de lignes vides qui la précédent.

J'arrive à faire ça avec `scan``add` qui transforme `[0 1 0 0 1 0]` en `[0 1 1 1 2 2]`, ce qui est bien le nombre de lignes vides précédant chaque ligne. Plus qu'à multiplier par 999999, puis pour la position actuelle j'ajoute un `range`.

```
[0 1 0 0 1 0]
\+ ≡(¬/↥)
+⇡⧻. ×999999
```

J'applique le même processus à la version transposée de la matrice, pour connaître les décalages de colonnes.

Il faut ensuite transformer les coordonnées des galaxies données par `where` avec ces décalages.

J'obtiens `PartTwo` en combinant tout ça :

```
Parse ← ⊜(=@#)≠@\n.
Distance ← /+⌵-
AllDistances ← ⊠Distance.
SumOfAllDistances ← ÷2/+♭AllDistances

ExpandN ← (
  -1 # on corrige le nombre de lignes à ajouter
  ⊃(
    ⋅⊚ # on trouve les coordonnées de galaxies
  | ⊙∘ # on copie la matrice
  | ⊙⍉ # et sa version transposée
  )
  # pour chaque version de la matrice
  ⊙∩(
    ⊙(\+ ≡(¬/↥)) # on combien de lignes vides précédent chaque ligne
    +⇡⧻. ×       # on en déduit les nouvelles coordonnées
    ¤            # fixé pour l'itération qui suit
  )
  # puis on transforme les coordonnées
  ≡(
    ⍜°⊟ ⊃(
      ⊡ ⊙⋅∘  # aller chercher le nouveau numéro de ligne
    | ⊡ ⋅⊙⋅∘ # et le numéro de colonne
    )
  )
)

PartTwo ← SumOfAllDistances ExpandN ⊙Parse

$ ...#......
$ .......#..
$ #.........
$ ..........
$ ......#...
$ .#........
$ .........#
$ ..........
$ .......#..
$ #...#.....

⍤⊃⋅∘≍ 1030 PartTwo 10
```

### Il y avait plus simple…

En réfléchissant un peu plus, je me dis qu'il y a peut-être une relation mathématique entre le résultat de la partie 1 et celui de la partie 2. Il ne s'agit pas simplement de multiplier par un million, mais chaque ligne ou colonne qui a compté double (à cause de l'expansion de l'univers) dans le premier parcours devrait compter un million de fois dans la deuxième partie.

Pour savoir combien de lignes et colonnes ont été comptées deux fois, on peut calculer la somme des distances sur un univers sans expansion et soustraire ça du résultat de la partie 1.

On obtient ensuite le résultat de la partie 2 en multipliant cette différence par `999999`, et en ajoutant les distances dans l'univers non étendu !

```
Parse ← ⊜(=@#)≠@\n.
Expand ← ⍥(⍉ ▽ +1 ⊃≡(¬/↥)∘)2
Distance ← /+⌵-
SumOfAllDistances ← ÷2/+♭⊠Distance.⊚
PartOne ← SumOfAllDistances Expand Parse
PartTwo ← + ⊙×: ⊙(⊃∘- ∩SumOfAllDistances ⊃∘Expand Parse) -1

$ ...#......
$ .......#..
$ #.........
$ ..........
$ ......#...
$ .#........
$ .........#
$ ..........
$ .......#..
$ #...#.....

⍤⊃⋅∘≍ 374 PartOne .
⍤⊃⋅∘≍ 1030 PartTwo 10 .
⍤⊃⋅∘≍ 8410 PartTwo 100
```

##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) 11 [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
