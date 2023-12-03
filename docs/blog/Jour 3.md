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

Lines ← ⊕□⍜▽¯:\+.=, @\n
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
[0_0_0_0
 0_0_0_0
 0_1_0_0
 0_0_0_0
 0_0_0_0]
≡↻ [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]
] ¤
```

Noter l'utilisation de `fix` avec `rows` pour répéter le même tableau cible comme deuxième argument de `rotate`.

Maintenant je veux fusionner ces 8 matrices décalées, j'utilise `reduce` avec `maximum` et j'appelle le tout `Neighbors` :

```
Neighbors = /+≡↻ [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]
] ¤

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
Neighbors = /+≡↻ [ [¯1 ¯1] [¯1 0] [¯1 1] [0 ¯1] [1 0] [1 ¯1] [0 1] [1 1] ] ¤

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
Neighbors ← /↥≡(UnGrow ↻ ⊙Grow) [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]] ¤

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]
Neighbors
```

Mais comme je suis joueur, j'aimerais pouvoir exprimer ça en utilisant `under`. `under` est un super modificateur dans Uiua qui permet justement d'exprimer le genre d'opération où on vuet appliquer une transformation, faire un traitement puis appliquer la transformation inverse.

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

Neighbors ← /↥≡(⍜Grow (↻:)) : [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]] ¤

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]

Neighbors
```

J'ai dû permuter les arguments avec `:` pour que `Grow` soit bien appliqué à la matrice cible et non à ma liste de décalages, mais je suis quand même content du résultat.

Bon, après avoir vu d'autres solutions Uiua, j'ai appris qu'il y avait plus simple. Si on modifie `rotate` avec `fill`, alors les lignes ou colonnes décalées ne sont plus reportées de haut en bas ou de droite à gauche, mais un remplissage est fait avec la valeur indiquée. En bref ça fait ce que je voulais :

```
Neighbors ← /↥≡⬚0↻ [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]] ¤

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
".12.34."

∊:"0123456789".
```

Puis utiliser `partition`, on a l'habitude maintenant :

```
".12.34.56."

⊜parse ∊:"0123456789".
```

C'est sympa mais il faut que je sache lesquels de ces nombres recouvrent mon masque de voisinage.

L'astuce à laquelle j'ai pensée, c'est que je peux utiliser le masque des chiffres, soit `0_1_1_0_1_1_0_1_1_0` pour la chaîne `".12.34.56."`, pour partitionner non pas la chaîne mais le masque des voisins (ici `1_1_1_0_0_1_0_0_0_0`). J'isolerai ainsi trois groupes : `1_1`, `0_1` et `0_0`. Chacun de ces groupes est de la même longueur que le nombre correspondant, et représente un masque qui m'indique pour chaque chiffre s'il est voisin d'un symbole.

Je peux ensuite faire un `ET` logique sur chaque groupe avec un classique `reduce` de `minimum`, que je passe directemnt comme fonction à `partition` :

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
KeepNumbers ← ▽⊃(⊜/↥|⊜parse;:)∊:"0123456789",

KeepNumbers 1_1_1_0_0_1_0_0_0_0 ".12.34.56."
```

Plus qu'à appliquer `KeepNumbers` ligne à ligne entre la matrice des voisins (obtenue avec `Neighbors FindSymbols`) et la matrice d'origine, grâce à `rows`.

Mais attention, chaque ligne peut contenir un nombre différent de nombres, donc `rows` va râler si on lui demande de construire un tableau où la première ligne a 3 éléments mais la deuxième en a 2, par exemple. Je pourrais utiliser `box` comme je l'ai déjà fait précédemment pour contourner ce problème, mais ça me donnerait un tableau de boîtes, ce qui est moins pratique pour ce que je vais vouloir faire ensuite.

Au lieu de `box` j'utilise donc à nouveau `fill`, qui résoud le problème en complétant les lignes trop courtes.

```
# Experimental!

Lines ← ⊕□⍜▽¯:\+.=, @\n
Parse ← ≡⊔Lines
FindSymbols ← ¬∊: "0123456789."

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Neighbors ← /↥≡(⍜(⊙Grow)↻) [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]] ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜parse;:)∊:"0123456789",

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
Parse ← ≡⊔Lines
FindSymbols ← ¬∊: "0123456789."

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Neighbors ← /↥≡(⍜(⊙Grow)↻) [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]] ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜parse;:)∊:"0123456789",

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

PartOne
```

