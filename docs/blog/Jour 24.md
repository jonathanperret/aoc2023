## Partie 1

C'est pas encore tout à fait Noël et pour mériter ses cadeaux, il reste encore un paquet de lignes dont il faut trouver les intersections :

```no_run
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
```

Ces droites sont données par un point et un vecteur ; il faut trouver leurs points d'intersection deux à deux (s'ils existent) et vérifier si ces points sont bien dans la direction du vecteur sur chaque droite, et de plus s'ils sont dans une région de l'espace donnée (dans l'exemple, `X` et `Y` entre `7` et `27` ; pour le vrai problème, c'est entre `200000000000000` et `400000000000000`).

Ah, et au moins pour la première partie, on ignore les coordonnées `Z`.

Il y a `300` droites dans l'entrée complète. Avec une approche très naïve, ça me fait `90000` intersections à tester, ça devrait aller.

Tiens, je note qu'il n'y a pas de `0` dans les coordonnées des vecteurs, ça enlève potentiellement des cas pénibles.

L'implémentation se passe assez agréablement, c'est un problème assez "uiuable" comme on dit dans la communauté. Je choisis de calculer le point d'intersection de chaque paire pour ensuite vérifier qu'il est dans la zone et du bon côté de chaque point de départ (pour satisfaire la contrainte que l'intersection potentielle soit "dans le futur"). Je choisis aussi de ne pas optimiser pour éviter de comparer chaque paire deux fois, je divise juste le résultat final par 2. J'utilise `cross` qui est très pratique pour les produits cartésiens comme ça.

Le temps d'exécution est très raisonnable (moins d'une seconde).

```
Parse ← ↯¯1_2_3 ⊜⋕¬∊:", @\n".
StripZ ← ⍜°⍉(↙2)

Cross ← /-×⇌

Intersect ← (
  ∩°⊟ # -- p1 v1 p2 v2
  ⊃(
    Cross ⋅⊙⋅∘ # denom = v1 cross v2
  | Cross -⊙⋅∘ # v2 cross (p2 - p1)
  | :          # v1 p1
  )
  # t = v2 cross (p2 - p1) / denom
  ÷
  # poi = p1 + t*v1
  +×
)

# ( min max [ p1 v1 ] [ p2 v2 ] -- ok )
IntersectOK ← (
  ⊙⊙⊃(Intersect|∩(⊙±°⊟⊢⍉))
  # -- min max poi p1.x sign(v1.x) p2.x sign(v2.x)
  ⊃(
    # poi >= min
    /↧≥⊙⋅∘
  | # poi <= max
    /↧≤⋅⊙∘
  | # sign(poi.x-p1.x) == sign(v1.x)
    ⋅⋅⊙∘
    =±-:⊢
  | # sign(poi.x-p2.x) == sign(v2.x)
    ⋅⋅⊙⋅⋅⊙∘
    =±-:⊢
  )
  ↧∩↧ # and it all
)

PartOne ← (
  ⊃(⋅⋅∘|⊙∘)
  Parse
  StripZ
  ⊠(IntersectOK ⊃(⋅⋅⊙∘|⊙∘)).
  ÷2/+♭
)

$ 19, 13, 30 @ -2,  1, -2
$ 18, 19, 22 @ -1, -1, -2
$ 20, 25, 34 @ -2, -2, -4
$ 12, 31, 28 @ -1, -2, -1
$ 20, 19, 15 @  1, -5, -3
⍤⊃⋅∘≍ 2 PartOne 7 27
```
