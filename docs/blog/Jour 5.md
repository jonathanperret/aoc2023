## Ce que j'ai retenu des épisodes précédents

Ça n'a pas trop mal marché de rédiger en même temps que je réfléchissais au problème. Quand les jours avancent et que les problèmes se complexifient, il devient de toute façon indispensable de se poser un peu avant de se lancer dans l'implémentation.

Ça ne m'a quand même pas mis à l'abri d'une erreur hier, qui était de construire une structure trop compliquée : j'ai représenté chque carte par un vecteur de `1` consécutifs alors que j'aurais pu me contenter de stocker la longueur du vecteur, ce qui aurait été plus simple à parcourir dans la suite de l'algorithme. Je crois que j'ai vraiment intérêt à favoriser les structures les plus simples qui soient avec ce langage.

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
---

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


