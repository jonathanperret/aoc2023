##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) 13 [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 

# Jour 13

## Partie 1

On est sur l'île de Lave, mais il n'y a pas de lave ?

Mais nous voilà dans la _vallée aux miroirs_.

Se présente une série de grilles de la forme :

```no_run
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
```

Il faut trouver un axe de symétrie à cette grille. Sachant qu'il n'est pas nécessairement centré : ici, on a une symétrie selon un axe vertical mais la première colonne n'a pas de réflexion visible.

```no_run
# .##. | .##.
. .#.# | #.#.
# #... | ...#
# #... | ...#
. .#.# | #.#.
. .##. | .##.
# .#.# | #.#.
```

Lecture de l'entrée, je commence à avoir l'habitude :

```
ParseGrid ← ⊜(=@#)≠@\n.
Parse ← ⊜(□ParseGrid)¬⌕ "\n\n".

$ #.##..##.
$ ..#.##.#.
$ ##......#
$ ##......#
$ ..#.##.#.
$ ..##..##.
$ #.#.##.#.
$
$ #...##..#
$ #....#..#
$ ..##..###
$ #####.##.
$ #####.##.
$ ..##..###
$ #....#..#
Parse
```

Sinon, c'est quoi mon plan ?

L'entrée ne comporte pas de grilles beaucoup plus grosses que l'exemple : `17x17` caractères au maximum. Et il y en a `100`.

On dirait que pour cette première partie en tout cas, essayer toutes les possibilités est jouable.

Pour accélérer un peu les choses, je pourrais chercher les occurences de paires ? D'après l'énoncé, l'axe de symétrie se trouve toujours entre deux lignes ou deux colonnes, donc je trouverai toujours deux lignes ou deux colonnes identiques.

En appliquant ce test sur toute l'entrée, je vois qu'il ne reste qu'un maximum de `4` axes candidats par grille.

Ah, pour comparer plus rapidement les lignes entre elles, je les convertis en entiers avec `un``bits` :

```
ParseGrid ← ⊜(=@#)≠@\n.
Numberize ← °⋯

$ #...##..#
$ #....#..#
$ ..##..###
$ #####.##.
$ #####.##.
$ ..##..###
$ #....#..#
ParseGrid
Numberize
```

Et pour trouver une paire de lignes identiques, je regroupe les paires d'éléments consécutifs avec `windows`, je `transpose` la matrice obtenue puis j'applique `reduce``equals` pour comparer les deux lignes obtenues. Enfin `where` me donne les indices où deux nombres identiques se suivent.

Il ne me reste qu'à vérifier chacune de ces positions candidates en extrayant les lignes ou colonnes concernées et en les comparant.

Pour finir, comme indiqué par l'énoncé il faut multiplier par `100` la position d'un axe horizontal éventuel et additionner celle d'un axe vertical.

```
ParseGrid ← ⊜(=@#)≠@\n.
Parse ← ⊜(□ParseGrid)¬⌕ "\n\n".
Numberize ← °⋯
Candidates ← +1⊚/=⍉◫2
TestCandidate ← (
  ⊃(⇌↙|↘)
  ↧⊃(∩△|⊙∘)
  ⊃(⊙∘|⊙⋅∘)
  ∩↯
  ≍
)
FindAxes ← (|1
  Candidates.
  ⊙¤
  .
  :⊙≡TestCandidate
  ([0]|▽)±/+.
)
ScoreGridA ← (|1
  Numberize
  FindAxes
  ×100
)
ScoreGridB ← (|1
  ⍉
  Numberize
  FindAxes
)
ScoreGrid ← (|1
  ScoreGridA.
  :
  ScoreGridB
  ⊂
  ⊝
  ▽ ±.
)
PartOne ← (
  Parse
  ≡(⊢ScoreGrid °□)
  /+
)

$ #.##..##.
$ ..#.##.#.
$ ##......#
$ ##......#
$ ..#.##.#.
$ ..##..##.
$ #.#.##.#.
$
$ #...##..#
$ #....#..#
$ ..##..###
$ #####.##.
$ #####.##.
$ ..##..###
$ #....#..#
⍤⊃⋅∘≍ 405 PartOne
```

## Partie 2

Comme d'habitude, ça se complique. Maintenant, dans chaque grille il faut trouver un unique symbole à permuter pour obtenir une nouvelle grille ayant encore un unique axe de symétrie.

Voyons, la grille la plus grosse fait quelque chose comme `18x18` soit `324` possibilités d'élément à permuter.

Je fais un test rapide : combien de temps ça me prend d'exécuter `300` fois `PartOne` sur l'entrée ? Presque pile une seconde. Bon, je crois qu'on ne va pas se compliquer la vie.

Hmm, ça marche mais j'ai trop d'axes de symétrie.

J'identifie déjà deux cas particuliers :
* s'il suffit de changer un bit pour que deux lignes deviennent identiques, alors changer le bit symétrique a le même résultat ;
* on peut changer tous les bits qu'on veut de lignes qui n'ont pas de symétrique.

Ces multiples ne seraient pas grave s'ils ramenaient toujours au même axe de symétrie, mais…

Ah, bien sûr, la réponse est dans l'énoncé. Il faut que le changement de bit donne une _nouvelle_ ligne de réflexion.

Du coup j'énumère les scores possibles d'une grille avec toutes les permutations de bit possibles, j'utilise `deduplicate` pour trouver les scores distincts, et j'élimine le score obtenu sans permutation de bit.

Ça devrait fonctionner, mais c'est alors que je tombe sur un bug de l'interpréteur Uiua… quand j'écris le code d'une certaine façon, l'interpréteur s'arrête avec une erreur interne. Je finis par essayer une version plus ancienne de l'interpréteur Uiua, qui fonctionne sur mon programme. Je signale ensuite ce bug via Discord au créateur de Uiua qui se penche dessus.

```
ParseGrid ← ⊜(=@#)≠@\n.
Parse ← ⊜(□ParseGrid)¬⌕ "\n\n".
Numberize ← °⋯
Candidates ← +1⊚/=⍉◫2
TestCandidate ← (
  ⊃(⇌↙|↘)
  ↧⊃(∩△|⊙∘)
  ⊃(⊙∘|⊙⋅∘)
  ∩↯
  ≍
)
FindAxes ← (|1
  Candidates.
  ⊙¤
  .
  :⊙≡TestCandidate
  ([0]|▽)±/+.
)
ScoreGridA ← (|1
  Numberize
  FindAxes
  ×100
)
ScoreGridB ← (|1
  ⍉
  Numberize
  FindAxes
)
ScoreGrid ← (|1
  ScoreGridA.
  :
  ScoreGridB
  ⊂
  ⊝
  ▽ ±.
)
FlipBit ← (
  ⊙⊃∘△
  ⊙♭
  ⍜(⊡)¬
  ↯:
)
ScoreSmudged ← (
  ⊃∘(+ScoreGrid)
  /×△.
  ⇡
  ⊙¤
  ≡FlipBit
  ≡(ScoreGrid)
  ⊂
  ▽±.
  ⊝
  :
  ⊙.
  ▽≠
  ⊢
)
PartTwoGrid ← (
  .
  ⊢ScoreGrid
  :
  /×△.
  ⇡
  ⊙¤
  ≡FlipBit
  .
  ≡(□ScoreGridA)
  :
  ≡(□ScoreGridB)
  ⊂
  /⊐⊂
  ▽±.
  ⊝
  :
  ⊙.
  ▽≠
  ⊢
)
PartTwo ← (
  Parse
  ≡(
    °□
    PartTwoGrid
  )
  /+
)

$ #.##..##.
$ ..#.##.#.
$ ##......#
$ ##......#
$ ..#.##.#.
$ ..##..##.
$ #.#.##.#.
$
$ #...##..#
$ #....#..#
$ ..##..###
$ #####.##.
$ #####.##.
$ ..##..###
$ #....#..#
⍤⊃⋅∘≍ 400 PartTwo
```

##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) 13 [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
