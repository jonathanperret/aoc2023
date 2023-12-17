## Partie 1

Une histoire de chariot de lave qui doit traverser la ville.

La ville, c'est une grille de chiffres :

```no_run
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
```

On entre en haut à gauche, on veut aller en bas à droite.

Il faut minimiser le total des chiffres sur le trajet ; et il ne faut jamais faire plus de `3` pas en ligne droite.

Bon, ça ressemble à un problème classique de chemin le plus court dans un graphe ; mais cette subtilité de `3` pas m'inquiète un peu.

La grille complète fait `141x141` caractères, soit `19881` nœuds.

Typiquement, pour résoudre ce genre de problèmes je vais faire un parcours en largeur du graphe : je commence par noter que je peux aller pour un coût de `0` au point de départ (important à noter : le chiffre porté par la case de départ ne doit pas être compté), puis j'explore les voisins de cette case et je calcule le coût d'y accéder ; ensuite de même pour les voisins de ces voisins, en accumulant le coût et à chaque fois que je retombe sur une case déjà visitée, je mets à jour son coût si j'y arrive avec un meilleur coût. Ça finit par donner le meilleur coût d'accès à chacun des nœuds du graphe.

Bref, ça s'appelle [l'algorithme de Dijkstra](https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra) et c'est un grand classique. Le genre de choses que les spécialistes d'Advent of Code implémentent en littéralement moins de 30 secondes.

Bon, mais ici il y a cette histoire de limiter les lignes droites. Le problème, c'est qu'une même case peut être accessible depuis l'arrivée pour disons un coût de `10` mais avec interdiction de continuer par une de ses voisines (parce qu'on a fait `3` pas en ligne droite), ou bien par un coût de `12` mais sans restrictions sur la case suivante. Et une structure classique de "meilleur coût d'accès à chaque case" n'encode pas cette information.

Une idée (assez classique aussi dans ce genre de problèmes, je n'invente rien ici) qui pourrait marcher, c'est de transformer ce graphe, qui pour l'instant est une grille en `2` dimensions, en ajoutant la dimension du nombre de cases parcourues en ligne droite pour arriver à un certain endroit.

Imaginons qu'on duplique la grille de départ `3` fois pour constituer `3` nouveaux "étages" :

```no_run
2413432311323 2413432311323 2413432311323 2413432311323
3215453535623 3215453535623 3215453535623 3215453535623
3255245654254 3255245654254 3255245654254 3255245654254
3446585845452 3446585845452 3446585845452 3446585845452
4546657867536 4546657867536 4546657867536 4546657867536
1438598798454 1438598798454 1438598798454 1438598798454
4457876987766 4457876987766 4457876987766 4457876987766
3637877979653 3637877979653 3637877979653 3637877979653
4654967986887 4654967986887 4654967986887 4654967986887
4564679986453 4564679986453 4564679986453 4564679986453
1224686865563 1224686865563 1224686865563 1224686865563
2546548887735 2546548887735 2546548887735 2546548887735
4322674655533 4322674655533 4322674655533 4322674655533
```

On peut imaginer ça comme un cube, du coup, mais c'est moins facile à représenter ici.

Dans le graphe de départ, chaque case de la grille est implicitement connectée à ses `4` voisines immédiates.

Mais dans ce nouveau graphe, chaque case serait connectée non pas à ses voisines au même étage, mais à ses "voisines" aux étages inférieurs ou supérieurs selon que le passage à cette voisine représente une avancée en ligne droite ou en tournant (si on va tout droit, on monte d'un étage ; si on tourne, on tombe directement au rez-de-chaussée).

En principe on pourrait donc se ramener à un problème de parcours dans un graphe (quatre fois plus grand) sans la contrainte initiale.

Bon, peut-être que `3` étages supplémentaires ne suffisent pas, parce qu'il faut encoder non seulement le nombre de pas mais aussi la direction dans laquelle on avançait pour arriver dans une case donnée.

Ah, peut-être qu'au lieu d'ajouter des étages qui représentent la distance en ligne droite, je peux en ajouter qui représentent la dernière direction prise ? Les connections seraient donc les suivantes : à chaque case, je peux rester sur le même étage à condition d'avancer dans la direction (Nord, Sud, Est, Ouest) associée à cet étage — donc chaque case a au plus une voisine à l'intérieur d'un étage ; les autres voisines sont prises chacune dans un étage différent.

Je crois que je n'aurais pas besoin d'ajouter encore des étages pour encoder la distance parcourue dans une direction donnée ; quand j'évaluerai le coût d'accès à une cellule, je pourrai faire un couple avec le total des chiffres rencontrés jusque-là mais aussi le nombre de pas dernièrement faits sur le même étage (un changement d'étage remettant ce compteur à zéro). Quand il faudra énumérer les voisins d'une cellule visitée, on pourra éliminer ceux qui feraient passer le compteur au-dessus de `3` ; et quand il s'agira de comparer le coût d'accès à une case à un coût précédemment stocké, un plus petit nombre de pas en ligne droite pour arriver à une case donnée sera toujours meilleur.

J'ai l'impression qu'une stratégie robuste commence à se dessiner. Mais je dois faire attention à ne pas tomber dans le même piège qu'hier : me lancer à une stratégie intéressante et potentiellement préparée à la complexité de la deuxième partie (par exemple, avec celle décrite ci-dessus je calculerais trivialement le coût minimal d'accès à tous les nœuds de la grille), pour découvrir ensuite que la deuxième partie ne nécessitait pas cet investissement ou pire, que cette approche est inefficace pour ce qui est demandé.

Mais est-ce que j'ai d'autres approches possibles de ce problème ?

Oui, il y a celle du parcours en profondeur : en partant toujours de la case de départ, on construit un chemin en prenant toujours la "première" case disponible parmi les voisines. On ne rentre pas dans une case si le chemin en cours l'a déjà visitée ; et on continue ainsi jusqu'à atteindre un cul-de-sac ou l'arrivée. Si on arrive à l'arrivée, on note le score obtenu puis on revient sur ses pas jusqu'au dernier embranchement qu'on n'a pas complètement exploré, et on essaie les possibilités inexplorées pour voir si ça mène à l'arrivée avec un meilleur score.

La structure de données (le chemin en cours) est plus simple que celle de l'algorithme de Dijkstra, mais cet algorithme peut être inefficace parce qu'une même case va être visitée un grand nombre de fois.

J'ai du mal à me dissuader d'implémenter Dijkstra quand même. Ce n'est pas comme si le parcours en profondeur était vraiment trivial à implémenter. Une approche naïve utiliserait la récursion ; il y a un mécanisme expérimental de récursion en Uiua avec `recur`, mais un test rapide me montre que la pile d'appels est limitée à moins de `1000` appels récursifs et je ne suis pas sûr que cela suffise.

Pour revenir à mon Dijkstra, je réalise qu'il y a peut-être plus simple que d'ajouter des étages au graphe : et si je me contentais de stocker sur chaque case visitée non pas un mais `4` scores, chacun associé à une direction ? Ainsi une case pourrait porter par exemple "atteignable pour un score de `15` après `2` pas vers le Nord, ou un score de `12` après `3` pas vers le Sud", etc.

Je soupçonne qu'il ne s'agisse que d'une représentation légèrement différente de celle que j'avais en tête avec les "étages" mais que ça revienne au même. En revanche je me rends compte que ce n'est pas si simple de comparer ces couples : `15 après 2 pas vers le Nord` est indubitablement meilleur que `20 après 2 pas vers le Nord` mais n'est pas forcément meilleur que `20 après 1 pas vers le Nord` par exemple, ou encore `10 après 1 pas vers le Nord`.

Il faudrait donc que sur chaque cellule je stocke jusqu'à `16` scores : un pour chaque nombre de pas dans chaque direction. J'ai l'impression que ça revient à avoir `16` étages dans mon graphe.

Ça fait très longtemps que je réfléchis sans avoir écrit une ligne de code.

Pour me changer les idées, je fais la lecture de l'entrée vite fait :

```
Parse ← ⊜(-@0)≠@\n.

$ 2413432311323
$ 3215453535623
$ 3255245654254
$ 3446585845452
$ 4546657867536
$ 1438598798454
$ 4457876987766
$ 3637877979653
$ 4654967986887
$ 4564679986453
$ 1224686865563
$ 2546548887735
$ 4322674655533
Parse
```

Puis je me remets à l'implémentation de l'algorithme de Dijkstra.

C'est comme un tunnel interminable.

```
Parse ← ⊜(-@0)≠@\n.
Directions ← [0_1 ¯1_0 0_¯1 1_0]
# coordinate -- coordinates
ListNeighbors ← (
  +Directions ¤
)

# - graph: node-indexed matrix of boxes[box[nodes] box[weights]]
#   ( grid -- graph)
MakeGraph! ← (|1
  ⊃(
    △
    ⊃(
      ⇡ # generate coordinates
    | ¤ # fix shape
    )
  | ¤ # fix grid
  )
  # for each cell coordinate
  ⍜(☇1)≡(
    # generate neighbors
    ^1
    ⊃(
      ⊙¤ # fix shape
      # check if each is < shape and >= 0
      ≡(/↧ ↧⊃(>|+1±))
    | ∘ # keep neighbors
    )
    ▽     # keep only in-range neighbors
    {⊃∘⊡} # get edge weights for these from grid, pack together
  )
)
Opposite ← (|1
  ◿4+2
)
ListNeighborsFourD ← (|1
  ⊃(
    ⊡0 # get direction
  | ListNeighbors ↘2
    ≡(⊂0) # new count defaults to 0
  | +1⊡1  # get count
  )
  ⊃∘(
    ⊂:0    # target count of original direction
    ⍜⊡(⋅∘) # replace with new count
    ≡⊂ ⇡⧻. # add direction number in front
  )
  Opposite
  °⊚
  ⬚0↯[4]
  ¬
  # opposite direction is forbidden!
  ▽
)
ExpandGridToFourD ← (
  ↯ ⊂ 4_3 △. # expand grid to 4D by repeating
)
# - setup:
#   - best cost: infinite for all nodes except 0 for start nodes
#   - visited: all nodes 0
#   - queue: start nodes (coordinates)
#   - queuecosts: 0 for each start node
#   ( startnodes graph -- queuecosts queue visited best )
DijkstraSetup ← (|2.4
  ⊃(
    ⊃(≡⋅0)∘    # queue costs 0 for start nodes
  | ⊙(⍜⇌(↘1)△) # shape of node matrix
    ⊃(
      ⋅(≠0↯:0) # all nodes unvisited (suggest byte array)
    | ⊙(↯:∞)   # all nodes infinite cost
      ⍜⊡(∵⋅0)  # start nodes cost 0
    )
  )
)
# - pop cheapest node and cost from queue
#   ( queuecosts queue -- node cost queuecosts' queue' )
PopCheapest ← (|2.4
  ⍏.                    # get cost order
  ⊃(⊢|↘1)               # pop first
  ⊃(⊡⊙⋅;|⊡⊙;|⊏⋅∘|⊏⋅⊙⋅∘) # pick and select
)
# - check visited
#   ( node visited -- isvisited )
CheckVisited ← |2 ⊡
# - mark node visited
#   ( node visited -- visited' )
MarkVisited ← |2 ⍜⊡⋅1
# - get neighbors (with weights) of node from graph
#   ( node graph -- neighbors neighborweights )
GetNeighborsWithWeights ← |2.2 ∩°□°⊟ ⊡
# - remove visited neighbors
#   ( neighbors neighborweights visited -- neighbors' neighborweights' )
RemoveVisitedNeighbors ← (|3.2
  ⊃(
    ¬⊡ ⊙⋅∘ # get visited status
  | ⊙∘
  )
  ∩▽,: # keep non-visited in both lists
)
# - add node's cost to neighbor's weights
#   ( neighborweights cost -- neighborcosts )
AddCostToNeighborWeights ← +
# - get neighbors best costs
#   ( neighbors best -- neighborbests )
GetNeighborsBestCosts ← ⊡
# - keep neighbors where newcost < best cost
#   ( neighborbests neighbors neighborcosts -- neighbors' neighborcosts' )
KeepImprovedNeighbors ← (
  ⊃(
    < ⊙⋅∘ # mask of improved
  | ⋅⊙∘   # keep neighbors, neighborcosts
  )
  ,: # -- mask neighbors mask neighborcosts
  ∩▽ # -- neighbors' neighborcosts'
)
# - update their best costs with newcost
#   ( neighbors neighborcosts best -- best' )
UpdateNeighborsBestCosts ← (|3
  ⊙:   # bring best up
  ⍜⊡⋅∘ # replace picked with new costs
)
# - add them to the queue
#   ( neighbors neighborcosts queuecosts queue -- queuecosts' queue' )
AddNeighborsToQueue ← (|4.2
  ⊃(⋅⊙∘|⊙⋅⋅∘)
  ∩(⊂:)
)
# - Dijkstra's step:
#   -- queuecosts queue visited best graph
DijkstraStep ← (|5.5
  #   - pop cheapest node and cost from queue
  #     ( queuecosts queue -- node cost queuecosts' queue' )
  PopCheapest
  #     -- node* cost* queuecosts' queue' visited best graph
  #   - check visited
  #     ( node visited -- isvisited )
  ⊃(CheckVisited ⊙⋅⋅⋅∘|⊙⊙⊙⊙∘)
  #     -- isvisited* node cost queuecosts queue visited best graph
  #   - assert not visited
  ⍤"a node in the queue should never be already visited"=0
  #     -- node cost queuecosts queue visited best graph
  #   - mark node visited
  #     ( node visited -- visited' )
  ⊃(⊙⊙⊙∘|MarkVisited ⊙⋅⋅⋅∘)
  #     -- node cost queuecosts queue visited' best graph
  #   - get neighbors (with weights) of node from graph
  #     ( node graph -- neighbors neighborweights )
  ⊃(GetNeighborsWithWeights ⊙⋅⋅⋅⋅⋅∘|⋅⊙⊙⊙⊙⊙∘)
  #     -- neighbors* neighborweights* cost queuecosts queue visited best graph
  #   - remove visited neighbors
  #     ( neighbors neighborweights visited -- neighbors' neighborweights' )
  ⊃(RemoveVisitedNeighbors ⊙⊙⋅⋅⋅∘|⋅⋅⊙⊙⊙∘)
  #     -- neighbors' neighborweights' cost queuecosts queue visited best graph
  #   - add node's cost to neighbor's weights
  #     ( neighborweights cost -- neighborcosts )
  ⊃(∘|AddCostToNeighborWeights ⋅∘)
  #     -- neighbors neighborcosts* queuecosts queue visited best graph
  #   - get neighbors best costs
  #     ( neighbors best -- neighborbests )
  ⊃(GetNeighborsBestCosts ⊙⋅⋅⋅⋅∘|⊙⊙⊙⊙⊙∘)
  #     -- neighborbests neighbors neighborcosts queuecosts queue visited best graph
  #   - keep neighbors where newcost < best cost
  #     ( neighborbests* neighbors neighborcosts -- neighbors' neighborcosts' )
  KeepImprovedNeighbors
  #     -- neighbors' neighborcosts' queuecosts queue visited best graph
  #   - update their best costs with newcost
  #     ( neighbors neighborcosts best -- best' )
  ⊃(⊙⊙⊙⊙∘|UpdateNeighborsBestCosts ⊙⊙⋅⋅⋅∘|⋅⋅⋅⋅⋅⋅∘)
  #     -- neighbors neighborcosts queuecosts queue visited best' graph
  #   - add them to the queue
  #     ( neighbors neighborcosts queuecosts queue -- queuecosts' queue' )
  AddNeighborsToQueue
  #     -- queuecosts' queue' visited best graph
)
# ( queuecosts -- nonempty? )
QueueHasNodes ← ±⧻
# (queuecosts queue visited best graph -- best)
DijkstraLoop ← (
  # - repeat until queue empty:
  #   - step
  0
  ⍢(
    # -- counter queuecosts queue visited best graph
    ⊙DijkstraStep
    # -- counter queuecosts queue visited best graph
    +1
    ⊃(
      ±◿10000.
      (
        ⊃(
          &p
            | ;
          ;
          ;
          /↥/↥
          ⍣(&ims)(⋅;)
          # &p /↧/↧
        )
        | # do nothing
      )
    | ⊙⊙⊙⊙∘
    )
  )(⋅QueueHasNodes)
  # -- counter queuecosts queue visited best graph
  ⋅⋅⋅⋅⊙;
  # -- best
)
GetEndCost ← (
  /↧  # flatten directions
  /↧  # flatten step counts
  ⊢⇌♭ # take last element
)
FourDSolve ← (
  ExpandGridToFourD
  MakeGraph!ListNeighborsFourD
  ⊃(
    # start at top left, either going right or down
    [0_0_0_0 3_0_0_0]
    DijkstraSetup
  | ∘
  )
  DijkstraLoop
  GetEndCost
)
PartOne ← FourDSolve Parse

$ 2413432311323
$ 3215453535623
$ 3255245654254
$ 3446585845452
$ 4546657867536
$ 1438598798454
$ 4457876987766
$ 3637877979653
$ 4654967986887
$ 4564679986453
$ 1224686865563
$ 2546548887735
$ 4322674655533
⍤⊃⋅∘≍ 102 PartOne
```
