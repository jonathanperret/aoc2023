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

L'entrée ne comporte pas de grilles beaucoup plus grosses que l'exemple : `17x17` caraactères au maximum. Et il y en a `100`.

On dirait que pour cette première partie en tout cas, essayer toutes les possibilités est jouable.

Pour accélérer un peu les choses, je pourrais chercher les occurences de paires ? D'après l'énoncé, l'axe de symétrie se trouve toujours entre deux lignes ou deux colonnes, donc je trouverai toujours deux lignes ou deux colonnes identiques.

En appliquant ce test sur toute l'entrée, je vois qu'il ne reste qu'un maximum de `4` axes candidats par grille.

Ah, pour comparer plus rapidement les lignes entre elles, je les convertis en entiers avec `un``bits` :

```
ParseGrid ← ⊜(=@#)≠@\n.

$ #...##..#
$ #....#..#
$ ..##..###
$ #####.##.
$ #####.##.
$ ..##..###
$ #....#..#
ParseGrid
°⋯
```

Pour trouver une paire de lignes identiques, je compare les éléments consécutifs avec `windows`.


TODO

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

Du coup j'énumère les scores possibles d'une grille avec toutes les permutations de bit possibles, j'utilise `deduplicate` pour trouver les scores distincts, et j'élimie le score obtenu sans permutation de bit.

Je tombe sur des erreurs étranges.
