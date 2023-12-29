##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) 8 [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 

# Jour 8

## Partie 1

Aujourd'hui j'ai voulu essayer quelque chose de différent : ne pas écrire ce journal pendant que j'essayais de résoudre le problème, le plus vite possible.

Le résultat n'est pas une réussite. J'ai l'impression d'avoir été inefficace sur la première partie, et mon code pour la deuxième partie est encore en train de tourner, donc…

Bref, l'énoncé me donne ces données d'exemple :

```no_run
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
```

La première ligne est une liste d'instructions (R=aller à droite, L=aller à gauche).

Les autres lignes sont une liste de nœuds nommés `AAA`, `BBB`, etc. et pour chacun on nous indique quel nœud est atteint en allant à gauche, et quel nœud est atteint en allant à droite.

Pour la lecture de l'entrée, pas de difficulté particulière. Je remplace `L` par `0` et `R` par `1` avec `=@R`. Et pour les autres lignes, je crée des tableaux de 3 lignes contenant le nom du nœud de départ et les noms des 2 nœuds connectés.

```
Parse ← (
  ⊜□≠@\n. # découpage en lignes
  ⊃(
    =@R °□ ⊢ # première ligne = le programme
  | ↘ 1      # sauter la première ligne
    ≡(
      °□
      ≥0-@A. # ne retenir que les caractères alphabétiques
      ⊜∘     # et les regrouper
    )
  )
)

$ RL
$
$ AAA = (BBB, CCC)
$ BBB = (DDD, EEE)
$ CCC = (ZZZ, GGG)
$ DDD = (DDD, DDD)
$ EEE = (EEE, EEE)
$ GGG = (GGG, GGG)
$ ZZZ = (ZZZ, ZZZ)
Parse
```

Mon implémentation pour la partie 1 est assez simple.

J'écris une fonction `Step` qui prend une instruction (`0` ou `1`), un nom de nœud et une liste de triplets représentant les liens du graphe, et qui renvoie le nouveau nœud atteint.

```
Step ← (
  ⊙(
    ⊙(≡⊢.) # on extrait le premier élément de chaque triplet
    ⊗      # on trouve le nœud courant dans cette liste
    ⊡      # on extrait le triplet correspondant
  )
  ⊡+1 # on prend dans le triplet le nœud cible selon l'instruction
)

[["AAA" "BBB" "CCC"] ["BBB" "CCC" "DDD"]]
"AAA"
0
Step
```

J'écris ensuite `Walk` qui prend une liste d'instructions et la liste des liens,  et fait le parcours à partir du nœud `AAA`. J'utilise `fold` et c'est un peu technique : il faut que la fonction passée à `fold` remette la pile dans l'état où elle souhaite la trouver à l'itération suivante.

Ici, l'état de pile qu'on veut conserver d'une itération à l'autre, c'est le nœud courant en haut, suivi de la liste de liens. On utilise donc un `fork` dont une branche consomme via `Step` l'instruction fournie par `fold`, le nœud courant et la liste de liens, en remplaçant tout ça par le nouveau nœud ; et l'autre branche va aller repêcher avec les "planètes" `gap``gap``identity` la liste de liens à deux niveaux sous le haut de la pile.

On se retrouve donc bien à l'arrivée avec le nouveau nœud suivi de la liste des liens.

```
Step ← ⊡+1 ⊙(⊡ ⊗ ⊙(≡⊢.))
Walk ← (
  ⊙"AAA" # on glisse le nom du nœud de départ sous le programme

  # on itère sur le programme,
  # avec le nœud courant et la liste de liens
  # comme "accumulateurs"
  ∧(
    ⊃(
      Step # on exécute l'instruction
    | ⋅⋅∘  # on conserve la liste de liens
    )
  )
  # à la fin, on se débarrasse de la liste de liens
  ⊙;
)
[["AAA" "BBB" "CCC"] ["BBB" "CCC" "DDD"]]
[0 1]
Walk
```

Ah oui, mais je ne veux pas juste le dernier nœud atteint, je voudrais l'historique de tous les nœuds traversés, pour aller trouver ensuite le `ZZZ`.

Pour ça, je décide que `Walk` ne va pas utiliser comme accumulateur le nœud courant mais la liste des nœuds traversés. À chaque itération je prendrai le dernier élément de cette liste pour le passer à `Step`, puis j'ajouterai le nœud atteint à la liste avec `join` :

```
Step ← ⊡+1 ⊙(⊡ ⊗ ⊙(≡⊢.))
Walk ← (
  ["AAA"] # liste initiale des nœuds parcourus
  :       # on la glisse sous le programme

  # on itère sur le programme,
  # avec la liste des nœuds parcourus et la liste de liens
  # comme "accumulateurs"
  ∧(
    ⊃(
      ⊙(⊢⇌) # on remplace la liste des nœuds par son dernier élément
      Step  # on exécute l'instruction
    | ⋅⊙∘   # on conserve la liste des nœuds et la liste de liens
    )
    ⊂:
  )
  # à la fin, on se débarrasse de la liste de liens
  ⊙;
)
[["AAA" "BBB" "CCC"] ["BBB" "CCC" "DDD"]]
[0 1]
Walk
```


Il me reste à gérer le caractère "circulaire" du programme : quand on arrive au bout des instructions fournies, il faut reprendre au début.

Je décide de prendre un raccourci qui consiste à préparer une liste suffisamment longue d'instructions répétées, avec `reshape` qui a le comportement de répéter en boucle la liste qu'on lui fournit pour atteindre la longueur demandée :

```
↯ [10] 1_2_3
```

Ensuite, je n'ai plus qu'à aller chercher la première occurrence de `ZZZ` dans la liste de nœuds, ce que `indexof` fait très bien.

```
Parse ← (⊃(=@R °□ ⊢|≡(⊜∘ ≥0-@A. °□)↘ 1) ⊜□ ≠@\n.)
Step ← ⊡+1 ⊙(⊡ ⊗ ⊙(≡⊢.))
Walk ← (⊙; ∧(⊂: ⊃(Step ⊙(⊢⇌)|⋅⊙∘)) :["AAA"])
PartOne ← (
  Parse
  ↯[100] # on rallonge le programme en bouclant
  Walk
  ⊗ "ZZZ"
)

$ LLR
$
$ AAA = (BBB, BBB)
$ BBB = (AAA, ZZZ)
$ ZZZ = (ZZZ, ZZZ)

⍤⊃⋅∘≍ 6 PartOne
```

Bien sûr, un programme de 100 pas n'est pas suffisant pour atteindre `ZZZ` dans la vraie entrée. J'augmente progressivement la longueur et c'est quand j'arrive à `20000` que j'ai ma réponse qui est `18023`. Mais le programme met quand même plusieurs secondes à y arriver ! Bref, c'est pas terrible.

Tout ça parce que je n'ai pas voulu apprendre à utiliser `do`…

## Partie 2

Ça se complique, bien sûr. Maintenant il n'y a plus un seul nœud de départ mais plusieurs (ceux dont le nom se termine par `A`, il y en a 6 dans l'entrée) et plusieurs nœuds d'arrivée (se terminant par `Z`, 6 aussi).

L'énoncé parle de fantômes qui partent simultanément de tous les nœuds de départ, et exécutent tous le programme de façon synchronisée. On me demande au bout de combien de pas ces fantômes seront tous sur un nœud d'arrivée au même moment — sachant que si un fantôme passe sur un nœud d'arrivée mais que ses collègues ne sont pas à ce moment-là aussi sur un nœud d'arrivée, il continue comme si de rien n'était.

Avant de me lancer là-dedans je décide d'améliorer mon code de la première partie. Je me dis que s'il met plusieurs secondes à résoudre le trajet d'un seul fantôme, alors ça va être pénible de lui faire tracer plusieurs trajets, d'autant que je m'attends à un grand nombre de pas avant qu'ils soient tous arrivés.

### Partie 1 bis

La première chose à laquelle je pense, c'est que ma recherche dans la table de liens n'est pas du tout efficace : à chaque pas je dois parcourir la table jusqu'à trouver le triplet dont le premier élément correspond au nœud courant. Si je pouvais numéroter les nœuds, ce serait plus rapide.

Du coup je modifie `Parse`. Je remplace déjà mon extraction des noms de nœuds, qui cherchait des caractères alphabétiques, par une extraction des caractères par position : en effet le nouvel exemple contient des chiffres dans les noms de nœuds.

Ensuite je convertis la table de liens pour remplacer chaque nom de nœud par son indice dans la table des noms.

```
Parse ← (
  ⊜□≠@\n. # découpage en lignes
  ⊃(
    =@R °□ ⊢ # première ligne = le programme
  | ↘ 1      # sauter la première ligne
    ≡(
      °□
      ⊃(
        ↙3                # le nom du nœud
        | [⊃(↙3↘7|↙3↘12)] # les liens à gauche et à droite
      )
    )
    # on a maintenant 2 listes sur la pile :
    # - celle des paires de liens
    # - (au sommet) celle des noms de nœuds
    ⊃(
      ∘  # on copie la liste de noms telle quelle
    | :¤ # et on l'utilise
      ≡⊗ # pour convertir les noms dans les liens
      ⍉  # qu'on transpose en deux lignes
    )
  )
)

$ LR
$
$ 11A = (11B, XXX)
$ 11B = (XXX, 11Z)
$ 11Z = (11B, XXX)
$ 22A = (22B, XXX)
$ 22B = (22C, 22C)
$ 22C = (22Z, 22Z)
$ 22Z = (22B, 22B)
$ XXX = (XXX, XXX)
Parse
```

Il me faut une fonction pour trouver les nœuds de départ et d'arrivée dans la table des nœuds. D'ailleurs c'est la seule utilisation que j'aurai de cette table : je vais la convertir en une liste de nœuds de départ, et une liste de nœuds d'arrivée.

Déjà pour la partie 1 où ils sont nommés `AAA` et `ZZZ` :

```
FindSingleStartEnd ← (
  ⊃(
    ⊗"AAA"  # indice du nœud de départ
  | ¤⊗"ZZZ" # indices des nœuds d'arrivée
  )
)

["BBB" "AAA" "ZZZ" "CCC"]
FindSingleStartEnd
```

La nouvelle structure de pile sera donc la suivante (du bas vers le haut) :
* au fond, la table des liens (deux lignes d'entiers) ;
* la liste des nœuds d'arrivée (une liste d'entiers) ;
* le nœud en cours (un entier) ;
* le programme à exécuter (une liste de `0` et `1`).

Pour utiliser cette nouvelle structure de pile je dois modifier `Step` (qui reçoit une instruction, le nœud en cours, la liste d'arrivées et la table des liens)  :

```
Step ← (
  ⊃(
    ⋅∘    # récupérer le nœud courant
  | ⊡⊙⋅⋅∘ # trouver la bonne ligne dans la table de liens
  )
  ⊡ # chercher le nœud cible dans la ligne de liens
)

[[1 2] [2 3]] # table des liens
[1]           # liste des nœuds d'arrivée
0             # nœud courant
1             # instruction (0=L, 1=R)
Step          # renvoie le nouveau nœud
```

`Walk` a aussi besoin d'une retouche. On va supposer que le nœud de départ est déjà en place sous le programme.

On va aussi remplacer ce vilain `fold` par un `do`. `do` attend deux fonctions :
* la première va être exécutée,
* puis la deuxième va être exécutée pour déterminer si la boucle doit continuer (si elle renvoie `1`) ou s'arrêter (si elle renvoie `0`) ;
* et ainsi de suite.

Pour être précis, il me semble que la deuxième fonction est exécutée en premier et si elle renvoie `0`, on n'exécute jamais la première. Mais ça n'a pas beaucoup d'importance ici.

La fonction que je veux exécuter en boucle, c'est à peu près `Step`. Mais `Step` a besoin d'une instruction, prise dans le programme. `fold` itérait automatiquement sur les instructions du programme, mais `do` ne fait rien de tel.

Je vais donc ajouter sur la pile un compteur de programme, qui commencera à `0` et sera incrémenté à chaque itération. Ensuite, pour trouver l'instruction à exécuter il me suffira d'aller indexer le programme, en m'assurant d'appliquer un `modulus` pour faire "boucler" le programme.

L'avantage du compteur de programme, c'est qu'en fin d'exécution il me donnera directement le nombre de pas effectué.

Je crée une fonction `ProgramStep` qui sera le corps de mon `do`. Pour mémoire, quand on l'appellera on aura sur la pile :
* au fond, la table des liens (deux lignes d'entiers) ;
* la liste des nœuds d'arrivée (une liste d'entiers) ;
* le nœud en cours (un entier) ;
* le programme à exécuter (une liste de `0` et `1`) ;
* au sommet, le compteur de programme (un entier).

Je vais faire en sorte que cette fonction préserve cette structure de pile, afin qu'elle puisse être appelée de façon répétée.

```
Step ← ⊡ ⊃(⋅∘|⊡⊙⋅⋅∘)
ProgramStep ← (
  ⊃(
    +1    # on incrémente le compteur de programme
    ⊙∘    # on conserve le programme
  | ⧻,    # on récupère la longueur du programme
    ◿     # on applique un modulo au compteur
    ⊡     # on récupère l'instruction à exécuter
    Step  # on l'exécute, ce qui donne le nouveau nœud
  | ⋅⋅⋅⊙∘ # on recopie la liste d'arrivées et les liens
  )
)

[[1 2] [2 3]] # table des liens
[1]           # liste des nœuds d'arrivée
0             # nœud courant
[0 1]         # programme
0             # compteur de programme
ProgramStep   # première exécution
?             # affichage de la pile
ProgramStep   # une deuxième exécution fonctionne
```

On y est presque, il faut s'occuper de la deuxième fonction du `do`, celle qui détermine si l'itération doit continuer. Ici, je veux qu'elle continue si le nœud en cours n'est pas dans la liste des nœuds d'arrivée (qui va enfin servir !).

Je crée la fonction `EndReached`. Elle sera invoquée avec la même pile que `ProgramStep`, mais elle n'a pas besoin de préserver la pile car `do` s'en occupe. Elle peut donc simplement faire sauter les deux entrées du haut de la pile (le compteur de programme et le programme) avec un double `gap` puis appliquer `member` pour chercher le nœud courant dans la liste des nœuds d'arrivée :

```
EndReached ← ⋅⋅∊

[[1 2] [2 3]] # table des liens
[1]           # liste des nœuds d'arrivée
1             # nœud courant
[0 1]         # programme
0             # compteur de programme
EndReached
```

Voilà, maintenant `Walk` s'exprime tout simplement :


```
Step ← ⊡ ⊃(⋅∘|⊡⊙⋅⋅∘)
ProgramStep ← ⊃(⊙∘ +1|Step ⊡◿⧻,|⋅⋅⋅⊙∘)
EndReached ← ⋅⋅∊
Walk ← (
  0 # compteur de programme initial
  ⍢ProgramStep (¬EndReached)
  # à la fin, on ne garde que le compteur de programme
  ⊙⋅⋅⋅;
)

[[1 2] [2 3]] # table des liens
[3]           # liste des nœuds d'arrivée
0             # nœud courant
[0 1]         # programme
Walk          # se termine en 2 pas
```

Voilà, tout ça me permet d'écrire une `PartOne` plus correcte :

```
Parse ← (⊃(=@R °□ ⊢|⊃(∘|⍉ ≡⊗:¤)  ≡(⊃(↙3|[⊃(↙3↘7|↙3↘12)]) °□)↘ 1) ⊜□≠@\n.)
Step ← ⊡ ⊃(⋅∘|⊡⊙⋅⋅∘)
ProgramStep ← ⊃(⊙∘ +1|Step ⊡◿⧻,|⋅⋅⋅⊙∘)
EndReached ← ⋅⋅∊
Walk ← ⊙⋅⋅⋅;  ⍢ProgramStep (¬EndReached) 0
FindSingleStartEnd ← ⊃( ⊗"AAA" | ¤⊗"ZZZ" )

PartOne ← (
  Parse
  ⊙FindSingleStartEnd
  Walk
)

$ LLR
$
$ AAA = (BBB, BBB)
$ BBB = (AAA, ZZZ)
$ ZZZ = (ZZZ, ZZZ)
⍤⊃⋅∘≍ 6 PartOne
```

### La vraie Partie 2

Je me lance dans une implémentation compliquée qui simule le parcours simultané des multiples fantômes à travers le graphe. Pour représenter la position des différents fantômes, je choisis un vecteur booléen qui contient un `1` pour chaque nœud actuellement occupé par un fantôme. Et pour faire avancer la simulation, je construis une matrice booléenne à partir de la table des liens : à chaque étape, le nouveau vecteur d'état est donc obtenu en combinant les lignes de la matrice sélectionnées par le vecteur actuel. Une sorte de multiplication matrice-vecteur, finalement.

C'est une solution assez élégante qui me permettrait par exemple de connaître l'état du système au bout d'un très grand nombre d'itérations, en appliquant une exponentiation rapide à la matrice.

Le problème, c'est que ce n'est pas la question qui est posée ! Et quand je fais tourner ma simulation, je vois régulièrement des fantômes passer par un nœud `Z` mais je vois bien qu'on est loin d'arriver à une étape où ils sont tous simultanément sur un nœud `Z`.

À court d'idées je tente une visualisation de l'entrée avec [Graphviz](https://graphviz.org) :

![](day8.svg)

Et je comprends alors à quel point l'entrée est spécifiquement construite pour que les fantômes se déplacent chacun sur leur propre circuit. Et il semble logique que les fantômes visitent leur nœud `Z` respectif à intervalle régulier.

Si chaque fantôme visite un nœud `Z` à un certain intervalle, le moment où ils seront tous en même temps sur un nœud `Z` sera donné par le plus petit multiple commun (PPCM) des longueurs de cycles.

Il me suffit donc de mesurer ces longueurs de cycles en simulant chaque fantôme suffisamment longtemps pour qu'il arrive à son nœud `Z`, et de prendre ensuite le PPCM de ces longueurs.

Je me débarrasse donc de toute mon implémentation à base de matrice pour reprendre ma simulation simple, j'ajoute un calcul de PPCM et j'ai enfin ma réponse.

```
# input -- program namelist links
Parse ← (
  ⊜□ ≠@\n. # split lines
  ⊃(
    °□ ⊢ # get program line
    =@R  # convert program to 0/1
  | ↘1   # drop program line
    # extract node names and links
    ≡(
      °□
      ⊃(
        ↙3                # node name
        | [⊃(↙3↘7|↙3↘12)] # left and right links
      )
    )
    ⊃(
      ∘  # keep name list for later
    | :¤ # fix name list
      ≡⊗ # lookup left & right node names
      ⍉  # put in rows
    )
  )
)

# instr node endnodes links -- newnode endnodes links
ExecuteInstruction ← (
  ⊃(
    ⊃(
      ⋅∘    # get current node
    | ⊡⊙⋅⋅∘ # pick link row from instruction
    )
    ⊡    # lookup target node
  | ⋅⋅⊙∘ # keep end list and links
  )
)

# node endnodes -- bool
EndReached ← ∊

# pc program node ends links -- pc+1 program newnode endnodes links
ProgramStep ← (
  ⊃(
    +1 # increment program counter
    ⊙∘ # keep program
  | ⧻, # get program length
    ◿  # pc mod program length
    ⊡  # get instruction
    ExecuteInstruction
  )
)

# namelist -- startnodes endnodes
FindMultiStartEnd ← (
  ≡(⊢⇌) # last letter of each name
  ⊃(
    ⊚=@A # indices of start nodes
  | ⊚=@Z # indices of end nodes
  )
)

# program, startnode, endnodes, links
WalkToEnd ← (
  0 # program counter
  ⍢ProgramStep (¬⋅⋅EndReached)
  ⊙⋅⋅⋅; # drop state
)

# program, startnodes, endnodes, links
FindPeriods ← (
  ⊓(¤|∘|¤|¤) # fix program, endnodes, links
  ≡WalkToEnd # run program for each startnode
)

GCD ← ;⍢(
  ⊃↧↥ # put smaller number on top
  ⊃◿∘ # remove smaller from larger
) (≠0)
LCM ← ×÷GCD,, # lcm(a,b) = ab/gcd(a,b)

PartTwo ← (
  Parse
  ⊙FindMultiStartEnd
  FindPeriods
  /LCM
)

$ LR
$
$ 11A = (11B, XXX)
$ 11B = (XXX, 11Z)
$ 11Z = (11B, XXX)
$ 22A = (22B, XXX)
$ 22B = (22C, 22C)
$ 22C = (22Z, 22Z)
$ 22Z = (22B, 22B)
$ XXX = (XXX, XXX)
⍤⊃⋅∘≍ 6 PartTwo
```

##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) 8 [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
