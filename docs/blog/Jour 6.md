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

Ça ne devrait pas être trop compliqué. Noter l'utilisation de `transpose` à la fin.

```
Parse ← ⍉⊜(⊜parse ∊:"0123456789".)≠@\n.

$ Time:      7  15   30
$ Distance:  9  40  200
Parse
```

Si on veut s'amuser, il était aussi possible de l'écrire comme ceci :

```
Parse ← ⍉ ↯2_¯1 ⊜parse ∊:"0123456789".

$ Time:      7  15   30
$ Distance:  9  40  200
Parse
```

Ici on ne sépare même pas les lignes, on se contente d'isoler les groupes de chiffres avec `partition`, puis d'en faire classiquement des nombres avec `parse`, ce qui nous donne une liste de tous les entiers trouvés soit `[7 15 30 9 40 200]` ; on utilise ensuite `reshape` avec l'argument `2_¯1`, ce qui lui demande de former un tableau de `2` lignes avec autant de colonnes que nécessaire pour utiliser les valeurs présentes dans le tableau. On finit encore par un `transpose` pour obtenir notre liste de paires.

### Exécution

Au vu des valeurs dans l'entrée, je ne vois pas pourquoi je ferais autre chose qu'une énumération des temps possibles.

Un bateau chargé `t` millisecondes partira avec une vitesse de `t` millimètres par milliseconde, il couvrira donc la distance demandée `d` en `d ÷ t` millisecondes. Son temps total sera donc `t + ⌈(d ÷ t)` millisecondes.

Bon, ça se passe assez vite. Je commencer par écrire une fonction `TimeFor` qui étant donné un temps de charge et une distance à parcourir, donne le temps total écoulé :

```
TimeFor ← (
  ⊃∘(⌈÷) # on garde le temps de charge,
  # et comme c'est aussi la vitesse on divise la distance par lui
  + # plus qu'à faire la somme des deux temps
)
TimeFor 3 10
```

Ensuite j'énumère les temps de charge possible, de `1` au temps disponible, pour faire une distance supérieure de `1` au record :

```
TimeFor ← +⊃∘(⌈÷)

CountWays ← (
  ⍘⊟
  ⊃(
    ∘ # on garde le temps total
  | ⊓(
      +1⇡ # intervalle de 1 jusqu'au temps total
    | ¤+1 # distance supérieure au record, fixée pour l'itération qui suit
    )
    TimeFor # on calcule le temps de parcours pour chaque temps de charge possible
  )
  ≤  # on compare chaque temps de parcours au temps disponible
  /+ # on compte combien sont possibles
)
CountWays 7_9
```

Détail amusant, j'avais initialement écrit `rows``TimeFor` pour appliquer `TimeFor` à chacune des courses de la liste, mais comme `TimeFor` n'utilise que des opérations _pervasives_, c'est-à-dire qu'elles s'appliquent aussi bien à un tableau qu'à un nombre, je peux me passer de `rows` !


Plus qu'à faire le produits de ces nombres de possibilités, comme demandé, et ça fait `PartOne` :

```
Parse ← ⍉⊜(⊜parse ∊:"0123456789".)≠@\n.
TimeFor ← +⊃∘(⌈÷)
CountWays ← /+ ≤ ⊃(∘|TimeFor ⊓(+1⇡|¤+1)) ⍘⊟
PartOne ← /× ≡CountWays Parse

$ Time:      7  15   30
$ Distance:  9  40  200
⍤⊃⋅∘≍ 288 PartOne
```

Pas possible ici de se passer de `rows`, car `CountWays` utilise au moins une opération non pervasive qui est `range`.

# Partie 2

Alors le loup c'est qu'il ne fallait pas lire plusieurs colonnes de nombres mais une seule en ignorant les espaces, donc ceci :

```
$ Time:      7  15   30
$ Distance:  9  40  200
```

Décrit une seule course de 71530 millisecondes avec une distance record de 940200 millimètres.

Il faut donc refaire le _parsing_. Je m'en sors en remplaçant `partition``parse` par `parse``keep` :

```
ParseTwo ← ⊜(parse ▽ ∊:"0123456789".)≠@\n.
$ Time:      7  15   30
$ Distance:  9  40  200
ParseTwo
```

Évidemment, je peux essayer d'appliquer la même logique que pour la première partie, et ça va marcher sur l'exemple :

```
ParseTwo ← ⊜(parse ▽ ∊:"0123456789".)≠@\n.
TimeFor ← +⊃∘(⌈÷)
CountWays ← /+ ≤ ⊃(∘|TimeFor ⊓(+1⇡|¤+1)) ⍘⊟
PartTwo ← CountWays ParseTwo

$ Time:      7  15   30
$ Distance:  9  40  200
⍤⊃⋅∘≍ 71503 PartTwo
```

Mais bien sûr, le nombre de possibilités à tester dans l'entrée complète (de `1` à `46828478` millisecondes) va être trop grand pour… ah non, c'est déjà fini, en 21 secondes et c'est la bonne réponse.
