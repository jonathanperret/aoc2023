# Jour 3

## Ce que j'ai retenu des épisodes précédents

Il faut que je me calme avec `regex`.

Il faut que je crée plus de petites fonctions nommées plutôt que d'attaquer le problème "de l'extérieur".

## Partie 1

Un moteur d'Elfe à réparer. Typique.

OK, on a une matrice de caractères qui ressemble à ça :

```no_run
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

Au moins, aujourd'hui pas d'excuse de difficulté de _parsing_ ! Après le découpage en lignes il me suffit d'enlever les boîtes superflues (comme toutes les lignes ont la même longueur) avec `un``box` :

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

Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡°□Lines
Parse
```

Il y aurait plus direct sans utiliser ma fonction toute faite `Lines` mais je n'ai pas envie de passer du temps là-dessus.

Ah tiens, j'ai mal lu : il faut trouver des _nombres_ écrits horizontalement (dans l'exemple ils font tous deux ou trois chiffres; je vérifie dans l'entrée et je constate que ça va de un à trois chiffres) qui touchent un symbole, c'est un peu plus compliqué.

Comment faire ? Déjà, je devrais pouvoir facilement, sur une ligne donnée, isoler les nombres. Hmm, si j'ai trouvé les coordonnées d'un nombre dans la matrice (ex. `(3,3)-(4,3)`) je devrais pouvoir agrandir ce rectangle d'une case tout autour (donc `(2,2)-(5,4)`), et vérifier dans cette zone si un symbole est présent.

Je pourrais aussi faire l'inverse : pour chaque symbole trouvé dans la matrice, marquer les 8 cases qui l'entourent. Ensuite un nombre n'est valide que s'il recouvre au moins une case marquée. Cette dernière option me paraît un peu plus simple, alors allons-y.

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡°□Lines

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

Je connais une opération qui permet de "décaler" une matrice, c'est `rotate`. Sur à tableau à une dimension, elle fait une simple "rotation" :

```
↻1 4_5_6
```

Étendu à une matrice 2D, si on lui passe un décalage 2D, ça décale la matrice comme demandé :

```
[0_0_0_0
 0_0_0_0
 0_1_0_0
 0_0_0_0
 0_0_0_0]
↻ 1_1
```

C'est exactement ce qu'il me faut. Il faut juste que je l'applique dans chacune des 8 directions qui m'intéressent :

```
Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
[0_0_0_0
 0_0_0_0
 0_1_0_0
 0_0_0_0
 0_0_0_0]
≡↻ Directions ¤
```

Noter l'utilisation de `fix` avec `rows` pour répéter le même tableau cible comme deuxième argument de `rotate`.

Maintenant je veux fusionner ces 8 matrices décalées, j'utilise `reduce` avec `maximum` et j'appelle le tout `Neighbors` :

```
Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors = /↥ ≡↻ Directions ¤

[0_0_0_0
 0_0_0_0
 0_1_0_0
 0_0_0_0
 0_0_0_0]

Neighbors
```

Parfait, je peux passer à la suite.

Mais je suis pris d'un horrible doute :

```
Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors = /↥ ≡↻ Directions ¤

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]

Neighbors
```

Oh non ! J'ai involontairement joué à Pac-Man et calculé les voisins sur un tore. Zut.

Bon, je sais : je vais entourer la matrice d'une bordure de zéros, appliquer mes rotations, puis enlever la bordure.

Pour ajouter la bordure, je fais des `join` modifiés par un `fill` `0` qui me permet d'ajouter un simple `0` à une liste de lignes, le `fill` le transformera en une liste de `0` de la bonne longueur. La bordure va en haut, en bas, à gauche et à droite :

```
Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]

Grow
```

Pour enlever la bordure, je fais une petite rotation des lignes avec `rotate` qui ramène les deux lignes de bordures en début de tableau, et je les enlève ensuite avec `drop`. Je fais la même chose sur chaque ligne pour enlever les bordures droite et gauche.

```
UnGrow ← ≡(↘2↻¯1)↘2↻¯1

[0_0_0_0_0_0
 0_1_0_0_0_0
 0_0_0_0_0_0
 0_0_0_0_0_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

UnGrow
```

Voilà, je vais pouvoir utiliser ça dans `Neighbors`.

Ça pourrait ressembler à ça :

```
Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥≡ (UnGrow ↻ ⊙Grow) Directions ¤

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]
Neighbors
```

Mais comme je suis joueur, j'aimerais pouvoir exprimer ça en utilisant `under`. `under` est un super modificateur dans Uiua qui permet justement d'exprimer le genre d'opération où on veut appliquer une transformation, faire un traitement puis appliquer la transformation inverse.

Par exemple, si je veux doubler uniquement le premier nombre d'une liste, je peux utiliser `under` avec `first` :

```
⍜⊢(×2) 10_20_30
```

C'est super non ? Ça ne marche pas avec toutes les transformations mais quand ça marche c'est assez élégant je trouve.

Bon, mais justement mon `Grow` est trop compliqué pour que `under` s'en débrouille. Il faudrait lui expliquer que l'inverse de `Grow`, c'est `UnGrow` en fait. Ça tombe bien, le modificateur expérimental `setund` est fait pour ça !

```
# Experimental!

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥≡ (⍜Grow (↻:)) : Directions ¤

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]

Neighbors
```

J'ai dû permuter les arguments avec `:` pour que `Grow` soit bien appliqué à la matrice cible et non à ma liste de décalages, mais je suis quand même content du résultat.

Bon, après avoir vu d'autres solutions Uiua, j'ai appris qu'il y avait plus simple. Si on modifie `rotate` avec `fill`, alors les lignes ou colonnes décalées ne sont plus reportées de haut en bas ou de droite à gauche, mais un remplissage est fait avec la valeur indiquée. En bref ça fait ce que je voulais :

```
Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥ ≡⬚0↻ Directions ¤

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]

Neighbors
```

OK, on identifie maintenant les cases qui sont adjacentes à un symbole.

Il reste à trouver les nombres qui recouvrent au moins une de ces cases.

Pour simplifier, je peux faire ce traitement ligne à ligne. Considérons donc une ligne comme `".12.34.56."` et un masque (obtenu avec `Neighbors`) qui soit par exemple `1_1_1_0_0_1_0_0_0_0`.

Pour isoler les nombres déjà, je peux créer un masque avec `member` qui m'indique où sont les chiffres :
```
".12.34.56."

∊:"0123456789".
```

Puis utiliser `partition`, on a l'habitude maintenant :

```
".12.34.56."

⊜⋕ ∊:"0123456789".
```

C'est sympa mais il faut que je sache lesquels de ces nombres recouvrent mon masque de voisinage.

L'astuce à laquelle j'ai pensé, c'est que je peux utiliser le masque des chiffres, soit `0_1_1_0_1_1_0_1_1_0` pour la chaîne `".12.34.56."`, pour partitionner non pas la chaîne mais le masque des voisins (ici `1_1_1_0_0_1_0_0_0_0`). J'isolerai ainsi trois groupes : `1_1`, `0_1` et `0_0`. Chacun de ces groupes est de la même longueur que le nombre correspondant, et représente un masque qui m'indique pour chaque chiffre s'il est voisin d'un symbole.

Je peux ensuite faire un `OU` logique sur chaque groupe avec un classique `reduce` de `maximum`, que je passe directemnt comme fonction à `partition` :

```
1_1_1_0_0_1_0_0_0_0

∊:"0123456789" ".12.34.56."

⊜/↥
```

J'obtiens bien une liste de `1` et de `0` de la même longueur que la liste de nombres obtenue précédemment. Il me suffit ensuite de filtrer la liste de nombres avec ce masque, ce qui est un travail pour `keep` :

```
[12 34 56]
[1 1 0]
▽
```

Je combine les deux opérations avec `fork`, je saupoudre d'opérateurs de pile comme `over`, `pop` et `flip` pour amener les arguments là où il faut, j'enchaîne avec le `keep` et ça me donne `KeepNumbers` :

```
KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",

KeepNumbers 1_1_1_0_0_1_0_0_0_0 ".12.34.56."
```

Plus qu'à appliquer `KeepNumbers` ligne à ligne entre la matrice des voisins (obtenue avec `Neighbors FindSymbols`) et la matrice d'origine, grâce à `rows`.

Mais attention, chaque ligne peut contenir un nombre différent de nombres, donc `rows` va râler si on lui demande de construire un tableau où la première ligne a 3 éléments mais la deuxième en a 2, par exemple. Je pourrais utiliser `box` comme je l'ai déjà fait précédemment pour contourner ce problème, mais ça me donnerait un tableau de boîtes, ce qui est moins pratique pour ce que je vais vouloir faire ensuite.

Au lieu de `box` j'utilise donc à nouveau `fill`, qui résoud le problème en complétant les lignes trop courtes.

```
# Experimental!

Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡°□Lines
FindSymbols ← ¬∊: "0123456789."

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥≡ (⍜(⊙Grow)↻) Directions ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",

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

⬚0≡KeepNumbers Neighbors FindSymbols .Parse
```

Maintenant que j'ai tous mes nombres dans une matrice (avec quelques `0` en bonus), il faut que je calcule la somme des éléments de celle-ci. Je vais utiliser `deshape` qui "aplatit" complètement une matrice :

```
[12_0
 34_57]
♭
```

Et ensuite le classique `reduce` de  `add` :


```
[12_0
 34_57]
♭
/+
```

On enchaîne tout ça et ça donne enfin `PartOne` :

```
# Experimental!

Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡°□Lines
FindSymbols ← ¬∊: "0123456789."

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥ ≡(⍜(⊙Grow)↻) Directions ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",

PartOne ← (
  Parse
  FindSymbols .
  Neighbors
  ⬚0≡KeepNumbers
  /+♭
)

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

⍤⊃⋅∘≍ 4361 . PartOne
```

## Partie 2

On nous demande maintenant de trouver non pas les nombres voisins d'au moins un symbole, mais les symboles `*` voisins d'exactement deux nombres. Et il faut calculer le produit de ces deux nombres pour chaque `*` concerné, puis faire le total sur tout le tableau.

Je devrais pouvoir réutiliser une bonne partie du code de la partie 1. En particulier, je sais déjà répondre à la question "quels sont les nombres qui couvrent au moins une des positions d'un masque.

Donc, en partant d'une matrice comme celle-ci, qui contient un unique symbole `*` :

```no_run
$ 467..114..
$ ...*......
$ ..35..633.
```

Si j'arrive à construire un masque des cases voisines du `*`, ce que je pourrai probablement faire avec `Neighbors` :

```no_run
[0_0_1_1_1_0_0_0_0_0_0
 0_0_1_0_1_0_0_0_0_0_0
 0_0_1_1_1_0_0_0_0_0_0]
```

Je pourrai appliquer `KeepNumbers` pour identifier que `467` et `35` sont les voisins de ce `*`.

Je commence donc par trouver les `*` dans la matrice, facile. J'appelle ça `FindGears` :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡°□Lines
FindGears ← =@*

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

Parse
FindGears
```

D'accord mais là j'ai les emplacements de tous les `*` alors que je veux les traiter un par un. Autrement dit, il faudrait que j'arrive à "éclater"

```no_run
[0_1_0
 0_0_1
 1_0_0]
```

en

```no_run
[
  [0_1_0
   0_0_0
   0_0_0]
  [0_0_0
   0_0_1
   0_0_0]
  [0_0_0
   0_0_0
   1_0_0]
]
```

Je peux commencer par utiliser `where` qui construit une liste des coordonnées des `1` dans une matrice.

```
[0_1_0
 0_0_1
 1_0_0]
⊚
```

Il faut ensuite que j'arrive à convertir chacune de ces coordonnées en une matrice de la même taille que l'originale, mais avec un `1` dans la cellule en question.

Changer une cellule dans un tableau, c'est quelque chose qui se fait bien avec `under` appliqué à `pick`. En effet `pick` sélectionne une cellule, on la modifie et `under` s'occupe de la réintégrer dans le tableau d'origine.

Par exemple pour doubler la valeur centrale d'une matrice 3x3 :

```
[1_1_1
 1_1_1
 1_1_1]
⍜(⊡ 1_1)(×2)
```

Pour remplacer une cellule par `1`, je peux utiliser `pop` comme ceci : `1;` mais j'aime bien aussi utiliser `gap` qui modifie une fonction pour qu'elle enlève le haut de la pile (comme `pop`) avant de s'appliquer (autrement dit, elle ignore son premier argument). Ici la fonction c'est juste `1`, donc ça donne `⋅1` :

```
0
⋅1
```

Note : si je préfère `⋅1` à `1;`, c'est qu'on peut plus souvent se passer de parenthèses en l'écrivant comme ça : en effet l'application d'un modificateur (comme `⋅`) est prioritaire sur la composition de fonctions. Par exemple si j'écris `≡1;` (enlever le haut de la pile, puis répéter la fonction `1` sur les lignes d'un tableau) ça n'a pas le même sens que `≡(1;)` (pour chaque ligne d'un tableau, dépiler puis appeler `1`). Alors que `≡⋅1`, c'est pareil que `≡(⋅1)`.

Et donc dans `under` `pick` ça donne :

```
[0_0_0
 0_0_0
 0_0_0]
⍜(⊡ 1_1)⋅1
```

On y est presque, il me manque juste une matrice de `0` de la taille de l'originale. Facile, en appliquant `⋅0` à toutes ses cellules :
```
[0_1_0
 0_0_1
 1_0_0]
∵⋅0
```

J'applique d'une part le `where` et d'autre part le remplacement par `0`, avec `fork` :
```
[0_1_0
 0_0_1
 1_0_0]
⊃(⊚|∵⋅0)
```

Ensuite avec `rows` assorti d'un `fix` (plus exactement `dip` `fix` parce qu'à ce moment-là la matrice de zéros est en deuxième position sur la pile), je transforme chaque coordonnée en une matrice contenant un unique `1`. J'appelle ça `SplitMask`.

```
SplitMask = ≡(⍜⊡⋅1)⊃(⊚|∵⋅0¤)
[0_1_0
 0_0_1
 1_0_0]
SplitMask
```

J'ai donc une série de masques correspondant à chacun des symboles `*`.

Étant donné un tel masque je peux construire le masque de ses voisins avec `Neighbors` :

```
# Experimental!
Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥ ≡(⍜(⊙Grow)↻) Directions ¤
[0_1_0
 0_0_0
 0_0_0]
Neighbors
```

Avec ce masque de voisins et la matrice d'origine, je peux utiliser `KeepNumbers` sur chaque ligne, comme dans la partie 1.

Sauf que cette fois, je ne veux pas utiliser `fill` pour régler le problème du nombre variable de nombres sur différentes lignes. Je vais plutôt mettre chaque liste en boîte :

```
KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",

["1.."
 "2.3"
 "789"]

[1_0_1
 1_1_1
 0_0_0]

≡(□KeepNumbers)
```

Et ensuite je rassemble tous ces tableaux contenus dans des boîtes en un seul avec `reduce` `join`. Plus précisément `reduce` `pack` `join`, car le modificateur `pack` permet à `join` de déballer automatiquement les tableaux avant de les concaténer.

```
[□[1] □[2 3] □[]]
/⊐⊂
```

J'appelle cette combinaison `KeepAllNumbers`, parce que je manque d'imagination.

```
KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",
KeepAllNumbers ← /⊐⊂ ≡(□KeepNumbers)

["1.."
 "2.3"
 "789"]

[1_0_1
 1_1_1
 0_0_0]

KeepAllNumbers
```

J'ai maintenant une liste des nombres adjacents à un `*` donné. Je peux calculer le produit des nombres s'ils sont deux, avec une _switch function_ pour retourner `0` si ce n'est pas le cas. J'appelle ça `GearRatio` :

```
GearRatio ← (⋅0|/×) =2 ⧻.

GearRatio []
GearRatio [1]
GearRatio 2_3
GearRatio 4_5_6
```

Il me suffira enfin de faire la somme des produits obtenus pour chaque `*`, avec `reduce` `add`.

Plus qu'à enchaîner tout ça pour obtenir `PartTwo` :

```
# Experimental!

Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡°□Lines
FindGears ← =@*
SplitMask = ≡(⍜⊡⋅1)⊃(⊚|∵⋅0¤)

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥ ≡(⍜(⊙Grow)↻) Directions ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",
KeepAllNumbers ← /⊐⊂ ≡(□KeepNumbers)

GearRatio ← (⋅0|/×) =2 ⧻.

PartTwo ← (
  Parse
  FindGears .
  SplitMask
  ≡(GearRatio KeepAllNumbers Neighbors)⊙¤
  /+
)

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

⍤⊃⋅∘≍ 467835 . PartTwo
```

Et voilà pour la deuxième partie. Quand je lance ce programme sur mon entrée, qui est une matrice de 140x140 caractères contenant 376 occurrences de `*`, je pense d'abord à un bug parce que rien ne s'affiche. Je finis par comprendre que le calcul est simplement long ! Il se termine quand même en moins de 10 secondes, ce qui m'évite d'avoir à mettre en œuvre des optimisations.

Je me dis que si je voulais accélérer le traitement, je pourrais par exemple traiter l'entrée par bloc de 3 lignes, puisque chaque `*` n'a besoin de considérer que les nombres se trouvant sur sa ligne ou celles adjacentes. Mais il y aurait sûrement quelques subtilités !

##### Aller au jour : [1](Jour%201) [2](Jour%202) 3 [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
