## Partie 1

Aujourd'hui j'ai voulu essayer quelque chose de différent : ne pas écrire ce journal pendant que j'essayais de résoudre le problème, le plus vite possible.

Le résultat n'est pas une réussite. J'ai l'impression d'avoir été inefficace sur la première partie, et mon code pour la deuxième partie est encore en train de tourner, donc…

Bref, l'énoncé me donne ces données d'exemple :

```no_run
$ RL
$
$ AAA = (BBB, CCC)
$ BBB = (DDD, EEE)
$ CCC = (ZZZ, GGG)
$ DDD = (DDD, DDD)
$ EEE = (EEE, EEE)
$ GGG = (GGG, GGG)
$ ZZZ = (ZZZ, ZZZ)
```

La première ligne est une liste d'instructions (R=aller à droite, L=aller à gauche).

Les autres lignes sont une liste de nœuds nommés `AAA`, `BBB`, etc. et pour chacun on nous indique quel nœud est atteint en allant à gauche, et quel nœud est atteint en allant à droite.

Pour la lecture de l'entrée, pas de difficulté particulière. Je remplace `L` par `0` et `R` par `1` avec `=@R`. Et pour les autres lignes, je crée des tableaux de 3 lignes contenant le nom du nœud de départ et les noms des 2 nœuds connectés.

```
Parse ← (
  ≠@\n.
  ⊜□
  ⊃(
    °□ ⊢
    =@R
  | ↘ 1
    ≡(
      °□
      ≥0-@A.
      ⊜∘
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
