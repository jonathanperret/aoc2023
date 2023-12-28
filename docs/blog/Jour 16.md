# Jour 16

## Partie 1

Encore des miroirs !

```no_run
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
```

Un rayon entre dans cette grille de miroirs en haut à gauche en allant vers la droite. Il rebondit en tournant à 90 degrés sur les miroirs `\` et `/`.

Les `-` et `|` sont des _splitters_. Quand un rayon rencontre le côté "pointu" d'un splitter, il ne se passe rien (le rayon le traverse comme si c'était du vide) mais quand le rayon arrive sur le côté "plat", le rayon se partage en deux dans les directions indiquées par les "pointes" du splitter.

La première question est : avec ce rayon entrant en haut à gauche, combien de cases finissent par voir passer un rayon? Avec un petit indice sur le programme de la deuxième partie, puisqu'on me dit que le rayon actuel n'éclaire pas assez de cases…

Alors, lecture de la grille… Ah flûte, il faut échapper ces `\`.

```
Parse ← ⊜∘≠@\n.

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....

Parse
```

Ensuite j'imagine qu'on va suivre le parcours du rayon ?

Cette suggestion sur la partie 2 ne me sort pas de la tête… Par exemple, s'il s'agit de suivre plusieurs rayons à la fois, et sur une grille plus grande (l'entrée fait `110x110` cases), peut-être que j'aurais intérêt à prendre une approche où je parcours toutes les cases de la grille pour faire avancer tous les éventuels rayons qui la parcourent simultanément. Je viens d'ailleurs de réaliser que grâce aux splitters je vais déjà avoir plusieurs rayons qui parcourent la grille…

Si je veux prendre cette approche "cellule", combien d'états peuvent cohabiter dans une cellule ? Il ne suffit pas de savoir qu'elle est parcourue par un rayon, il faut aussi connaître les directions dans laquelle chacun des rayons qui la traversent se déplacent. Ou plutôt, lesquelles des `4` directions possibles sont utilisées.

Ensuite, pour mettre à jour une cellule, je peux collecter les directions des rayons y entrant, et appliquer des règles en fonction du type de la cellule :
* Pour une cellule vide (`.`), les directions sortantes sont les directions entrantes.
* Pour un miroir `/`, `bas` (venant du haut, donc) devient `gauche`, `gauche` (venant de droite) devient `bas`, `haut` (venant du bas) devient `droite`, et `droite` (venant de gauche) devient `haut` ;
* Pour un miroir `\`, `bas` (venant du haut, donc) devient `droite`, `droite` (venant de gauche) devient `bas`, `haut` (venant du bas) devient `gauche`, et `droite` (venant de gauche) devient `bas` ;
* Pour un splitter horizontal `-`, `droite` et `gauche` restent inchangées, `haut` et `bas` deviennent `gauche` et `droite` ;
* Pour un splitter vertical `|`, `droite` et `gauche` deviennent `haut` et `bas`, `haut` et `bas` restent inchangées.

Pour la représentation de l'état des cellules, j'envisage plusieurs binaires matrices superposées. Par exemple une matrice contenant un `1` pour toutes les cellules dont sort un rayon allant vers le `haut`, et ainsi de suite.

Si je considère ma matrice de rayons `haut`, en la décalant vers le haut (probablement avec un `fill``rotate`) j'obtiens une matrice avec un `1` pour les cellules où un rayon entre vers le `haut`. Je peux ensuite appliquer les règles de transformation pour obtenir `4` nouvelles matrices :
* Les cellules `.` et `|` auront une copie de la matrice `haut` dans la nouvelle matrice `haut`, `0` dans les autres ;
* Les cellules `\` auront une copie de la matrice `haut` dans la nouvelle matrice `gauche`, et un `0` dans les autres ;
* Les cellules `/` auront une copie de la matrice `haut` dans la nouvelle matrice `droite`, et un `0` dans les autres ;
* Les cellules `-` auront une copie de la matrice `haut` dans les nouvelles matrice `droite` et `gauche`, et un `0` dans les autres.

Si je répète la même opération avec les `4` matrices correspondant aux `4` directions (peut-être avec des `under` bien sentis), j'obtiendrai donc `4` nouvelles matrices par direction, que je pourrai fusionner entre elles avec un `OU` (`maximum` en Uiua), et je serai ainsi prêt pour l'itération suivante. Je pourrai arrêter d'itérer quand une nouvelle matrice sera identique à la précédente.

Hmm, ça paraît pas mal de travail quand même. Mais l'alternative évidente qui serait de maintenir une liste des rayons en train de traverser la grille promet d'être compliquée aussi : il faudrait quand même se souvenir de l'état des cellules pour éviter de continuer à simuler un rayon qui a déjà été parcouru (je soupçonne qu'il y ait une possibilité de boucle infinie de rayons).

Au boulot, donc.

Pour que mes nombreuses opérations sur les matrices soient efficaces, il faut que je m'appuie sur les opérations _pervasives_ de Uiua, c'est-à-dire que les opérations mathématiques comme `maximum` appliquées à deux matrices s'appliquent automatiquement (et efficacement) élément par élément :

```
[0_1_0_1
 1_0_1_0
 0_1_0_1
 1_0_1_0]
[1_0_1_0
 0_1_0_1
 1_0_1_0
 0_1_0_1]
↥
```

Si j'arrive à exprimer les règles ci-dessus en termes d'une seule cellule mais en n'utilisant que des opérations pervasives, ça devrait être efficace. Ce que je veux éviter à tout prix c'est d'avoir à utiliser `each` ou `rows` et d'écrire naïvement une fonction avec des branchements.

Zoomons donc sur une cellule et exprimons son nouvel état `haut` en fonction de :
* l'état `haut` de sa voisine du dessous ;
* la nature de la cellule.

Pour la nature de la cellule, afin de pouvoir écrire une formule purement "mathématique", j'ai besoin de la transformer en quelque chose de numérique. Ce qui me vient en tête c'est d'avoir une valeur binaire par catégorie : donc `.` serait `[1 0 0 0 0]`, `\` serait `[0 1 0 0 0]`, `/` serait `[0 0 1 0 0]` et ainsi de suite. C'est assez facile de construire ces matrices à partir de la grille de départ avec un "simple" `=` pervasif :

```
Parse ← ⊜∘≠@\n.

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....
Parse

= "./\\-|" ¤
```

Ici grâce à `fix` j'ai demandé à Uiua d'exécuter un `=` entre chaque caractère successivement de `"./\\-|"` et la grille, ce qui me donne autant de matrices qu'il y a de caractères dans `"./\\-|"`, donc `5` matrices apparaissant comme les lignes d'un nouveau tableau. Sans le `fix` la comparaison aurait été rejetée parce que les deux tableaux n'ont pas la même taille.

Voilà, je crois que j'ai toutes les variables nécessaires pour écrire mes équations. Si je note par exemple `╱` la variable indiquant si la cellule est de nature `/` (et ainsi de suite), `h` celle qui indique si un rayon allant vers le haut y entre (`g`, `b`, `d` pour les autres directions), et `h'` (etc.) celle qui dit si un rayon doit en sortir vers le haut, j'obtiens les équations suivantes :
* `h' = (h ∧ (· ∨ │)) ∨ (g ∧ ╲) ∨ (d ∧ ╱) ∨ (b ∧ ─)`
* `g' = (g ∧ (· ∨ ─)) ∨ (h ∧ ╲) ∨ (b ∧ ╱) ∨ (d ∧ │)`
* `b' = (b ∧ (· ∨ │)) ∨ (d ∧ ╲) ∨ (g ∧ ╱) ∨ (h ∧ ─)`
* `d' = (d ∧ (· ∨ ─)) ∨ (b ∧ ╲) ∨ (h ∧ ╱) ∨ (g ∧ │)`

Hmm, ces équations se ressemblent beaucoup dans la forme, et je sens que ça va être plus simple à implémenter si je trouve la forme commune. Je commence par développer un peu :
* `h' = (h ∧ ·) ∨ (h ∧ │) ∨ (g ∧ ╲) ∨ (d ∧ ╱) ∨ (b ∧ ─)`
* `g' = (g ∧ ·) ∨ (g ∧ ─) ∨ (h ∧ ╲) ∨ (b ∧ ╱) ∨ (d ∧ │)`
* `b' = (b ∧ ·) ∨ (b ∧ │) ∨ (d ∧ ╲) ∨ (g ∧ ╱) ∨ (h ∧ ─)`
* `d' = (d ∧ ·) ∨ (d ∨ ─) ∨ (b ∧ ╲) ∨ (h ∧ ╱) ∨ (g ∧ │)`

Puis je réordonne les symboles :
* `h' = (h ∧ ·) ∨ (d ∧ ╱) ∨ (g ∧ ╲) ∨ (h ∧ │) ∨ (b ∧ ─)`
* `g' = (g ∧ ·) ∨ (b ∧ ╱) ∨ (h ∧ ╲) ∨ (d ∧ │) ∨ (g ∧ ─)`
* `b' = (b ∧ ·) ∨ (g ∧ ╱) ∨ (d ∧ ╲) ∨ (b ∧ │) ∨ (h ∧ ─)`
* `d' = (d ∧ ·) ∨ (h ∧ ╱) ∨ (b ∧ ╲) ∨ (g ∧ │) ∨ (d ∨ ─)`

Ah, maintenant je peux exprimer chaque équation en utilisant une fonction :
* `f(x,y,z,u,v) = (x ∧ ·) ∨ (y ∧ ╱) ∨ (z ∧ ╲) ∨ (u ∧ │) ∨ (v ∧ ─)`
* `h' = f(h,d,g,h,b)`
* `g' = f(g,b,h,d,g)`
* `b' = f(b,g,d,b,h)`
* `d' = f(d,h,b,g,d)`

Chacune des équations se ramène donc à une sélection de `h g b d` puis l'application d'une fonction.

Bon, heureusement que Uiua est un langage dans lequel il est particulièrement facile d'écrire des expressions mathématiques à plusieurs variables… non ?

Si j'ai sur la pile `x y z u v · ╱ ╲ │ ─` alors je peux implémenter l'équation pour `f`. Pour m'aider, je mets sur la pile des caractères correspondant aux noms des variables, et j'utilise des _output comments_ pour visualiser à chaque étape que je récupère bien les entrées que je veux.

Je remarque aussi que je peux extraire un _helper_ que je nomme `TopAndSixth` consistant à extraire la première et la sixième valeur sur la pile.

Finalement ce n'est pas si douloureux :

```
# f(x,y,z,u,v) = (x ∧ ·) ∨ (y ∧ ╱) ∨ (z ∧ ╲) ∨ (u ∧ │) ∨ (v ∧ ─)
@x @y @z @u @v @· @╱ @╲ @│ @─
TopAndSixth ← ⊃(∘|⋅⋅⋅⋅⋅∘)
⊃(
  # x ∧ ·
  ↧TopAndSixth
  ### @y
  ### @x
| # y ∧ ╱
  ↧⋅TopAndSixth
  ### @z
  ### @y
| # z ∧ ╲
  ↧⋅⋅TopAndSixth
  ### @u
  ### @z
| # u ∧ │
  ↧⋅⋅⋅TopAndSixth
  ### @v
  ### @u
| # v ∧ ─
  ↧⋅⋅⋅⋅TopAndSixth
  ### @v
)
↥↥↥↥
```

Ensuite je peux exprimer la préparation de `h g b d` nécessaire avant d'appeler `F` pour obtenir `h'`, que j'appelle `SwizzleH`. Je découvre une autre astuce : créer des fonctions nommées pour accéder à différentes profondeurs sur la pile.

```
H ← ∘
G ← ⋅∘
B ← ⋅⋅∘
D ← ⋅⋅⋅∘

SwizzleH ← ⊃(H|D|G|H|B)
SwizzleG ← ⊃(G|B|H|D|G)
SwizzleB ← ⊃(B|G|D|B|H)
SwizzleD ← ⊃(D|H|B|G|D)

# `h' = f(h,d,g,h,b)`
⍤⊃⋅∘≍ "hdghb" [⊙⊙⊙⊙∘] SwizzleH @h @g @b @d

# `g' = f(g,b,h,d,g)`
⍤⊃⋅∘≍ "gbhdg" [⊙⊙⊙⊙∘] SwizzleG @h @g @b @d

# `b' = f(b,g,d,b,h)`
⍤⊃⋅∘≍ "bgdbh" [⊙⊙⊙⊙∘] SwizzleB @h @g @b @d

# `d' = f(d,h,b,g,d)`
⍤⊃⋅∘≍ "dhbgd" [⊙⊙⊙⊙∘] SwizzleD @h @g @b @d
```

Enfin, je peux appeler `F` sur chacune des quatres combinaisons de `h g b d` et rassembler tout ça :

```
TopAndSixth ← ⊃(∘|⋅⋅⋅⋅⋅∘)
F ← ↥↥↥↥ ⊃(↧TopAndSixth|↧⋅TopAndSixth|↧⋅⋅TopAndSixth|↧⋅⋅⋅TopAndSixth|↧⋅⋅⋅⋅TopAndSixth)
H ← ∘
G ← ⋅∘
B ← ⋅⋅∘
D ← ⋅⋅⋅∘
SwizzleH ← ⊃(H|D|G|H|B)
SwizzleG ← ⊃(G|B|H|D|G)
SwizzleB ← ⊃(B|G|D|B|H)
SwizzleD ← ⊃(D|H|B|G|D)

Bounce ← ⊃(F SwizzleH|F SwizzleG|F SwizzleB|F SwizzleD)
```

J'écris une série de tests pour vérifier le fonctionnement de cette nouvelle fonction. Ça se passe plutôt bien… jusqu'à ce que je me rende compte que je me suis trompé dans les équations : j'ai traité `│` et `─` comme des miroirs et non des splitters. Bref, retour aux équations.

* `h' = (h ∧ (· ∨ │)) ∨ (g ∧ (╲ ∨ │)) ∨ (d ∧ (╱ ∨ │))`
* `g' = (g ∧ (· ∨ ─)) ∨ (h ∧ (╲ ∨ ─)) ∨ (b ∧ (╱ ∨ ─))`
* `b' = (b ∧ (· ∨ │)) ∨ (d ∧ (╲ ∨ │)) ∨ (g ∧ (╱ ∨ │))`
* `d' = (d ∧ (· ∨ ─)) ∨ (b ∧ (╲ ∨ ─)) ∨ (h ∧ (╱ ∨ ─))`

* `h' = (h ∧ A) ∨ (g ∧ B) ∨ (d ∧ C)`
* `g' = (g ∧ D) ∨ (h ∧ E) ∨ (b ∧ F)`
* `b' = (b ∧ A) ∨ (d ∧ B) ∨ (g ∧ C)`
* `d' = (d ∧ D) ∨ (b ∧ E) ∨ (h ∧ F)`

Je remarque que `─` n'apparaît pas dans l'expression de `h'`. Ça reflète (haha) le fait qu'aucun rayon ne peut repartir vers le haut d'un splitter horizontal.

Je développe :

* `h' = (h ∧ ·) ∨ (h ∧ │) ∨ (g ∧ ╲) ∨ (g ∧ │) ∨ (d ∧ ╱) ∨ (d ∧ │)`
* `g' = (g ∧ ·) ∨ (g ∧ ─) ∨ (h ∧ ╲) ∨ (h ∧ ─) ∨ (b ∧ ╱) ∨ (b ∧ ─)`
* `b' = (b ∧ ·) ∨ (b ∧ │) ∨ (d ∧ ╲) ∨ (d ∧ │) ∨ (g ∧ ╱) ∨ (g ∧ │)`
* `d' = (d ∧ ·) ∨ (d ∧ ─) ∨ (b ∧ ╲) ∨ (b ∧ ─) ∨ (h ∧ ╱) ∨ (h ∧ ─)`

Je réordonne :

* `h' = (h ∧ ·) ∨ (d ∧ ╱) ∨ (g ∧ ╲) ∨ (h ∧ │) ∨ (g ∧ │) ∨ (d ∧ │)`
* `g' = (g ∧ ·) ∨ (b ∧ ╱) ∨ (h ∧ ╲) ∨ (g ∧ ─) ∨ (h ∧ ─) ∨ (b ∧ ─)`
* `b' = (b ∧ ·) ∨ (g ∧ ╱) ∨ (d ∧ ╲) ∨ (b ∧ │) ∨ (d ∧ │) ∨ (g ∧ │)`
* `d' = (d ∧ ·) ∨ (h ∧ ╱) ∨ (b ∧ ╲) ∨ (d ∧ ─) ∨ (b ∧ ─) ∨ (h ∧ ─)`

Je refactorise :

* `h' = (h ∧ ·) ∨ (d ∧ ╱) ∨ (g ∧ ╲) ∨ ((h ∨ d ∨ g) ∧ │)`
* `g' = (g ∧ ·) ∨ (b ∧ ╱) ∨ (h ∧ ╲) ∨ ((g ∨ b ∨ h) ∧ ─)`
* `b' = (b ∧ ·) ∨ (g ∧ ╱) ∨ (d ∧ ╲) ∨ ((b ∨ g ∨ d) ∧ │)`
* `d' = (d ∧ ·) ∨ (h ∧ ╱) ∨ (b ∧ ╲) ∨ ((d ∨ h ∨ b) ∧ ─)`

La nouvelle formule commune prend maintenant aussi `│` ou `─` :

* `f(x, y, z, t, ·, ╱, ╲) = (x ∧ ·) ∨ (y ∧ ╱) ∨ (z ∧ ╲) ∨ ((x ∨ y ∨ z) ∧ t)`
* `h' = f(h, d, g, │, ·, ╱, ╲)`
* `g' = f(g, b, h, ─, ·, ╱, ╲)`
* `b' = f(b, g, d, │, ·, ╱, ╲)`
* `d' = f(d, h, b, ─, ·, ╱, ╲)`

La nouvelle `F` :

```
TopAndFifth ← ⊃(∘|⋅⋅⋅⋅∘)

# f(x,y,z,t) = (x ∧ ·) ∨ (y ∧ ╱) ∨ (z ∧ ╲) ∨ ((x ∨ y ∨ z) ∧ t)`
@x @y @z @t @· @╱ @╲
⊃(
  # (x ∧ ·)
  TopAndFifth
  ### @·
  ### @x
  ↧
| # (y ∧ ╱)
  ⋅TopAndFifth
  ### @╱
  ### @y
  ↧
| # (z ∧ ╲)
  ⋅⋅TopAndFifth
  ### @╲
  ### @z
  ↧
| # ((x ∨ y ∨ z) ∧ t)`
  ##### @t
  ##### @z
  ##### @y
  ##### @x
  ↥↥
  ### @t
  ### @z
  ↧
)
↥↥↥
### @z
```

Je refais les _swizzles_ :

```
H ← ∘
G ← ⋅∘
B ← ⋅⋅∘
D ← ⋅⋅⋅∘

SwizzleH ← ⊃(H|D|G|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleG ← ⊃(G|B|H|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))
SwizzleB ← ⊃(B|G|D|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleD ← ⊃(D|H|B|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))

# h' = f(h, d, g, │, ·, ╱, ╲)
⍤⊃⋅∘≍ "hdg│•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleH @h @g @b @d @• @╱ @╲ @│ @─

# g' = f(g, b, h, ─, ·, ╱, ╲)
⍤⊃⋅∘≍ "gbh─•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleG @h @g @b @d @• @╱ @╲ @│ @─

# b' = f(b, g, d, │, ·, ╱, ╲)
⍤⊃⋅∘≍ "bgd│•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleB @h @g @b @d @• @╱ @╲ @│ @─

# d' = f(d, h, b, ─, ·, ╱, ╲)
⍤⊃⋅∘≍ "dhb─•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleD @h @g @b @d @• @╱ @╲ @│ @─
```

Et la bonne nouvelle, c'est que `Bounce` et tous les tests que j'avais déjà écrits pour celle-ci, fonctionnent sans modification.

Ouf, c'était long déjà. Mais je me sens armé pour… bientôt finir la première partie ?

Si je me remémore mon plan, il me reste à extraire les fameuses valeurs `h`, `g`, `b` et `d` pour une matrice donnée.

Ou plutôt, j'ai déjà quatre matrices `hgbd` indiquant les rayons sortant des cellules. Ce que je veux c'est obtenir les quatre matrices correspondant aux rayons entrants.

Si un rayon dirigé vers le haut (`h`) sort de la cellule en ligne `4` colonne `2` par exemple, alors un rayon `h` entre dans la cellule en ligne `3` colonne `2`. Globalement, je peux prendre la matrice des rayons `h` sortants et la décaler d'une ligne vers le haut pour obtenir celle des rayons `h` entrants. Ça se fait facilement avec `rotate`, assorti d'un `fill` pour remplir la dernière ligne de `0` :

```
ShiftH ← ⬚0↻1
[0_0_0_0
 0_1_0_0
 0_0_1_0]

ShiftH
```

Pour la gauche c'est similaire — heureusement `rotate` accepte un vecteur comme `0_1` pour faire un décalage de colonnes :

```
ShiftG ← ⬚0↻0_1
[0_0_0_0
 0_1_0_0
 0_0_1_0]

ShiftG
```

Pour la droite et le bas, je passe des décalages négatifs à `rotate` :

```
ShiftD ← ⬚0↻0_¯1
[0_0_0_0
 0_1_0_0
 0_0_1_0]

ShiftD
```

```
ShiftB ← ⬚0↻¯1
[0_0_0_0
 0_1_0_0
 0_0_1_0]

ShiftB
```

Donc, si j'ai mes 4 matrices `hbgd` sur la pile, je devrais pouvoir les transformer en enchaînant ces fonctions avec `bracket` :

```
ShiftH ← ⬚0↻1
ShiftG ← ⬚0↻0_1
ShiftB ← ⬚0↻¯1
ShiftD ← ⬚0↻0_¯1

ShiftHGBD ← ⊓(ShiftH|ShiftG|ShiftB|ShiftD)
[0_0_0_0
 0_1_0_0
 0_0_1_0]
[1_0_0_0
 0_0_0_0
 0_0_0_1]
[0_1_0_0
 1_0_0_0
 0_1_0_0]
[1_0_0_0
 0_0_0_1
 1_0_0_0]
ShiftHGBD
```

Il me reste à initialiser ces matrices. Elles sont toutes de la même taille que l'entrée. Je peux commencer par en créer quatre remplies de zéros, puis ajouter un `1` en haut à gauche de la matrice `d`.

```
Parse ← (
  ⊜∘≠@\n.
  = "./\\-|" ¤
  °[⊙⊙⊙⊙∘]
)
SetupHGBD ← (
  ⊃(...×0|∘)
  ⊙⊙⊙(⍜(⊡0_0)⋅1)
)
$ ...../
$ ..-.-/
$ ..|...
$ ...//.
Parse
SetupHGBD
```

Tiens, l'énoncé dit que le rayon "entre dans le coin supérieur gauche de la gauche", je suppose que ça veut dire qu'il vient bien de l'extérieur de la grille, et non de la cellule en haut à gauche elle-même. Dans l'exemple ça ne changerait rien puisqu'on a un `.` en haut à gauche. Mais dans mon entrée complète j'ai un `\` en haut à gauche ! Je reste relativement confiant dans mon interprétation.

Pour finir, elle ressemble à quoi mon itération ?

Je dois décaler les quatre matrices avec `ShiftHGBD`, puis appliquer les réflections avec `Bounce`.

Ah, et je ne dois pas oublier de préserver les rayons existants ! Une fois qu'un rayon a traversé une cellule il y est pour toujours.

Je fais quelques essais sur l'exemple et les rayons prennent des directions inattendues. Je prends le temps de me construire des fonctions pour visualiser le trajet des rayons.

Je finis par comprendre que j'ai inversé `─` et `│` dans `Parse`…

Une fois que c'est corrigé, je peux itérer sur l'exemple et j'obtiens bien une stabilisation au bout d'une vingtaine de cycles. Avec le bon nombre de cellules "énergisées", joie.

Il me reste à coder la détection de stabilité comme condition d'arrêt de l'itération, mais aussi le cqs de l'entrée du rayon. En effet, ma fonction `SetupHGBD` telle que je l'ai écrite ne fait pas quelque chose de correct : comme mes matrices `hgbd` décrivent les rayons _sortants_ des cellules, il est incorrect de commencer avec un `1` dans la cellule en haut à gauche.

Je peux arranger ça en commençant au milieu de la transformation : ces matrices avec un `1` en haut à gauche de `d`, ce sont les matrices décrivant les rayons entrants, soit ce qui sort de `ShiftHGBD` en temps normal.

Encore pas mal de tâtonnements pour faire marcher ça, mais je finis par y arriver.

Le passage au `do` est relativement aisé par comparaison : je conserve sur la pile le nombre de cases énergisées, et la condition pour continuer est que le nouveau nombre de cases soit différent du précédent.

J'exécute tout ça sur l'entrée complète et j'ai ma réponse. Ça prend quand même plusieurs secondes, ce qui me déçoit et m'inquiète pour la suite…

```
Parse ← (
  ⊜∘≠@\n.
  = "./\\|-" ¤
  °[⊙⊙⊙⊙∘]
)
DropHGBD ← ;;;;
KeepHGBD ← ⊙⊙⊙∘
DropMirrors ← ;;;;;
KeepMirrors ← ⊙⊙⊙⊙∘
KeepAll ← ⊙⊙⊙⊙KeepMirrors
DropAll ← DropHGBD DropMirrors

H ← ∘
G ← ⋅∘
B ← ⋅⋅∘
D ← ⋅⋅⋅∘
TopAndFifth ← ⊃(∘|⋅⋅⋅⋅∘)

F ← ↥↥↥ ⊃(↧ TopAndFifth|↧⋅TopAndFifth|↧⋅⋅TopAndFifth|↧↥↥)
SwizzleH ← ⊃(H|D|G|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleG ← ⊃(G|B|H|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))
SwizzleB ← ⊃(B|G|D|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleD ← ⊃(D|H|B|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))

Bounce ← ⊃(F SwizzleH|F SwizzleG|F SwizzleB|F SwizzleD)

ShiftH ← ⬚0↻1
ShiftG ← ⬚0↻0_1
ShiftB ← ⬚0↻¯1
ShiftD ← ⬚0↻0_¯1
ShiftHGBD ← ⊓(ShiftH|ShiftG|ShiftB|ShiftD)
SetupHGBD ← (
  ⊃(...×0|∘)
  ⊙⊙⊙(⍜(⊡0_0)⋅1)
)
OrHGBD ← ⊃(
  ↥TopAndFifth
| ↥⋅TopAndFifth
| ↥⋅⋅TopAndFifth
| ↥⋅⋅⋅TopAndFifth
)
Step ← (
  ⊃(Bounce ShiftHGBD|KeepAll)
  OrHGBD
)
Energized ← ↥↥↥
Count ← /+♭
FirstStep ← (
  SetupHGBD
  ⊃(Bounce|⋅⋅⋅⋅KeepMirrors)
)
SignatureHGBD ← +∩(+∩Count)
RepeatToEnd ← (
  ¯1
  0
  ⍢(
    ⊙;
    ⊙Step
    ⊙⊃(SignatureHGBD|KeepHGBD)
    :
  )(
    ≠
  )
  ;;
  ⊃(Count Energized|KeepHGBD)

  ⊙(&gifs 30 ≡(▽↯⧻,:⍉▽↯⧻,,:10))
)
PartOne ← (
  Parse
  FirstStep
  RepeatToEnd
  ⊙DropAll
)

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....
⍤⊃⋅∘≍ 46 PartOne
```

## Partie 2

Envoyer un rayon vers la droite en haut à gauche, ça illumine `7477` cellules sur les `110*110 = 12100` que compte la grille. Mais apparemment ce n'est pas suffisant.

On me demande d'essayer d'envoyer un rayon depuis toutes les "entrées" de la grille, c'est-à-dire vers le bas et vers le haut dans chaque colonne, et vers la droite et vers la gauche dans chaque ligne.

Je n'ai pas beaucoup de code à ajouter pour faire tourner ma solution à la première partie sur toutes ces possibilités. Je paramétrise bien sûr la fonction `SetupHGBD`, et du coup celles qui l'appellent.

Ensuite plus qu'à traiter les quatre bords de la grille.

Une utilisation rigolote de `range` à noter : quand on lui passe un entier `n`, bien sûr elle génère les entiers de `0` à `n-1` inclus. Mais si on lui passe un tableau comme par exemple `[4 5]`, elle génère un tableau de `4` lignes et `5` colonnes, dont chaque case contient elle-même un tableau contenant ses coordonnées, de `[0 0]` en haut à gauche à `[1 2]` en bas à droite.

```
⇡ [4 5]
≡≡□ # je mets les paires en boîte pour que ça soit plus clair
```

Du coup si je veux énumérer les coordonnées de la ligne du haut de ma grille, je peux utiliser `shape` pour obtenir ses dimensions (`[10 10]`) puis `range` et enfin `first` pour extraire la première ligne de ce tableau de coordonnées. De même pour la dernière ligne, la première colonne et la dernière colonne.

Je lance donc le calcul sur ces `440` possibilités et je vais faire autre chose. Au bout d'un quart d'heure environ, j'ai une réponse. Elle est correcte, mais je ne suis pas très satisfait…

Dans l'espoir d'utiliser un peu plus les capacités de calcul de mon ordinateur j'utilise `spawn` pour tester chaque possibilité sur un thread séparé. Effectivement, ça divise le temps par `4` environ, ça valait le coup.

Avec le recul, j'aurais certainement mieux fait de partir sur une solution qui suive chaque rayon (avec des optimisations pour éviter de refaire le même travail plusieurs fois ou même à l'infini). Mais je suis quand même content d'être allé au bout de mon idée.

### Surprise de dernière minute

Alors que je m'apprêtais à poser ce problème pour de bon, en essayant d'ajouter une petite visualisation animée je me suis rendu compte que j'exécutais beaucoup plus d'itérations que nécessaire, parce que je comparais le nombre de cases allumées au nombres d'étapes exécutées (qui n'a aucun intérêt en fait).

Je tente une première correction en arrêtant la boucle dès que le nombre de cases allumées cesse d'augmenter, mais un test qui échoue m'indique que ce n'est pas correct. En effet, un rayon peut entrer dans une case déjà allumée par un autre rayon (qui allait dans une autre direction) et donc ne pas augmenter le nombre de cases allumées, mais ce même rayon peut ensuite aller allumer d'autres cases. Je crée donc la fonction `SignatureHGBD` qui me donne le nombre total de cases à `1` dans les quatre matrices directionnelles. Si ce nombre ne bouge plus alors je suis sûr d'être arrivé au bout.

Les performances sont nettement améliorées : pour la partie 1 on passe de 6 secondes à moins d'une seconde.

Pour la partie 2, avec le parallélisme en threads, on descend à 30 secondes au lieu de 4 minutes. C'est agréable mais on n'arrive quand même pas à quelque chose de compétitif (apparemment les solutions à base de rayons individuels calculent la partie 2 en quelques secondes à peine).


```
Parse ← (
  ⊜∘≠@\n.
  = "./\\|-" ¤
  °[⊙⊙⊙⊙∘]
)
DropHGBD ← ;;;;
KeepHGBD ← ⊙⊙⊙∘
DropMirrors ← ;;;;;
KeepMirrors ← ⊙⊙⊙⊙∘
KeepAll ← ⊙⊙⊙⊙KeepMirrors
DropAll ← DropHGBD DropMirrors
FixMirrors ← ⊙∩∩¤ ¤

H ← ∘
G ← ⋅∘
B ← ⋅⋅∘
D ← ⋅⋅⋅∘

TopAndFifth ← ⊃(∘|⋅⋅⋅⋅∘)

F ← ↥↥↥ ⊃(↧ TopAndFifth|↧⋅TopAndFifth|↧⋅⋅TopAndFifth|↧↥↥)
SwizzleH ← ⊃(H|D|G|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleG ← ⊃(G|B|H|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))
SwizzleB ← ⊃(B|G|D|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleD ← ⊃(D|H|B|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))

Bounce ← ⊃(F SwizzleH|F SwizzleG|F SwizzleB|F SwizzleD)

ShiftH ← ⬚0↻1
ShiftG ← ⬚0↻0_1
ShiftB ← ⬚0↻¯1
ShiftD ← ⬚0↻0_¯1
ShiftHGBD ← ⊓(ShiftH|ShiftG|ShiftB|ShiftD)
SetupHGBDAt ← (
  ⊙(
    ⊃(...×0|∘)
    [KeepHGBD]
  )
  ⍜⊡ (⋅1)
  °[KeepHGBD]
)
SetupHGBD ← (
  SetupHGBDAt 3_0_0
)
OrHGBD ← ⊃(
  ↥TopAndFifth
| ↥⋅TopAndFifth
| ↥⋅⋅TopAndFifth
| ↥⋅⋅⋅TopAndFifth
)
Step ← (
  ⊃(Bounce ShiftHGBD|KeepAll)
  OrHGBD
)
Energized ← ↥↥↥
Count ← /+♭
FirstStepAt ← (
  SetupHGBDAt
  ⊃(Bounce|⋅⋅⋅⋅KeepMirrors)
)
FirstStep ← FirstStepAt 3_0_0
RepeatToEnd ← (
  ¤.
  0
  ⍢(
    ⊓(+1|∘|Step)
    ⊙⊃(
      ⊙Energized
      ⊂
    | ⋅KeepHGBD
    )
  )(
    ⊙⋅(Count Energized)
    ≠
  )
  ⊙(&gifs 30 ≡(▽↯⧻,:⍉▽↯⧻,,:10))
)
Solve ← (
  RepeatToEnd
  ⊙DropAll
)
SolveAt ← (
  FirstStepAt
  Solve
)
PartTwo ← (
  Parse
  ⊃(⇡△|FixMirrors)
  [
    ⊃(
      # from top
      ⊢
      ≡(⊂ 2)
    | # from bottom
      ⊢⇌
      ≡(⊂ 0)
    | # from left
      ⍉⊢⍉
      ≡(⊂ 3)
    | # from right
      ⍉⊢⇌⍉
      ≡(⊂ 1)
    )  ]
  ☇ 1
  ≡(spawn SolveAt)
  wait
  /↥♭
)

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....
⍤⊃⋅∘≍ 51 PartTwo
```

##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) 16 [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
