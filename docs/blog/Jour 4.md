# Jour 4

## Ce que j'ai retenu des épisodes précédents

Ça prend vraiment du temps d'écrire ce journal ! D'autant que je le fais essentiellement après avoir terminé de résoudre les problèmes. Je vais tenter de noter plus au fil de l'eau, et probablement alléger le niveau de détail pour que ça reste faisable.

## Partie 1

Je prends le téléphérique. Et me voilà sur une ile au climat tropical ? Ah mais bien sûr, c'est l'île Île. Il faut que j'emprunte un bateau pour aller trouver le jardinier, sur une autre île. Et pour ça, je dois aider un Elfe à faire le tri dans ses cartes à gratter.

Bref, on est lundi.

Voici un exemple d'entrée :

```no_run
$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
```

Sur chaque carte, à gauche on a une liste des numéros gagnants, et à droite les numéros joués. La valeur d'une carte est 2^[nombre de "bons" numéros moins 1].

C'est parti pour la lecture des lignes.

```
ParseCard ← (
  ↘+1⊗@:. # on enlève les caractères jusqu'au ":"
  ≠@|.    # on détecte ce qui n'est pas "|"
  ⊜(
    ⊜⋕ ≠@\s. # on lit les séquences de chiffres
    □            # qu'on met en boîte pour cohabiter
  )
)

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53

ParseCard
```

et bien sûr :

```
ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜⋕ ≠@\s.
    □
  )
)
Parse ← (
  ≠@\n.
  ⊜ParseCard
)

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

Parse
```

OK, maintenant il faut faire correspondre la droite avec la gauche, j'utilise `member`.

```
ScoreCard ← (
  ⊃(°□⊡1|°□⊢) # on sort les deux tableaux de leurs boîtes
  ⊙¤        # on "fixe" le tableau de droite pour qu'il soit constant
  ≡∊        # …pendant l'itération sur le tableau de gauche
  /+        # on additionne pour savoir combien sont trouvés
  -1        # hop, moins un
  ⁿ:2       # et 2^x (avec un `: flip` pour ne pas faire x^2)
)

{41_48_83_86_17 83_86_6_31_17_9_48_53}

ScoreCard
```

Ah, quand la liste est vide il faut compter 0 points, pas 2 puissance -1 qui fait 0,5. Un petit `floor` et il n'y paraîtra plus.

```
ScoreCard ← (
  ⊃(°□⊡1|°□⊢)
  ≡∊ ⊙¤
  -1/+
  ⁿ:2
  ⌊
)

{41_48_83_86_17 1234}

ScoreCard
```

Et voici donc pour la première partie :

```
ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜⋕ ≠@\s.
    □
  )
)
Parse ← (
  ≠@\n.
  ⊜ParseCard
)
ScoreCard ← (
  ⊃(°□⊡1|°□⊢)
  ≡∊ ⊙¤
  -1/+
  ⁿ:2
  ⌊
)

PartOne ← (
  Parse
  ≡ScoreCard
  /+
)

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

⍤⊃⋅∘≍ 13 . PartOne
```

## Partie 2

Maintenant, les cartes se multiplient ?

### Résumé de l'énoncé

Si une carte a 5 numéros gagnants, on gagne une copie de chacune des 5 cartes qui la suivent.

Ah, les numéros des cartes entrent en jeu. Une carte copie toujours les cartes de numéros consécutifs à elle-même, même si des copies se sont insérées entre elle et ses suivantes.

On nous promet qu'une carte ne nous fera jamais copier de carte "inexistante".

Le processus de copie doit être répété jusqu'à ce qu'on ne gagne plus de cartes.

### Comment on va s'y prendre

Il y a 219 cartes dans l'entrée, chacune portant 25 numéros potentiellement gagnants. Je soupçonne qu'une approche naïve mène à une sorte d'explosion.

Je peux bien sûr commencer par lire les cartes et calculer pour chacune la liste des numéros de carte qu'elle fait gagner, donc pour `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53` ce sera `2_3_4_5`.

Je me retrouverai avec une liste comme ça :

```no_run
[
  2_3_4_5
  3_4
  4_5
  [5]
  []
  []
]
```

Et là, il faudrait faire une sorte de produit ?

Je ne veux pas réellement multiplier les instances de cartes en mémoire. Il devrait me suffire de maintenir une liste du nombre de chaque carte que je possède, qui commencerait avec des 1 partout :

```no_run
1_1_1_1_1_1
```

La résolution de la première carte ajouterait `1_1_1_1` à ce vecteur, mais à partir de la deuxième position :

```
1_1_1_1_1_1
0_1_1_1_0_0
+
```

La résolution de la deuxième carte ajouterait `2_2` (puisque j'ai maintenant 2 instances de la deuxième carte) en troisième position :

```
1_2_2_2_1_1
0_0_2_2_0_0
+
```

Et ainsi de suite.

Je me dis que lors de l'analyse initiale, j'aurais intérêt à calculer pour chaque carte le vecteur qu'elle ajoute, plutôt que les indices des cartes :

```
⬚0 [
  0_1_1_1_1_0
  0_0_1_1
  0_0_0_1_1
  0_0_0_0_1
  []
]
```

La magie de `fill` m'évitera d'avoir à remplir les vecteurs vers la droite.

### C'est parti

Calculons le vecteur d'une carte. C'est une variante de `ScoreCard` où on utilise `keep` plutôt que de calculer une puissance de 2.

```
ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜⋕ ≠@\s.
    □
  )
)

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
ParseCard

CardVector ← (
  ⊃(°□⊡1|°□⊢)
  ≡∊ ⊙¤
  ▽=1.
)
CardVector
```

Et pour l'ensemble du jeu, avec le `fill` qui va bien :

```
ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜⋕ ≠@\s.
    □
  )
)
Parse ← (
  ≠@\n.
  ⊜ParseCard
)
CardVector ← (
  ⊃(°□⊡1|°□⊢)
  ≡∊ ⊙¤
  ▽=1.
)
$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
Parse
⬚0≡CardVector
```

Ah oui mais il faut que je décale chaque vecteur vers la droite.

```
ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜⋕ ≠@\s.
    □
  )
)
Parse ← (
  ≠@\n.
  ⊜ParseCard
)
CardVector ← (
  ⊃(°□⊡1|°□⊢)
  ≡∊ ⊙¤
  ▽=1.
)

CardMatrix ← (
  +1⇡⧻.
  ⬚0≡(
    [⍥0]
    ⊙CardVector
    ⊂
  )
)

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

Parse
CardMatrix
```

Maintenant on peut passer à l'évaluation.

Il y a sûrement un truc intelligent à faire qui ramène le problème à une sorte de multiplication de matrices, mais je vais y aller tranquillement avec une liste des nombres de cartes, comme prévu.

Je veux garder en bas de la pile la matrice des cartes, et au-dessus la liste du nombre que j'ai de chaque carte, que j'initialise avec un `1` pour chaque carte (note : l'éditeur Uiua affiche la pile avec le haut en bas, donc quand je dis "en bas de la pile" il faut regarder le premier élément affiché) :

```
[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]
≡⋅1.
```

Pour évaluer l'effet de la première carte, je veux prendre le premier élément de mon vecteur de nombres de cartes (qui est sur le haut de la pile), multiplier ce nombre par la première ligne de la matrice, et enfin ajouter ce vecteur à mon vecteur de nombres. Sans oublier de commencer par dupliquer le vecteur accumulateur et la matrice, pour ne pas les perdre :

```
[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

[1 1 1 1 1 1]

,,
∩⊢
×
+
```

Pour évaluer l'effet de la deuxième carte, c'est presque pareil mais je dois remplacer les `first` par des `pick` `1` :

```
[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

[1 2 2 2 2 1]

,,
∩(⊡1)
×
+
```

Hmm. Ça marche, mais ça ne va pas être très pratique de transformer ce `pick` `1` en `pick` `2` etc. pour les tours suivants.

J'aimais bien mon itération avec `first`. Est-ce que je ne peux pas modifier les données à chaque étape pour que chaque étape n'ait besoin que d'un `first` ? En effet, après avoir résolu la première carte, je n'ai plus besoin de la première ligne ni de la première colonne de la matrice.

Mais j'ai besoin de me souvenir du nombre de copies de la première carte que j'ai obtenues, pour le score final. Sauf si j'accumule séparément ce score…

Jusqu'à présent, entre chaque itération sur la pile j'ai le vecteur de nombres de cartes suivi de la matrice (vecteur, matrice). Je décide d'ajouter en haut de la pile le score intermédiaire. Donc : score, vecteur, matrice.

Je reprends mon étape d'évaluation avec `first` ci-dessus, en l'enveloppant dans un `dip` pour ignorer le score qui est en haut de la pile :

```
[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

[1 1 1 1 1 1]

0

⊙(
  ,,
  ∩⊢
  ×
  +
)
```

Je peux maintenant éliminer la première ligne et colonne de la matrice, et le premier élément du vecteur, si je prends soin d'ajouter cet élément au score :

```
[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

[1 2 2 2 2 1]

0

  # en sautant le score...
⊙(
    # on va d'une part
  ⊃(
    ⊢ # prendre le premier élément du vecteur
      # et
  | ⊓(
      ↘1      # supprimer le premier élément du vecteur
    | ≡(↘1)↘1 # supprimer la première ligne et colonne de la matrice
    )
  )
)
+ # enfin on ajoute l'élément extrait au score

```

Si je combine cette étape à la précédente, j'obtiens une fonction que j'appelle `Step` :

```
Step ← (
  ⊙(
    +×∩⊢,,
    ⊃(⊢|⊓(↘1|≡(↘1)↘1))
  )
  +
)

[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

[1 1 1 1 1 1]

0

Step
```

Il me reste à appliquer cette fonction autant de fois qu'il y a de cartes (`length` appliqué au deuxième élément de la pile grâce à `,`), ce que permet `repeat` :

```
Step ← (
  ⊙(
    +×∩⊢,,
    ⊃(⊢|⊓(↘1|≡(↘1)↘1))
  )
  +
)

[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

[1 1 1 1 1 1]

0

⧻,
⍥Step
```

Je nettoie ensuite la pile avec `dip` (`pop` `pop`).

J'ajoute l'étape de préparation (initialiser le vecteur avec des `1` et le score à `0`), et j'appelle le tout `Run` :

```
Step ← (
  ⊙(
    +×∩⊢,,
    ⊃(⊢|⊓(↘1|≡(↘1)↘1))
  )
  +
)

Run ← (
  ≡⋅1.
  0

  ⧻,
  ⍥Step
  ⊙(;;)
)

[0_1_1_1_1_0
 0_0_1_1_0_0
 0_0_0_1_1_0
 0_0_0_0_1_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

Run
```

En combinant ça avec `Parse` et `CardMatrix` ça donne bien `PartTwo` :

```
ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜⋕ ≠@\s.
    □
  )
)
Parse ← (
  ≠@\n.
  ⊜ParseCard
)
CardVector ← (
  ⊃(°□⊡1|°□⊢)
  ≡∊ ⊙¤
  ▽=1.
)
CardMatrix ← (
  +1⇡⧻.
  ⬚0≡(
    [⍥0]
    ⊙CardVector
    ⊂
  )
)
Step ← (
  ⊙(
    +×∩⊢,,
    ⊃(⊢|⊓(↘1|≡(↘1)↘1))
  )
  +
)

Run ← (
  ≡⋅1.
  0

  ⧻,
  ⍥Step
  ⊙(;;)
)

PartTwo ← (
  Parse
  CardMatrix
  Run
)

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

⍤⊃⋅∘≍ 30 PartTwo
```

##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) 4 [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) [15](Jour%2015) [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
