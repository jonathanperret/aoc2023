## Ce que j'ai retenu des épisodes précédents

Ça n'a pas trop mal marché de rédiger en même temps que je réfléchissais au problème. Quand les jours avancent et que les problèmes se complexifient, il devient de toute façon indispensable de se poser un peu avant de se lancer dans l'implémentation.

Ça ne m'a quand même pas mis à l'abri d'une erreur hier, qui était de construire une structure trop compliquée : j'ai représenté chaque carte par un vecteur de `1` consécutifs alors que j'aurais pu me contenter de stocker la longueur du vecteur, ce qui aurait été plus simple à parcourir dans la suite de l'algorithme. Je crois que j'ai vraiment intérêt à favoriser les structures les plus simples qui soient avec ce langage.

## Partie 1

Je trouve le jardinier. Il manque de sable, apparemment. Mais surtout de nourriture ? En tout cas il a des graines à planter et des sols à fertiliser.

Un exemple d'entrée :

```no_run
$ seeds: 79 14 55 13
$ 
$ seed-to-soil map:
$ 50 98 2
$ 52 50 48
$ 
$ soil-to-fertilizer map:
$ 0 15 37
$ 37 52 2
$ 39 0 15
$ 
$ fertilizer-to-water map:
$ 49 53 8
$ 0 11 42
$ 42 0 7
$ 57 7 4
$ 
$ water-to-light map:
$ 88 18 7
$ 18 25 70
$ 
$ light-to-temperature map:
$ 45 77 23
$ 81 45 19
$ 68 64 13
$ 
$ temperature-to-humidity map:
$ 0 69 1
$ 1 0 69
$ 
$ humidity-to-location map:
$ 60 56 37
$ 56 93 4
```

La première ligne me dit qu'il faut planter les graines (_seeds_) 79, 14, 55 et 13.

Les autres lignes m'indiquent des correspondances entre par exemple les numéros de graines et les numéros de terreau (_soil_), sous la forme d'intervalles : `50 98 2` signifie que l'intervalle de graines de longueur `2` commençant à `98` correspond à l'intervalle de terreau commençant à `50`, autrement dit la graine `98` va avec le terreau `98` et la graine `51` avec le terreau `51`.

On me dit aussi que les numéros qui ne sont pas couverts par un intervalle restent inchangés, donc la graine `10` va avec le terreau `10`.

Très bien, et quelle est la question ?

Pour chacune des graines à planter, je dois traverser les différentes tables de correspondance pour arriver à un numéro d'emplacement (_location_), et retourner le numéro d'emplacement le plus petit qui soit atteint par une de ces graines.

Bon, réfléchissons au problème de _parsing_ pour commencer. Il me semble déjà qu'on peut se passer de lire les lignes introduisant les différentes tables comme `temperature-to-humidity map:`. En effet les tables sont déjà dans la bonne séquence. Je vérifie qu'il en est de même dans l'entrée complète : c'est bien le cas.

J'arrive assez vite à ceci :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
ParseSeeds ← (
  ⊔
  ↘+2⊗@:.
  ⊜parse≠@\s.
)
ParseMap ← (
  ⊔
  ↘1
  ≡(⊜parse ≠@\s. ⊔)
  □
)
ParseMaps ← (
  ≠0≡⧻.
  ⊜□
  ≡ParseMap
)
Parse ← (
  Lines
  ⊃(
    ⊢
    ParseSeeds
  | ↘2
    ParseMaps
  )
)

$ seeds: 79 14 55 13
$ 
$ seed-to-soil map:
$ 50 98 2
$ 52 50 48
$ 
$ soil-to-fertilizer map:
$ 0 15 37
$ 37 52 2
$ 39 0 15

Parse
```

Voilà, on a les données du fichier dans une forme à peu près digeste.

Ensuite, je vais vouloir faire passer chaque numéro de graine à travers les différentes tables de correspondance. Ça prendra bien sûr un `rows` pour itérer sur les graines, et probablement un `fold` pour parcourir les différentes tables.

À l'intérieur d'une table, je veux trouver l'intervalle qui corresponde à mon entrée. Je veux m'arrêter dès que j'ai trouvé un intervalle contenant l'entrée, donc peut-être utiliserai-je un `do` ?

Alternativement, je pourrais construire pour chaque table de correspondance une liste triée des bornes d'intervalles, trouver où se trouve l'entrée, et… non, c'est trop compliqué, restons sur la première idée.

Je n'aurai même pas besoin d'un `do` en fait. Il me suffit de chercher quel intervalle contient la valeur (s'il y en a plusieurs, ce qui ne devrait pas arriver il me semble, je peux prendre le premier qui corresponde) et d'appliquer sa transformation.

Pour simplifier la recherche, je me propose d'ajouter à la fin de chaque table un intervalle très grand ne faisant pas de décalage, donc `0 0 ∞`. Ainsi je suis assuré de toujours trouver un intervalle.

Il me faut donc :
 * une fonction qui prend une valeur (`99`) et une liste d'intervalles et renvoie l'intervalle contenant la valeur.
 * une fonction qui prend une valeur (`99`) et un intervalle (`50 98 2`) et renvoie la valeur convertie (`99`).
 * une fonction qui prend une valeur et une table et convertit la valeur.
 * une fonction qui prend une valeur et plusieurs tables et convertit la valeur.
 * une fonction qui prend plusieurs valeurs, plusieurs tables, et convertit les valeurs.

Voici la première, `FindRange` :

```
FindRange ← (
  ¤ # [99] [52_50_48 50_98_2]
  : # [52_50_48 50_98_2] [99]
  . # [52_50_48 50_98_2] [52_50_48 50_98_2] [99]
  ⊙≡(
    # 52_50_48 99
    ⊃(⊡2|⊡1) # 48 50 99
    ⊙-       # 48 49(99-50)
    ≤        # 0 (49<=48?)
  )
  # [52_50_48 50_98_2] [0 1]
  ▽: # [50_98_2]
  ⊢  # 50_98_2
)
FindRange 99 [52_50_48 50_98_2]
```

Ensuite `ApplyRange` :

```
ApplyRange ← (
  ⊙⊃(⊡1|⊢)
  -:
  +
)

ApplyRange 99 [50 98 2]
```

Voici `ApplyTable` :

```
FindRange ← ⊢ ▽: ⊙≡(≤ ⊙- ⊃(⊡2|⊡1)) . : ¤
ApplyRange ← + -: ⊙⊃(⊡1|⊢)
ApplyTable ← (
  # 99 [52_50_48 50_98_2]
  .          # 99 99 [52_50_48 50_98_2]
  ⊙FindRange # 99 50_98_2
  ApplyRange # 51
)

ApplyTable 99 [52_50_48 50_98_2]
```

Et pour finir `ApplyTables` :

```
FindRange ← ⊢ ▽: ⊙≡(≤ ⊙- ⊃(⊡2|⊡1)) . : ¤
ApplyRange ← + -: ⊙⊃(⊡1|⊢)
ApplyTable ← ApplyRange ⊙FindRange .
ApplyTables ← (
  # 99 {[52_50_48 50_98_2] [0_10_200]}
  :
  # {[52_50_48 50_98_2] [0_10_200]} 99
  ∧(
    # □[52_50_48 50_98_2] 99
    ⊔ # [52_50_48 50_98_2] 99
    : # 99 [52_50_48 50_98_2]
    ApplyTable
  )
)
ApplyTables 99 {[52_50_48 50_98_2] [0_10_200]}
```

J'essaie d'appliquer tout ça à l'entrée d'exemple et ça ne donne pas le résultat attendu : j'ai des nombres négatifs en sortie ! Je creuse un peu et je me rends compte que j'ai oublié une partie de mon test d'intervalle dans `FindRange` : quand la valeur cherchée moins le début de l'intervalle est négative, ce n'est pas le bon intervalle !

J'ajoute ce test :

```
FindRange ← (
  ¤ # [79] [50_98_2 52_50_48]
  : # [50_98_2 52_50_48] [79]
  . # [50_98_2 52_50_48] [50_98_2 52_50_48] [79]
  ⊙≡(
    # 50_98_2 79
    ⊃(⊡2|⊡1) # 2 98 79
    ⊙-       # 2 -19(79-98)
    ⊙.       # 2 -19 -19
    ≤        # 1 (-19<=2?) -19
    ⊙(≥0)    # 1 0
    ↧        # 0 (1 && 0)
  )
  # [52_50_48 50_98_2] [0 1]
  ▽: # [50_98_2]
  ⊢  # 50_98_2
)
```

Et quand j'applique ça sur l'exemple, je tombe sur des erreurs d'intervalles non trouvés. Je ne suis pas surpris parce que je n'ai pas encore ajouté mes intervalles "tampon" `0_0_∞`. J'écris `FixTables` :

```
FixTables ← ≡(
  ⊔
  0_0_∞
  ⊂:
  □
)
```

Pour finir il faut appliquer ça pour chacune des graines, et prendre le minimum des nombres obtenus.

L'enchaînement de tout ça donne `PartOne`:

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
ParseSeeds ← (
  ⊔
  ↘+2⊗@:.
  ⊜parse≠@\s.
)
ParseMap ← (
  ⊔
  ↘1
  ≡(⊜parse ≠@\s. ⊔)
  □
)
ParseMaps ← (
  ≠0≡⧻.
  ⊜□
  ≡ParseMap
)
Parse ← (
  Lines
  ⊃(
    ⊢
    ParseSeeds
  | ↘2
    ParseMaps
  )
)
FixTables ← ≡(
  ⊔
  0_0_∞
  ⊂:
  □
)
FindRange ← (
  ¤ # [79] [50_98_2 52_50_48]
  : # [50_98_2 52_50_48] [79]
  . # [50_98_2 52_50_48] [50_98_2 52_50_48] [79]
  ⊙≡(
    # 50_98_2 79
    ⊃(⊡2|⊡1) # 2 98 79
    ⊙-       # 2 -19(79-98)
    ⊙.       # 2 -19 -19
    ≤        # 1 (-19<=2?) -19
    ⊙(≥0)    # 1 0
    ↧        # 0 (1 && 0)
  )
  # [52_50_48 50_98_2] [0 1]
  ▽: # [50_98_2]
  ⊢  # 50_98_2
)
ApplyRange ← (
  ⊙⊃(⊡1|⊢)
  -:
  +
)
ApplyTable ← (
  # 99 [52_50_48 50_98_2]
  .          # 99 99 [52_50_48 50_98_2]
  ⊙FindRange # 99 50_98_2
  ApplyRange # 51
)
ApplyTables ← (
  # 99 {[52_50_48 50_98_2] [0_10_200]}
  :
  # {[52_50_48 50_98_2] [0_10_200]} 99
  ∧(
    # □[52_50_48 50_98_2] 99
    ⊔ # [52_50_48 50_98_2] 99
    : # 99 [52_50_48 50_98_2]
    ApplyTable
  )
)
MapSeeds ← (
  ⊙FixTables
  ⊙¤
  ≡ApplyTables
)
PartOne ← (
  Parse
  MapSeeds
  /↧
)

$ seeds: 79 14 55 13
$
$ seed-to-soil map:
$ 50 98 2
$ 52 50 48
$
$ soil-to-fertilizer map:
$ 0 15 37
$ 37 52 2
$ 39 0 15
$
$ fertilizer-to-water map:
$ 49 53 8
$ 0 11 42
$ 42 0 7
$ 57 7 4
$
$ water-to-light map:
$ 88 18 7
$ 18 25 70
$
$ light-to-temperature map:
$ 45 77 23
$ 81 45 19
$ 68 64 13
$
$ temperature-to-humidity map:
$ 0 69 1
$ 1 0 69
$
$ humidity-to-location map:
$ 60 56 37
$ 56 93 4

PartOne

⍤⊃⋅∘≍ 35
```

C'était long quand même pour une première partie. Voyons la suite.

## Partie 2

Ouille. Maintenant il faut interpréter la liste des graines au début, `79 14 55 13`, doit être interprétée comme une liste d'intervalles, soit `14` valeurs en partant de `79` puis `13` valeurs en partant de `55`. Dans l'exemple, cela fait donc `27` valeurs de graine à tester.

Et la question reste la même, quel est la valeur la plus petite atteinte par une de ces graines.

A priori il est très facile de construire la liste des graines à partir de ces intervalles. Mais autant transformer 27 nombres à travers les tables est simple, autant si je regarde mon entrée… rien que le premier intervalle de graines est `364807853 408612163`,  soit un peu plus de 43 millions de valeurs !

Clairement, il faut trouver une stratégie moins naïve.

Plusieurs idées me viennent en tête, qui pourraient éventuellement se combiner :
* Appliquer les tables non plus à des valeurs individuelles mais à des intervalles.
* Combiner plusieurs tables en une seule.
* Partir de la dernière table et remonter ?

Pour cette première piste de transformation d'intervalles, la difficulté que je vois est qu'un intervalle transformé par une table ne reste pas nécessairement un intervalle, mais plutôt une collection d'intervalles. Qui ne seront même pas nécessairement disjoints d'ailleurs — il faudrait potentiellement en fusionner certains.

### Une représentation compacte des collections d'intervalles ?

Ça me fait repenser à mon idée abandonnée plus tôt de représentation alternative pour une collection d'intervalles : une liste de bornes, associées chacune à une information valable à partir de cette borne, par exemple "dedans/dehors".

Par exemple à partir de la paire d'intervalles `79,14 55,13` on construirait la liste `0 55 68 79 93` associée à la liste `0_1_0_1_0` qui s'interpréterait ainsi : à partir de `55`, on est "dedans" (`1`), mais à partir de `68` on est "dehors" (`0`), et ainsi de suite.

Pour représenter une table de correspondance, au lieu d'associer des valeurs `0` et `1` pour "dehors" et "dedans" on pourrait stocker le décalage à appliquer. Donc par exemple cette table :

```no_run
[52_50_48 50_98_2]
```

Deviendrait cette paire de listes :

```no_run
[ 0 50  98 100 ]
[ 0  2 ¯48   0 ]
```

Je me dis qu'une telle représentation simplifierait peut-être les opérations de comparaison et de fusion d'intervalles que je vais avoir à faire.

Je garde cette idée au chaud, mais pour l'instant j'ai envie de faire une petite évaluation du volume de données à potentiellement traiter.

### Il est gros comment le problème au juste ?

Je commence par regarder combien de lignes chaque table possède avec :

```no_run
≡⧻;Parse &fras "day5.txt"
# [24 31 10 27 11 13 8]
```

Supposons que je commence avec un intervalle suffisamment grand pour contenir tous les intervalles de la première table. Celle-ci contient `24` lignes dans mon entrée. Mon intervalle de départ pourrait donc se transformer en un maximum de `24` nouveaux intervalles.

Pour chacun de ceux-ci, la deuxième table qui a `31` lignes pourrait donc en introduire `31` nouveaux. Et ainsi de suite.

Or, le produit des tailles des tables est quand même `229806720` ! Bien sûr, j'ai peu de chances d'arriver à ce cas qui est le pire, mais ça fait réfléchir quand même.

Est-ce que je pourrais purger la liste des intervalles au fur et à mesure ? Certains se fusionneront certainement, mais je n'ai aucune garantie que cela réduise suffisamment le nombre d'intervalles à conserver. Et je ne peux pas simplement ignorer les intervalles "élevés" sous prétexte que je cherche le minimum à la fin, puisqu'un intervalle "élevé" peut très bien être ramené à plus petit par une table suivante.

Ce calcul me fait réaliser aussi que fusionner les tables de correspondance ne serait probablement pas une bonne idée, la table résultante serait énorme.

Il ne me reste donc qu'une seule idée à explorer : peut-on prendre le problème "à l'envers", c'est-à-dire en cherchant pour une table donnée quels intervalles donneraient les plus petites valeurs possibles en sortie ?

Si je reprends l'exemple, voici la dernière table :

```no_run
$ humidity-to-location map:
$ 60 56 37
$ 56 93 4
```

Je vais faire une hypothèse qui n'est pas explicite dans l'énoncé mais qui me paraît raisonnable : tous les nombres que l'on manipule sont des entiers non négatifs.

La plus petite valeur que je puisse espérer obtenir est donc `0`.

Si par exemple je voulais obtenir `0` en sortie de la table ci-dessus, que faudrait-il passer en entrée ?

`0` lui-même se transformera en `0` puisqu'il n'appartient à aucun des intervalles mentionnés. Mais d'autres valeurs peuvent-elles mener à `0` ? Non, car le premier intervalle (`60 56 37`) ajoute `4` (`60 - 56`) aux valeurs comprises entre `56` et `56 + 37`. Et le deuxième (`56 93 4`) enlève `37` (`93 - 56`) aux valeurs entre `93` et `93 + 4`.

Toutes les valeurs inférieures à `56` ne peuvent être obtenues que par identité. Mais `56` peut aussi être obtenu en passant `93`.

Je pourrais commencer par un intervalle pour lequel j'espère trouver une graine source, par exemple `0…55`, faire la transformation inverse qui me donnerait les intervalles sources susceptibles de générer une valeur dans cet intervalle, et remonter la liste des tables ainsi. Mais comme remonter chaque table va multiplier le nombre d'intervalles à suivre, j'aurai le même problème qu'en prenant le problème "à l'endroit" ! Hmm.

### Quelques particularités des données d'entrée

Tiens, une observation intéressante : dans l'entrée complète, chaque table ne contient que des intervalles d'entrée consécutifs. Et à l'exception de la dernière table, il y a toujours un intervalle qui commence à zéro.

Les intervalles de sortie sont également consécutifs !

### Compression d'intervalles : un nouvel espoir ?

Je continue de chercher. À un moment, je crois avoir trouvé la solution : si j'arrive à énumérer tous les "points" auxquels des intervalles peuvent être coupés, je pourrai "compresser" les intervalles en ne gardant qu'un seul élément comme représentant de chacun de ces intervalles, ce qui me permettrait de réutiliser le code de la partie 1 puisqu'il n'y aurait plus qu'un petit nombre d'éléments à tester.

Je crois tellement à cette piste que j'écris une implémentation complète, qui commence par calculer tous les points de rupture possibles en cherchant le début et la fin de tous les intervalles dans les données en entrée. Puis je trie ces points (il y en a environ 250) et je les renumérote de façon à avoir le même problème mais avec des nombres qui vont de 0 à 250 au lieu d'aller de 0 à quelques milliards, ce qui rend une énumération des graines tout à fait faisable. Je suis assez content de cette implémentation et je soumets la réponse qu'elle me donne… qui est fausse, malheureusement.

### Pause

Après une longue pause avec entre les mains un guidon au lieu d'un clavier, je m'y remets. Pendant cette pause j'ai encore réfléchi, bien sûr.

J'ai compris déjà pourquoi mon idée de compression des intervalles ne fonctionnait pas. Les points que j'avais énuméré dans l'entrée ne suffisent pas , car ils vont être transformés et se multiplier au fil du passage par les différentes tables de conversion. Bref, mauvaise piste.

L'illumination qui m'est venue en fin de trajet, c'est que j'ai largement surestimé le nombre d'intervalles que je devrais manipuler si j'appliquais "simplement" les tables pour les transformer. Oui, appliquer une table découpant l'entrée en 10 intervalles peut transformer un intervalle en 10 intervalles. Mais dans l'hypothèse où la collection d'intervalles en entrée ne contient pas de recouvrement (ce que j'ai constaté dans l'entrée, mais que j'aurais pu sinon garantir en fusionnant les intervalles se recouvrant entre chaque application de table), une table à 10 lignes ne va pas multiplier par 10 le nombre d'intervalles de la collection à laquelle elle est appliquée ! Plus précisément, si une table découpe la ligne des réels en 10 parties, elle ne peut ajouter qu'un maximum de 10 intervalles à cette collection.

Une façon imagée de le voir est avec un cake : si j'ai découpé un cake en 3 parts, chaque coup de couteau supplémentaire (tant qu'ils sont parallèles, on n'est pas chez les sauvages) ne peut ajouter qu'une part.

Bref, au lieu de m'inquiéter j'aurais mieux fait de partir directement sur la solution avec les intervalles. Comme quoi il est possible de trop réfléchir.

### Et c'est reparti

Maintenant que je suis confiant sur le fait que j'ai la bonne piste, il ne reste plus qu'à coder des intersections d'intervalles en Uiua…

À ce stade, je n'ai plus trop l'énergie pour détailler l'écriture de cette implémentation, donc désolé, voici juste le résultat :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n

ParseSeeds ← (
  ⊔
  ↘+2⊗@:.
  ⊜parse≠@\s.
)
ParseMap ← (
  ⊔
  ↘1
  ≡(⊜parse ≠@\s. ⊔)
  □
)
ParseMaps ← (
  ≠0≡⧻.
  ⊜□
  ≡ParseMap
)
Parse ← (
  Lines
  ⊃(
    ⊢
    ParseSeeds
  | ↘2
    ParseMaps
  )
)

LeftSegment ← (
  ⊃(
    ⊢ # start of left ⇡
  | ⊓(
      /+ # end of left ⇡
    | ⊡1 # start of right ⇡
    )
    ↧ # end of left segment = leftmost
  )
  ⊙-. # compute ⧻ from start and end
  ⊟   # build left segment
)
MiddleSegment ← (
  # 40_20 52_50_48
  ⊃(
    ⊓(
      ⊢  # start of left ⇡
    | ⊡1 # start of right ⇡
    )
    ↥ # start of middle = rightmost start
  | ⊓(
      /+   # end of left ⇡
    | /+↘1 # end of right ⇡
    )
    ↧ # end of middle = leftmost end
  | ;
    - ⊃(⊡1|⊢) # offset of right ⇡
  )
  -,: # ⧻ of middle from start to end
  ⊟:  # build source middle segment
  ⍜⊢+ # apply offset to middle segment
)
RightSegment ← (
  # 80_20 52_50_40 -> 90_10
  ⊃(
    /+ # end of left ⇡ (100)
  | ⊓(
      ⊢    # start of left ⇡ (80)
    | /+↘1 # end of right ⇡ (90)
    )
    ↥ # start of right segment = rightmost (90)
  )
  -, # ⧻ of right segment
  ⊟: # build right segment
)

ValidRange ← (
  ⊡1
  >0
)

ApplyRangeToRange ← (
  # 40_20 52_50_48 -> [ 40_10 ] [ 52_10 ]

  ⊃(
    ⊟⊃(LeftSegment|RightSegment)
  | ¤ MiddleSegment
  )

  # filter out invalid ranges
  ∩(
    ▽ ≡ValidRange .
  )
)

ApplyTableToRangeStep ← (|3.2
  # on the stack: ⇡ to apply, and accumulators: ranges to process, transformed ranges
  ¤
  ≡(
    :
    ApplyRangeToRange
    ∩□
  )
  ∩(∧(⊂⊔)⊙(↯0_2[]))
  ⊙⊂
)

ConvertSeeds ← ↯¯1_2
SortRanges ← ⊏⍏≡⊢.
JoinBoxed ← ∧(⊂⊔)⊙(↯0_2[])

ApplyTableToRange ← (
  :
  ⊙(
    ¤
    ⊙(↯0_2[])
  )
  ∧ApplyTableToRangeStep
  # on the stack: untransformed ranges, transformed ranges
  # merge transformed ranges with untransformed ones
  ⊂
)
ApplyTableToRanges ← (
  ⊙¤
  ≡(□ApplyTableToRange)
  JoinBoxed
  SortRanges
)

ApplyTablesToRanges ← (
  ∧(|2
    ⊔
    :
    ApplyTableToRanges
  )
)

PartTwo ← (
  Parse
  ConvertSeeds
  :
  ApplyTablesToRanges
  ⊡ 0_0
)

$ seeds: 79 14 55 13
$
$ seed-to-soil map:
$ 52 50 48
$ 50 98 2
$
$ soil-to-fertilizer map:
$ 0 15 37
$ 37 52 2
$ 39 0 15
$
$ fertilizer-to-water map:
$ 49 53 8
$ 0 11 42
$ 42 0 7
$ 57 7 4
$
$ water-to-light map:
$ 88 18 7
$ 18 25 70
$
$ light-to-temperature map:
$ 45 77 23
$ 81 45 19
$ 68 64 13
$
$ temperature-to-humidity map:
$ 0 69 1
$ 1 0 69
$
$ humidity-to-location map:
$ 60 56 37
$ 56 93 4

⍤⊃⋅∘≍ 46 PartTwo
```

Avec des tests unitaires sur chacune des petites fonctions, le code n'a pas été trop difficile à écrire malgré certaines manipulations de pile un peu compliquées. J'ai vu ensuite des implémentations Uiua d'intersections d'intervalles bien plus élégantes, notamment en améliorant la représentation des intervalles.

Par curiosité (et pour pouvoir plus facilement partager ma solution) j'ai voulu voir à quoi elle ressemblerait sous une forme plus compacte, ça donne ceci :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n

ParseSeeds ← ⊜parse≠@\s. ↘+2⊗@:. ⊔
ParseMap ← □ ≡(⊜parse ≠@\s. ⊔) ↘1
ParseMaps ← ⊜ParseMap ≠0≡⧻.
Parse ← ⊃(ParseSeeds ⊢|ParseMaps ↘2) Lines

LeftSegment ← ⊟ ⊙-. ⊃(⊢|↧ ⊓(/+|⊡1))
MiddleSegment ← ⍜⊢+ ⊟:-,: ⊃(↥ ⊓(⊢|⊡1)|↧ ∩/+⊙(↘1)|- ⊃(⊡1|⊢) ;)
RightSegment ← ⊟: -, ⊃(/+|↥ ⊓(⊢|/+↘1))

ApplyRangeToRange ← ∩(▽ >0 ⊃(≡⊡1)∘) ⊃(⊟⊃(LeftSegment|RightSegment)|¤ MiddleSegment)
ApplyTableToRangeStep ← |3.2 ⊙⊂ ∩(∧(⊂⊔)⊙(↯0_2[])) ≡(∩□ ApplyRangeToRange :) ¤

ApplyTableToRange ← ⊂ ∧ApplyTableToRangeStep ⊙(⊙(↯0_2[]) ¤) :
ApplyTableToRanges ← ⊏⍏≡⊢. ∧(⊂⊔)⊙(↯0_2[]) ≡(□ApplyTableToRange) ⊙¤

ApplyTablesToRanges ← ∧(ApplyTableToRanges : ⊔)

PartTwo ← ⊡ 0_0 ApplyTablesToRanges : ↯¯1_2 Parse
PartOne ← ⊡ 0_0 ApplyTablesToRanges : ≡(⊂:1) Parse

$ seeds: 79 14 55 13
$
$ seed-to-soil map:
$ 52 50 48
$ 50 98 2
$
$ soil-to-fertilizer map:
$ 0 15 37
$ 37 52 2
$ 39 0 15
$
$ fertilizer-to-water map:
$ 49 53 8
$ 0 11 42
$ 42 0 7
$ 57 7 4
$
$ water-to-light map:
$ 88 18 7
$ 18 25 70
$
$ light-to-temperature map:
$ 45 77 23
$ 81 45 19
$ 68 64 13
$
$ temperature-to-humidity map:
$ 0 69 1
$ 1 0 69
$
$ humidity-to-location map:
$ 60 56 37
$ 56 93 4

⍤⊃⋅∘≍ 35 PartOne .
⍤⊃⋅∘≍ 46 PartTwo
```

J'en ai profité pour exprimer `PartOne` en fonction du code écrit pour la deuxième partie, puisque ce n'est qu'un cas particulier.
