## Partie 1

Des pierres à déplacer pour focaliser un miroir (encore !) parabolique…

On a donc une plate-forme avec des pierres rondes qui roulent (`O`), des pierres carrées qui ne bougents pas (`#`), et des espaces vides (`.`) :

```no_run
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
```

On va jouer à pencher la plate-forme. Pour le moment (c'est que la partie 1, quand même), on ne la penche que vers le Nord. Les pierres qui roulent se déplacent jusqu'à ne plus pouvoir bouger. Et il faut ensuite faire un calcul en fonction de leurs positions.

La "vraie" plate-forme fait `100x100` cases.

Lecture de l'entrée, on sépare juste les lignes :

```
Parse = ⊜∘ ≠@\n.

$ O....#....
$ O.OO#....#
$ .....##...
$ OO.#O....O
$ .O.....O#.
$ O.#..O.#.#
$ ..O..#O..O
$ .......O..
$ #....###..
$ #OO..#....
Parse
```

Ensuite, quelle est la position finale de chaque `O` ? Je pense que c'est la position du dernier `#` qui le précède (je peux ajouter une rangée de `#` au début pour éviter le cas particulier), plus le nombre de `O` entre lui et ce `#`.

Ah, mais si je partage chaque colonne en groupes séparés par les `#`, il me suffirait de trier les intervalles pour avoir tous les `O` avant les `.`. Je n'ai pas besoin d'ajouter des `#` en haut, d'ailleurs.

D'abord je vais transposer la matrice avec `transpose` pour que les colonnes deviennent des lignes. Puis je pourrai utiliser `under``partition` qui me permettra de travailler sur les intervalles entre les `#`, puis reconstituera la ligne originale en réinsérant les `#`.

J'arrive à ça :

```
Parse = ⊜∘ ≠@\n.

RollRowLeft ← ⍜⊜□≡⍜°□(⊏⍖.) ≠@#.

$ O.#..O.#.#
RollRowLeft
## "O.#O...#.#"
;

RollNorth ← ⍜⍉ ⍉≡RollRowLeft⍉

$ O....#....
$ O.OO#....#
$ .....##...
$ OO.#O....O
$ .O.....O#.
$ O.#..O.#.#
$ ..O..#O..O
$ .......O..
$ #....###..
$ #OO..#....

Parse
RollNorth
```

Voilà qui me paraît sympathique. Plus qu'à calculer le score de cette nouvelle grille.

Un `O` sur la ligne du bas vaut `1`, et ça augmente en remontant.

Un coup de `reverse``range`, `multiply` et `reduce``add` et on arrive à `PartOne` :

```
Parse ← ⊜∘ ≠@\n.
RollRowLeft ← ⍜⊜□≡⍜°□(⊏⍖.) ≠@#.
RollNorth ← ⍜⍉ ≡RollRowLeft
CountOs ← ≡(/+=@O)
RowWeights ← +1⇌⇡⧻
ScoreGrid ← /+× ⊃RowWeights CountOs
PartOne ← (
  Parse
  RollNorth
  ScoreGrid
)

$ O....#....
$ O.OO#....#
$ .....##...
$ OO.#O....O
$ .O.....O#.
$ O.#..O.#.#
$ ..O..#O..O
$ .......O..
$ #....###..
$ #OO..#....

⍤⊃⋅∘≍ 136 PartOne
```

## Partie 2

Il faut maintenant savoir faire pencher la grille dans les quatre directions. Pas vraiment une surprise.

Mais une fois qu'on sait faire un cycle "Nord, Ouest, Sud, Est", il faut répéter ce cycle *un milliard de fois*. Et enfin donner le score de la grille résultante.

Cette fois je ne vais pas me faire avoir à réfléchir comme le jour 8. Je vais juste afficher les scores sur les premiers cycles et constater une période. Enfin j'espère.

D'abord il faut pencher dans les autres directions. Ça devrait être raisonnablement facile à coup de `transpose` et `reverse`. À chaque fois, j'applique ça avec `under` pour redresser la grille après l'opération. Ce n'est pas très efficace, je ferais mieux de garder la grille tournée à chaque étape, mais j'aime vraiment bien `under`.

Voici donc `Spin` :

```
RollRowLeft ← ⍜⊜□≡⍜°□(⊏⍖.) ≠@#.
RollNorth ← ⍜⍉ ≡RollRowLeft
RollWest ← ⍜(⍉⇌)RollNorth
RollSouth ← ⍜(≡⇌⇌)RollNorth
RollEast ← ⍜(⇌⍉)RollNorth
Spin ← (
  RollNorth
  RollWest
  RollSouth
  RollEast
)

["O....#...."
 "O.OO#....#"
 ".....##..."
 "OO.#O....O"
 ".O.....O#."
 "O.#..O.#.#"
 "..O..#O..O"
 ".......O.."
 "#....###.."
 "#OO..#...."]

Spin
```

Ça tourne bien comme dans l'exemple donné. Plus qu'à faire ça un milliard de fois…

J'écris donc `Loop` qui accumule les `n` premiers scores dans un tableau :

```
RollRowLeft ← ⍜⊜□≡⍜°□(⊏⍖.) ≠@#.
RollNorth ← ⍜⍉ ≡RollRowLeft
RollWest ← ⍜(⍉⇌)RollNorth
RollSouth ← ⍜(≡⇌⇌)RollNorth
RollEast ← ⍜(⇌⍉)RollNorth
Spin ← (RollEast RollSouth RollWest RollNorth)
CountOs ← ≡(/+=@O)
RowWeights ← +1⇌⇡⧻
ScoreGrid ← /+× ⊃RowWeights CountOs

Loop ← (
  ⊃(⊙∘|⋅ScoreGrid)
  ;⍥(
    Spin
    ⊃(∘|⊂:ScoreGrid)
  )
)

["O....#...."
 "O.OO#....#"
 ".....##..."
 "OO.#O....O"
 ".O.....O#."
 "O.#..O.#.#"
 "..O..#O..O"
 ".......O.."
 "#....###.."
 "#OO..#...."]
Loop 30
```

Je lui fais calculer les `1000` premiers sur l'entrée complète, au hasard. Déjà, vu le temps que ça prend, je ne vais pas aller au milliard, mais ça je le savais déjà.

Ça me fait des grands nombres, pas facile à différencier : `102449 101575 101554 101559 101711 101898 101991 102153 102343 102446…`

J'applique `classify` pour ramener ça dans un intervalle plus raisonnable : `0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 72 73 74 75 76 77 78 78 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177…`.

Rien qu'en voyant qu'on ne dépasse jamais `200` dans les `1000` premiers éléments, je me doute qu'un cycle est bien là.

Mais pour que ce soit plus visible, je remplace ces nombres sans âme par quelque chose de plus… imagé :

```
[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59
 60 61 62 63 64 65 66 67 68 69 70 71 72 72 73 74 75 76 77 78
 78 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96
 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116
 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136
 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156
 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176
 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181
 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174
 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179
 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185
 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177
 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183
 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176
 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181
 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174
 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179
 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185
 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177
 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181 182 183
 184 185 186 174 175 176 173 177 178 179 180 181 182 183 184 185 186 174 175 176
 173 177 178 179 180 181 182 183 184 185 186 174 175 176 173 177 178 179 180 181]

&p +65536 +@\uf300
```

Là, c'est nettement plus clair.

À ce stade, je pourrais me contenter de faire le calcul à la main mais si je voulais automatiser la résolution ?

Je cherche deux nombres qui sont : la longueur du cycle (période), et le décalage initial (nombre d'éléments à passer avant d'entrer dans un cycle).

Si je regarde ma liste en partant de la fin, je peux me considérer qu'on est dans le cycle. Si je prends le dernier élément, ici `🎵`, et que je remonte jusqu'à son avant-dernière occurrence, j'ai un bon candidat pour la longueur du cycle.

Attention, le cycle peut contenir des répétitions, parce que ce qu'on regarde ce sont les scores de grilles et non les versions distinctes de grilles (différentes grilles peuvent avoir le même score). Dans l'exemple, les premiers éléments donnent `🌀🌁🌂🌂🌂🌃🌄🌃🌅🌆🌂🌂🌃🌄🌃🌅🌆🌂🌂🌃🌄🌃…`. Donc si je n'ai pas de chance, ma liste des `n` premières valeurs pourrait se terminer par `🌂🌂` ou encore `🌃🌄🌃` et je risquerais de penser que le cycle est de longueur `1` ou `2`.

Après un coup d'œil à la "vraie" séquence, je décide d'ignorer cette possibilité. Mais finalement, en écrivant l'implémentation, je réalise qu'il y a aussi simple et plus robuste comme approche : si au lieu de chercher (en partant de la fin) le dernier élément avec `indexof`, je cherche une séquence de plusieurs éléments, disons `10`, avec `find` ? Si le cycle est d'une longueur supérieure à `10`, je connaîtrai sa longueur en regardant la position de la prochaine occurrence de la séquence recherchée. Mais si le cycle fait plus de `10` éléments, je vais rater le début du cycle non ? Oui mais ce n'est pas grave, je vais quand même trouver une séquence qui se répète et ce n'est pas grave si cette séquence a des répétitions à l'intérieur d'elle-même (par exemple, je trouverai `🌅🌆🌂🌂🌃🌄🌃🌅🌆🌂🌂🌃🌄🌃` comme cycle au lieu de `🌅🌆🌂🌂🌃🌄🌃`). Tant que la longueur de séquence utilisée pour la recherche (`10` éléments) ne dépasse pas la moitié de la longueur de la partie "cyclique" de mon échantillon (ici, ça a l'air de commencer à se répéter au bout de `200` éléments à vue d'œil, donc on est large), ça va bien se passer. Et on élimine virtuellement le risque d'erreur : il faudrait qu'une série de `10` grilles ait les mêmes scores qu'une autre série de `10` grilles différentes pour qu'on détecte un "faux cycle".

Une autre observation est qu'une fois que j'ai trouvé la longueur de cycle, je n'ai pas besoin de "remonter" la liste pour trouver exactement à partir de quel indice on est dans un cycle. Je peux considérer que mes `n` premiers éléments représentent la séquence de départ, et que le cycle se répète après eux.

Donc, si j'ai un cycle de longueur `k` commençant après les `n` premiers éléments, où en sera-t'on dans le cycle après `N` itérations ? Je dirais… `(N-n) mod k` ?

Vérifions ça : si j'ai un cycle de longueur `3` qui commence après les `10` premiers éléments, l'élément suivant, donc en position `11` si je commence à `1`, doit être le premier du cycle donc d'indice `0`. La formule `(N-n) mod k` donne `1` dans ce cas. Ça ne va pas, il faut enlever `1`. Partons donc sur `(N-n-1) mod k` pour compenser la différence de numérotation, et on verra si ça marche sur l'exemple.

Ça marche, et donc voici `PartTwo` :

```
Parse ← ⊜∘ ≠@\n.
RollRowLeft ← ⍜⊜□≡⍜°□(⊏⍖.) ≠@#.
RollNorth ← ⍜⍉ ≡RollRowLeft
RollWest ← ⍜(⍉⇌)RollNorth
RollSouth ← ⍜(≡⇌⇌)RollNorth
RollEast ← ⍜(⇌⍉)RollNorth
Spin ← (
  RollNorth
  RollWest
  RollSouth
  RollEast
)
CountOs ← ≡(/+=@O)
RowWeights ← +1⇌⇡⧻
ScoreGrid ← /+× ⊃RowWeights CountOs
Loop ← (
  ⊃(⊙∘|⋅(¤ScoreGrid))
  ;⍥(
    Spin
    ⊃(∘|⊂:ScoreGrid)
  )
)
FindCycle ← ⍜⇌(
  ⊃(↙10|∘|∘|∘)
  ¬⌕
  ⊜⧻
  ↙+1⊢
)
ProbeLength ← 300
TargetLength ← 1000000000
PartTwo ← (
  Parse
  Loop ProbeLength
  FindCycle
  ⧻.
  - ProbeLength -1 TargetLength
  ◿:
  ⊡
)

$ O....#....
$ O.OO#....#
$ .....##...
$ OO.#O....O
$ .O.....O#.
$ O.#..O.#.#
$ ..O..#O..O
$ .......O..
$ #....###..
$ #OO..#....

⍤⊃⋅∘≍ 64 PartTwo
```
