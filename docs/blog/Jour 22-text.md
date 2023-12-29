##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) 22 [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 

# Jour 22

## Partie 1

Je jette un œil à l'entrée avant de lire l'énoncé :

```no_run
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
```

Du coup j'écris le parser, comme ça c'est fait :

```
Parse ← ↯ ¯1_2_3 ⊜⋕∊:"0123456789".

$ 1,0,1~1,2,1
$ 0,0,2~2,0,2
$ 0,2,3~2,2,3
$ 0,0,4~0,2,4
$ 2,0,5~2,2,5
$ 0,1,6~2,1,6
$ 1,1,8~1,1,9
Parse
```

Du coup c'est quoi ces nombres ? Des segments dans l'espace ?

C'est une pile de briques, apparemment. Ah non, une photo de briques qui tombe. Mais ce sont bien des paires de coordonnées dans l'espace, qui désignent les coins d'une brique.

Il faut simuler la chute des briques jusqu'à ce qu'elles touchent le sol ou une autre brique touchant le sol ; puis trouver lesquelles peuvent être supprimées sans faire bouger d'autre brique.

C'est parti pour la réflexion. La première partie est censée être facile, donc pas trop de réflexion quand même, attention.

Est-ce que je fais vraiment la simulation, ou bien je peux me contenter de regarder si une brique en a d'autres sous elle ?

J'ai `1229` briques dans l'entrée. Les coordonnées vont de `0` à `283`.

Si je trie les briques par `z minimum` décroissant, pour chaque brique je peux regarder si parmi les briques qui la suivent (donc sont en-dessous) il y en a au moins une ayant une intersection en `x,y` avec elle. Est-ce que j'ai besoin de regarder le `z maximum` ? Il me semble que non : si une brique avec un `z minimum` inférieur à celle considérée a une intersection en `x,y` avec celle-ci, alors son `z maximum` est nécessairement inférieur au `z minimum` de celle-ci, sinon elles seraient en intersection et l'énoncé dit bien que cela n'existe pas (_Two bricks cannot occupy the same position_).

Je vérifie que les coordonnées `z` sont triées sur chaque ligne, c'est bien le cas. En fait `x`, `y` et `z` sont bien triées.

Ah, c'est par `z` croissant que je dois traiter les briques si je veux savoir lesquelles _soutiennent_ d'autres briques et ne peuvent donc pas être désintégrées.

C'est un problème d'intersection de rectangles. On est comment sur les intersections de rectangles ? Je vérifie que les intervalles `x` et `y` s'intersectent simultanément ? Oui, ça a l'air de marcher.

Ah zut, c'est plus compliqué que je ne l'imaginais pour trouver les briques supprimables. Il ne suffit pas de trouver les briques qui ne supportent rien ; une brique qui en soutient une autre peut quand même être supprimée si une troisième brique soutient la deuxième.

Posons la question différemment : pour chaque brique, quelles sont celles qui la soutiennent ? L'ensemble des briques qui en soutiennent au moins une autre ne sont pas supprimables.

C'est reparti pour trier par `z` décroissant du coup.

Ah mais zut, j'ai encore pensé n'importe quoi, décidément. Une brique est à conserver si elle est la seule à en soutenir une autre. C'est correct ça ?

Toujours pas, mais c'est parce que je me suis trompé en amont. Une brique `A` peut être "au-dessus" (faire de l'ombre) d'une brique `B` sans être soutenue par `B`, si une brique `C` soutient `A` de sorte qu'il reste de l'espace vertical entre `A` et `B`.

Je vais vraiment devoir calculer les positions finales des briques ? Peut-être pas. Ma logique de recherche des briques qui sont sous une autre fait quand même un travail utile : sous `A` on trouve `B` et `C`, reste à déterminer lesquelles parmi `B` et `C` "touchent `A` à la fin. Non ? Je commence à être perdu.

Et si je repars de la question : est-ce qu'une brique donnée peut être enlevée ? Si je savais calculer les positions finales des briques, il me suffirait d'enlever la brique puis de faire un pas de simulation.

Après tout, la simulation n'est pas forcément si coûteuse. En prenant les briques par `z` croissant, je peux regarder s'il y a des briques précédant chaque brique et qui l'intersecte. Disons, le `z` le plus grand des briques qu'elle "couvre", avec `0` comme valeur de repli pour représenter le sol. Ensuite le nouveau `z` de ma brique est ce `z` plus 1.

Voilà, je crois que je sais faire tomber des briques. En `n^2` certes, mais ne chipotons pas. Enfin, ça prend déjà une poignée de secondes sur les `1229` briques donc essayons de ne pas trop en rajouter. Typiquement, je ne peux pas m'amuser à refaire une simulation complète après avoir enlevé chaque brique.

Maintenant, une brique participe vraiment à en soutenir une autre si elle est dessous mais avec un `zmax` immédiatement inférieur au `zmin` de la première. Pour chaque brique, je peux énumérer les briques qui sont "au-dessus", et regarder si une d'entre celle-là a un `zmin` égal à mon `zmax` plus 1. Probablement plus efficace dans l'autre sens : je filtre les briques pour ne garder que celles qui ont le `zmin` requis, puis je regarde s'il y en a qui me couvrent.

…et non, c'est toujours pas ça. Ce n'est pas parce qu'une brique est posée sur moi qu'elle va tomber si je me retire, il faut que je me mette ça dans le crâne.

Je finis par arriver à quelque chose qui marche : pour chaque brique, je regarde quelles sont les briques qui la soutiennent (intersectant en X/Y et dont le `zmax` est égal à mon `zmin-1`), et s'il n'y en a qu'une, j'ajoute cette dernière à la liste des briques "porteuses".

Ça me donne enfin la bonne réponse à la partie 1.

```
Parse ← ↯ ¯1_2_3 ⊜⋕∊:"0123456789".

# ( range1 range2 -- bool )
RangesIntersect ← (
  # sort by min1
  ⍜⊟(⊏⍏.)
  # get max1, min2
  ⊓(⊡1|⊡0)
  # check it's at least min2
  ≤
)
# ( brick1 brick2 -- bool )
Covers ← (|2
  ⊃(
    ∩≡(⊡0)
  | ∩≡(⊡1)
  )
  ∩RangesIntersect
  ↧
)
DropAll ← (
  ⊏⍏≡(⊡0_2).              # sort bricks by increasing z
  ⊙[[[¯∞ ¯∞ ¯∞] [∞ ∞ 0]]] # dropped bricks accumulator: start with ground
  # for each brick to drop
  ∧(
    # -- dropping dropped
    ⊃(
      ⊃∘(
        ¤ # fix dropping
        # -- [dropping] dropped
        ⊃(
          ≡Covers # find potentially supporting dropped bricks
          # -- [covers?]
            | ⋅∘
        )
        # -- [covers?] dropped
        ▽
        # -- covered
        # find max zmax
        ≡(⊡ 1_2)
        /↥
      )
      # -- dropping droppedzmax
      ⊃∘(
        # distance to fall = myzmin - droppedzmax - 1
        ⊡0_2
        -1-:
      )
      # -- dropping falldist
      ⍜(⊡[0_2 1_2])(
        -:
      )
      # -- dropping
    | ⋅∘ # keep dropped
    )
    # -- dropping dropped
    # add dropping to dropped
    ⊂:
  )
  ↘1 # remove ground
)
FindKeepers ← (
  ⊏⍏≡(⊡0_2). # sort bricks by increasing z
  :¤.        # fix a copy
  ≡(
    # -- brick bricks
    ⊃∘(
      ⊡0_2 # get zmin
      -1   #  find zmax of supporters
      # -- zmin-1 bricks
      ⊙(≡(⊡1_2).) # pick zmax from bricks
      =           # match zin-1 against zmax of bricks
      # keep only matching
      ▽
    )
    # -- brick justunder
    ¤             # fix brick
    ⊃(≡Covers|⋅∘) # find covered bricks
    ▽♭
    # -- supporters
    =1⧻. # only one supporter?
    # if so, keep it
    (
      ⋅[]
    | ∘
    )
    □
  )
  ≠□[].
  ≡°□▽
  ☇2
  ⊝
  # -- tokeep
)
CountRemovable ← (
  ⊃(⧻FindKeepers) ⧻
  -
)
PartOne ← (
  Parse
  DropAll
  CountRemovable
)

$ 1,0,1~1,2,1
$ 0,0,2~2,0,2
$ 0,2,3~2,2,3
$ 0,0,4~0,2,4
$ 2,0,5~2,2,5
$ 0,1,6~2,1,6
$ 1,1,8~1,1,9

⍤⊃⋅∘≍ 5 PartOne
```

## Partie 2

Ah ben faudrait savoir. Maintenant il paraît qu'on cherche la brique qui en fera tomber le plus d'autres si on la désintègre. Enfin, l'énoncé commence par dire ça mais la question finale c'est plutôt : pour chaque brique, calculer le nombre de briques qui tombent si on l'enlève, et faire la somme de tous ces nombres.

En théorie c'est assez simple : je peux enlever chaque brique successivement, faire une simulation et regarder ce qui tombe. Et avec seulement `1229` briques, ça ne prendrait certainement pas plus de quelques minutes.

Mais faisons plutôt les choses proprement. Dans la première partie, j'ai calculé l'ensemble des briques qui soutiennent une brique donnée. Bien sûr, en inversant cette relation je peux obtenir l'ensemble des briques soutenues par une brique donnée. Ensuite, ça devrait être assez rapide de parcourir cette relation pour trouver la cascade de briques déclenchée par la désintégration d'une brique.

D'ailleurs, si je construis cette relation — sous la forme assez naturelle en Uiua d'une matrice binaire — je pourrai m'en servir pour ré-exprimer le calcul de la partie 1.

Je commence donc par faire ça, en extrayant de ma fonction `FindKeepers` précédente une fonction `SupportMatrix` :

```
Parse ← ↯ ¯1_2_3 ⊜⋕∊:"0123456789".
# ( range1 range2 -- bool )
RangesIntersect ← ≤⊓(⊡1|⊡0)⍜⊟(⊏⍏.)
# ( brick1 brick2 -- bool )
Covers ← ↧∩RangesIntersect ⊃(∩≡(⊡0)|∩≡(⊡1))
# ( bricks -- matrix )
SupportMatrix ← (|1
  :¤. # fix a copy
  # -- bricks [bricks]
  ≡(|2
    # -- brick bricks
    ⊃(
      ⊡0_2      # get zmin
      -1        # find zmax of supporters
      ⊙(⊡1_2 ⍉) # pick zmax from bricks
      =         # match zmin-1 against zmax of bricks
    | ¤         # fix brick
      ≡Covers   # find covered bricks mask
    )
    # -- justundermask coveredmask bricks
    # and masks together
    ↧
  )
)

[[1_0_1 1_2_1]
 [0_0_2 2_0_2]
 [0_2_2 2_2_2]
 [0_0_3 0_2_3]
 [2_0_3 2_2_3]
 [0_1_4 2_1_4]
 [1_1_5 1_1_6]]
SupportMatrix
```

J'ai maintenant une matrice qui contient sur chaque ligne un `1` pour chaque autre brique qui soutient celle-ci. Dans l'exemple on trouve donc uniquement des `0` sur la première ligne, puisque la première brique repose directement sur le sol.

Je peux facilement réexprimer la première partie (`FindKeepers`) en cherchant les lignes ne contenant qu'un seul `1`, puis en récupérant la position des `1` en question pour connaître le numéro des briques porteuses.

```no_run
# ( bricks -- keepersmask )
FindKeepers ← (
  SupportMatrix
  # find bricks supported by a single other
  =1/+⍉.
  # find the supporters for those
  /↥▽
)
```

Ensuite, pour trouver l'ensemble des briques soutenues même indirectement par une brique donnée, je vais faire :
* initialiser la liste des briques qui tombent avec la brique de départ ;
* initialiser un "compteur de supports", un vecteur qui donne pour chaque brique le nombre de supports qu'elle a ;
* trouver les briques supportées par une des briques qui tombent, et décrémenter leur compteur de support ; celles qui passent à `0` supports deviennent la nouvelle liste des briques qui tombent, et on note que celles-ci sont tombées ;
* répéter l'étape précédente jusqu'à ce que la liste des briques qui tombent soit vide.

Grâce à la représentation en matrice des relations de support entre les briques, ces opérations sont plutôt rapides. Donc ça ne prend vraiment pas longtemps de faire la boucle sur chacune des briques.

```
Parse ← ↯ ¯1_2_3 ⊜⋕∊:"0123456789".
# ( range1 range2 -- bool )
RangesIntersect ← ≤⊓(⊡1|⊡0)⍜⊟(⊏⍏.)
# ( brick1 brick2 -- bool )
Covers ← ↧∩RangesIntersect ⊃(∩≡(⊡0)|∩≡(⊡1))
# ( bricks -- bricks' )
DropAll ← (
  ⊏⍏≡(⊡0_2).
  ⊙[[[¯∞ ¯∞ ¯∞] [∞ ∞ 0]]]
  ∧(
    ⊂: ⊃(
      ⊃∘(/↥ ≡(⊡ 1_2) ▽ ⊃(≡Covers|⋅∘) ¤)
      ⊃∘(-1-: ⊡0_2)
      ⍜(⊡[0_2 1_2])(-:)
    | ⋅∘
    )
  )
  ↘1
)
# ( bricks -- matrix )
SupportMatrix ← (|1
  :¤. # fix a copy
  # -- bricks [bricks]
  ≡(|2
    # -- brick bricks
    ⊃(
      |2   # -- brick bricks
      ⊡0_2 # get zmin
      -1   #  find zmax of supporters
      # -- zmin-1 bricks
      ⊙(⊡1_2 ⍉) # pick zmax from bricks
      =         # match zmin-1 against zmax of bricks
    | |2        # -- brick bricks
      ¤         # fix brick
      ≡Covers   # find covered bricks mask
      # -- coveredmask
    )

    # -- justundermask coveredmask bricks
    # and masks together
    ↧
  )
)

# ( bricks -- keepersmask )
FindKeepers ← (
  SupportMatrix
  # find bricks supported by a single other
  =1/+⍉.
  # find the supporters for those
  /↥▽
)
CountRemovable ← (
  ⊃(/+ FindKeepers|⧻)
  -
)
PartOne ← (
  Parse
  DropAll
  CountRemovable
)
Step ← (
  # get their supportees
  ⊃(/+▽⊙⋅∘|⋅⊙∘)
  # bump down supportercount of supportees
  -
  # find new list of falling bricks
  =0.
  # bump supportcount of fallers to -inf to avoid them falling again
  ⊃(∘|⍜▽(-∞))
)
PartTwo ← (
  Parse
  DropAll
  SupportMatrix
  # compute supporters count
  ≡/+.
  # those on the ground (no supporters) have infinite supporters
  .
  =0
  ⍜▽(+∞)
  # pre-transpose suppportmatrix: becomes list of supportees lists
  ⊙⍉
  ⊠=.⇡⊃(⋅⧻|⊙∘) # range of bricks to remove
  ⊙∩¤          # fix counts and matrix
  ≡(
    # pick a selection to remove
    # ( fallingmask supportercounts supporteesmatrix -- fallingmask' )
    ⍢(
      Step
    | # until fallingmask is all zeroes
      ±/+.
    )
    # count fallers
    ⋅(⧻⊚<0)
    # drop matrix
    ⊙;
  )
  /+
)

$ 1,0,1~1,2,1
$ 0,0,2~2,0,2
$ 0,2,3~2,2,3
$ 0,0,4~0,2,4
$ 2,0,5~2,2,5
$ 0,1,6~2,1,6
$ 1,1,8~1,1,9

⍤⊃⋅∘≍ 5 PartOne.
⍤⊃⋅∘≍ 7 PartTwo
```


##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) 22 [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
