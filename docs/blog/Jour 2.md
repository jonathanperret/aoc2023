Où l'on atterrit dans le ciel et on joue aux cubes.

Attention, aujourd'hui je m'y suis pris n'importe comment. Pour la lecture de l'entrée, en tout cas.

## Partie 1

On commence avec une série de lignes qui ressemblent à ceci :

```
$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
```

Cette ligne représente une partie d'un jeu (la partie numéro 1). La partie se compose de trois tours (séparés par des points-virgules), chaque tour indiquant le nombre de cubes de chaque couleur utilisés ce tour. Noter que les couleurs ne sont pas toujours dans le même ordre et ne sont pas toujours toutes mentionnées.

Pour la partie 1, il faut vérifier qu'on n'utilise jamais plus de 12 cubes rouges, 13 cubes verts ou 14 cubes bleus.

Je commence par essayer de séparer la ligne au niveau du caractère `:`.

```
$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
.   # on duplique la ligne
≠@: # on trouve où il y a des caractères ":"
⊜□  # on regroupe dans des boîtes les séquences de caractères différents de ":"
```

Mais je réalise que ça va être laborieux ensuite de traiter cette partie `Game 1` : séparer sur l'espace, lire le nombre, etc. Et ensuite il va falloir stocker ce numéro de partie quelque part, sachant que stocker un nombre et une liste dans la même ligne d'un tableau, ce n'est pas évident avec Uiua : il faudrait tout mettre dans des boîtes…

Du coup je regarde un peu l'entrée et je constate que les numéros de partie correspondent exactement aux numéro de lignes. Je peux donc me passer d'extraire et de stocker ces numéros, que je pourrai retrouver implicitement par la suite en fonction de la position de la partie dans le tableau.

Je commence donc par traiter chaque ligne en enlevant la partie `Game 1: `. Je fais ça en enlevant les 8 premiers caractères :

```
$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
↘8
```

Ce n'est que maintenant en le racontant que je réalise que ça ne marche pas comme il faut avec `Game 10: ` ni `Game 100: ` ! Mais j'ai eu de la chance apparemment, les traitements que je fais après m'ont permis d'ignorer ces caractères superflus.

Bref, une fois que j'ai (à peu près…) isolé la partie droite, je veux la découper selon les points-virgules. Je continue avec `regex`, en isolant les séquences de caractères autres que les points-virgules.

```
$ 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
regex "[^;]+"
```

Sur chaque groupe isolé ainsi, je découpe à nouveau selon les virgules.

```
$ 3 blue, 4 red
regex "[^,]+"
```

Voici où j'en suis, quand je compose les deux découpages :

```
$ 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
regex "[^;]+"         # on découpe selon les points-virgules
≡(□regex "[^,]+" ⊔)   # on sous-découpe selon les virgules
```

La composition est polluée par des `unbox` (`regex` met les différentes chaînes trouvées dans des boîtes, toujours pour les faire cohabiter dans un tableau) et les `box`, encore pour constituer un tableau de résultat.

Ça commence à devenir alambiqué, mais en plus je me rends compte que la sortie n'est même pas encore parfaitement utilisable : il y a des espaces qui se glissent un peu partout comme par exemple dans ` 4 red`.

Mais il faut continuer. Maintenant qu'on a `3 blue` il faut en extraire le nombre `3` et la couleur `blue`. Évidemment, c'est l'occasion de ressortir `regex` !

```
$ 3 blue
regex "\\d+ [rgb]"
```

Avec `\\d+ [rgb]` je ne conserve que le strict minimum : les chiffres du nombre, et la première lettre de la couleur. C'est ici que je me débarrasse donc d'un éventuel espace superflu, ainsi que (à mon insu) du `:` qui avait survécu à ma suppression des 8 premiers caractères de la ligne plus haut.

Je ne suis pas encore sorti d'affaire : non seulement il faut que je sépare le nombre de la couleur, mais surtout il faut que je trouve une façon intelligente de représenter ces paires dans un tableau Uiua. Je pourrais faire des tableaux de boîtes : une première boîte contenant le nombre, et une deuxième contenant la lettre représentant la couleur. Mais je sens bien que ça ne serait pas pratique du tout à traiter par la suite.

Je décide plutôt de faire un peu plus de travail lors de l'analyse, pour avoir des données pratiques pour la suite. Je veux construire pour chaque tour un triplet indiquant le nombre de cubes de chaque couleur, toujours dans l'ordre rouge, vert, bleu. Autrement dit, je veux que `3 blue, 4 red` devienne `[ 4 0 3 ]` (qui peut aussi s'écrire `4_0_3`).

Mais pour l'instant, j'en suis à `{ "3 b" "4 r" }`  : un tableau de boîtes contenant des chaînes.

Je transforme déjà la chaîne `"3 b"` en une paire dont le premier élément sera la lettre, et le deuxième l'entier. J'utilise `fork` pour d'une part isoler le dernier caractère (une simple combinaison de `first` et `reverse`), et d'autre part l'entier obtenu en enlevant les deux dernièrs caractères avec la séquence `⇌↘2⇌` (on retourne, on enlève deux caractères avec `drop`, et on retourne à nouveau) puis en passant le résultat à `parse`.

```
$ 3 b
⊃(⊢⇌|parse⇌↘2⇌)
```

Il faut emballer ces deux valeurs dans un tableau de boîtes, ça peut se faire en mettant toute l'expression entre `{}` :

```
$ 3 b
{ ⊃(⊢⇌|parse⇌↘2⇌) }
```

OK, maintenant on sait transformer la chaîne représentant un tour du jeu (`3 blue, 4 red`) en une liste de paires :

```
$ 3 blue, 4 red
regex "[^,]+"         # on découpe selon les virgules
≡(                    # et pour chaque groupe…
  ⊔                   # on ouvre la boîte
  regex "\\d+ [rgb]"  # on ne conserve que le nombre et la première lettre
  ⊔⊢                  # on prend la première chaîne trouvée par regex, on la déballe
  { ⊃(⊢⇌|parse⇌↘2⇌) } # on extrait la lettre, et le nombre
)
```

Ce n'est toujours pas fini. Dans cette liste, il faut que je trouve le nombre correspondant à `r` (ou `0` s'il n'y a pas de `r`).

Voyons le cas simple où il y a bien un élément `r` :

```
[{ @b 3 } { @r 4 }]
.      # on duplique la liste de paires
≡(⊔⊢⊔) # on extrait la lettre de chaque paire
⊗@r    # on trouve la position du "r"
⊡      # on prend la paire correspondante
⊔⊡1⊔   # on en extrait le nombre associé
```

Et quand il n'y a pas de `r` ? Le code ci-dessus va échouer puisque `indexof` quand il ne trouve pas l'élément recherché, renvoie un indice qui est au-delà de la fin du tableau, donc `pick` déclenche une erreur.

Plutôt que de faire quelque chose d'intelligent, je vais chercher `try` qui permet d'intercepter l'erreur et d'éxécuter une autre fonction dans ce cas. La fonction en question reçoit les arguments passés à la fonction qui a échoué, plus le message d'erreur. Je veux ignorer tout ça et renvoyer `0`, ce pourquoi j'utilise `gap` autant de fois que nécessaire donc `⋅⋅⋅0`. Ça donne cette horreur :

```
[{ @b 3 } { @g 5 }]
.      # on duplique la liste de paires
≡(⊔⊢⊔) # on extrait la lettre de chaque paire
⍣(⊔⊡1⊔⊡⊗@r)(⋅⋅⋅0)
```

Bon, il faut bien sûr faire la même chose avec `g` et `b`, c'est un travail pour `fork` et on met le résultat dans un tableau en entourant de `[]` :

```
[{ @b 3 } { @r 4 }]
[ ⊃(⍣(⊔⊡1⊔⊡⊗@r)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@g)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@b)(⋅⋅⋅0))≡(⊔⊢⊔). ]
```

C'est atroce mais au moins on a le résultat souhaité. Je nomme cette fonction `ExtractRGB` et je décide de ne plus jamais la regarder.

On peut maintenant combiner tout ça pour analyser une partie, j'appelle ça `ParseGame` :

```
ExtractRGB ← [⊃(⍣(⊔⊡1⊔⊡⊗@r)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@g)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@b)(⋅⋅⋅0))≡(⊔⊢⊔).]
ParseGame ← ≡(ExtractRGB≡({⊃(⊢⇌|parse⇌↘2⇌)}⊔⊢regex "\\d+ [rgb]"⊔)regex "[^,]+" ⊔)regex "[^;]+" ↘8

$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
ParseGame
```

Je suis déjà au bout de ma vie mais je n'ai même pas encore calculé le résultat de la première partie.

Heureusement, maintenant ça promet d'être simple. On arrive enfin dans la zone de confort d'un langage comme Uiua.

Pour comparer une liste représentant un tour comme `4_3_20` aux limites qui sont `12_13_14` il suffit d'utiliser `≤` :

```
≤12_13_14 4_3_20
```

Je peux appliquer ça à toutes les lignes d'une partie avec `rows` :

```
[3_4_0 13_12_10 1_3_4]
≡(≤12_13_14)
```

Me voilà avec une matrice de 0 et de 1. Une partie est possible si celle-ci ne contient pas de 0. Je peux vérifier cela en "aplatissant" la matrice avec `deshape`, ce qui en fait une liste de 0 et de 1, puis en cherchant le minimum en combinant `minimum` (qui ne prend que deux arguments) avec `reduce` (qui va appliquer `minimum` successivement à tous les éléments).

```
[3_4_0 13_12_10 1_3_4]
≡(≤12_13_14) # on compare chaque ligne aux limites
⸮
♭            # on aplatit la matrice
⸮
/↧           # on prend le minimum
```

J'appelle cette fonction `IsPossible`.

```
IsPossible ← /↧♭≡(≤12_13_14)

IsPossible [3_4_0 13_12_10 1_3_4]
```

On y est presque pour la partie 1. Je sais déterminer si une partie est possible, je peux donc appliquer ce test à toutes les parties identifiées :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
ExtractRGB ← [⊃(⍣(⊔⊡1⊔⊡⊗@r)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@g)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@b)(⋅⋅⋅0))≡(⊔⊢⊔).]
ParseGame ← ≡(ExtractRGB≡({⊃(⊢⇌|parse⇌↘2⇌)}⊔⊢regex "\\d+ [rgb]"⊔)regex "[^,]+" ⊔)regex "[^;]+" ↘8
Parse ← ≡(□ ParseGame ⊔) Lines
IsPossible ← /↧♭≡(≤12_13_14)

$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
$ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
$ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red

Parse           # on analyse les parties
≡(IsPossible ⊔) # on vérifie si chaque partie est possible
```

Me voilà avec un tableau booléen de la forme `[ 1 1 0 1 0 ]`. L'énoncé demande d'additioner les numéros de parties possibles. Il faut donc que je reconstitue les numéros de partie que j'ai décidé plus haut de rendre implicites.

Je commence par construire avec `range` la liste des _n_ premiers entiers (où _n_ est la longueur du tableau booléen, obtenue avec `length`), augmentés avec `+1` pour commencer à `1`.

```
[ 1 1 0 1 0 ]
.    # on duplique le tableau
⧻    # on prend sa longueur
+1⇡  # on construit la liste des entiers à partir de 1
```

Ensuite je ne veux conserver parmi ces entiers que ceux qui sont en face d'un `1` dans le tableau booléen. La fonction `keep` est faite pour ça, il faut juste permuter ses arguments avec `flip`.

```
[ 1 1 0 1 0 ]
+1⇡⧻. # on construit la liste des entiers à partir de 1
▽:    # on ne garde que les entiers correspondant à un 1
```

Il ne reste qu'à faire la somme avec encore un `reduce` appliqué à `add`, et ça donne `PartOne`.

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
ExtractRGB ← [⊃(⍣(⊔⊡1⊔⊡⊗@r)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@g)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@b)(⋅⋅⋅0))≡(⊔⊢⊔).]
ParseGame ← ≡(ExtractRGB≡({⊃(⊢⇌|parse⇌↘2⇌)}⊔⊢regex "\\d+ [rgb]"⊔)regex "[^,]+" ⊔)regex "[^;]+" ↘8
Parse ← ≡(□ ParseGame ⊔) Lines
IsPossible ← /↧♭≡(≤12_13_14)

PartOne ← /+▽:+1⇡⧻.≡(IsPossible ⊔) Parse

$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
$ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
$ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
$ Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
$ Game 100: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

PartOne
```

Pfouh. Je croise les doigts pour que la deuxième partie ne nécessite pas de modifier `Parse`.

## Partie 2

Il n'est plus demandé de filtrer les parties possibles ou impossibles. Mais de déterminer pour chaque partie, le nombre maximum de cubes utilisés dans chaque couleur.

Autrement dit, pour une partie comme `[4_0_3 1_2_6 0_2_0]` je dois calculer `4_2_6`.

Encore une fois, c'est confortable à faire en Uiua, puisque `maximum` appliquée à deux listes renvoie la liste des plus grandes valeurs élément par élément. Et si on utilise `reduce` on peut appliquer ça à une liste de longueur arbitraire.

```
[4_0_3 1_2_6 0_2_0]
/↥
```

L'énoncé demande qu'on fasse le produit de ces maximums. Facile avec `reduce` encore, appliqué à `multiply`. J'appelle ça `GamePower` :

```
GamePower ← /×/↥

[4_0_3 1_2_6 0_2_0]
GamePower
```

La partie 2 s'exprime donc plus simplement que la partie 1, finalement :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
ExtractRGB ← [⊃(⍣(⊔⊡1⊔⊡⊗@r)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@g)(⋅⋅⋅0)|⍣(⊔⊡1⊔⊡⊗@b)(⋅⋅⋅0))≡(⊔⊢⊔).]
ParseGame ← ≡(ExtractRGB≡({⊃(⊢⇌|parse⇌↘2⇌)}⊔⊢regex "\\d+ [rgb]"⊔)regex "[^,]+" ⊔)regex "[^;]+" ↘8
Parse ← ≡(□ ParseGame ⊔) Lines

GamePower ← /×/↥

PartTwo ← /+≡(GamePower ⊔) Parse

$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
$ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
$ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
$ Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
$ Game 100: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

PartTwo
```

