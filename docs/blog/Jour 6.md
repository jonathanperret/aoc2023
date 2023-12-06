## Ce que j'ai retenu des épisodes précédents

Ne pas faire confiance à des estimations de complexité faites au doigt mouillé ?

Aussi, certaines des solutions Uiua au problème d'hier que j'ai vues m'ont montré s'il était nécessaire la marge de progression que j'ai.

## Partie 1

On me donne une liste de temps et des distances correspondantes :

```no_run
$ Time:      7  15   30
$ Distance:  9  40  200
```

Je regarde vite fait, l'entrée complète n'est étonnamment pas beaucoup plus grosse que l'exemple :

```no_run
$ Time:        46     82     84     79
$ Distance:   347   1522   1406   1471
```

Il s'agit d'une série de courses de bateaux miniatures. Dans chaque course (une colonne de l'entrée) je peux choisir combien de temps je fais accélérer le bateau au début de la course (1 milliseconde d'accélération = 1 millimètre par milliseconde en plus) et ensuite le bateau va passer le temps restant à avancer. Une course n'est gagnée que si le bateau a parcouru une distance supérieure au record indiqué.

On me demande combien de façons (temps d'accélération) il y a de gagner chaque course.

### Lecture de l'entrée

Ça ne devrait pas être trop compliqué.

```
$ Time:      7  15   30
$ Distance:  9  40  200
Parse = ⍉⊜(⊜parse ∊:"0123456789".)≠@\n.
```

### Exécution

Au vu des valeurs dans l'entrée, je ne vois pas pourquoi je ferais autre chose qu'une énumération des temps possibles.

Un bateau chargé `t` millisecondes partira avec une vitesse de `t` millimètres par milliseconde, il couvrira donc la distance demandée `d` en `d ÷ t` millisecondes. Son temps total sera donc `t + ⌈(d ÷ t)` millisecondes.

Bon, ça se passe assez vite :

```
TimeFor ← (
  # chargeTime targetDistance
  ⊃∘(⌈÷)
  # chargeTime timeToDestination
  +
)

CountWays ← (
  ⍘⊟
  .
  ⊙(
    ⊓(+1⇡-1|+1¤)
    ≡TimeFor
  )
  /+≤
)

PartOne ← (
  Parse
  ≡CountWays
  /×
)

$ Time:      7  15   30
$ Distance:  9  40  200
⍤⊃⋅∘≍ 288 PartOne
```

