## Partie 1

Un dirigeable me dépose au bord d'un désert.

Une Elfe m'emmène sur un chameau et me propose de jouer aux cartes pendant le trajet.

Le jeu, c'est un peu comme le poker : on a chacun 5 cartes en main, et la main la plus forte (selon un ensemble de règles à venir) gagne le montant mis en jeu.

En entrée j'ai une liste de mains et les montants associés :

```no_run
$ 32T3K 765
$ T55J5 684
$ KK677 28
$ KTJJT 220
$ QQQJA 483
```

La règle, c'est que la main la plus faible gagne le montant indiqué en face, la deuxième gagne le double, etc. jusqu'à la plus forte qui gagnera (ici) 5 fois son montant.

Donc il s'agit d'abord de trier ces mains.

Comme au poker, on peut d'abord ranger les mains par type :
* 5 cartes identiques
* 4 cartes identiques
* un full : 3 et 2 cartes identiques
* brelan : 3 carte identiques
* double paire
* une paire
* 5 cartes différentes

Quand deux mains sont du même type on compare les cartes par ordre décroissant (attention : je me rends compte [plus tard](#changement-de-règles-?) que j'ai imaginé cette règle d'ordre décroissant). Attention, il y a une simplification par rapport au poker (en plus du fait que les cartes n'ont pas de couleur) : si elle a lieu, la comparaison ne tient pas compte du type de main à comparer, donc (cet exemple est donné dans l'énoncé), le full `77788` est plus fort que le full `88877`.

Bon, j'ai envie de commencer par vérifier que je peux faire un tri lexicographique avec Uiua :

```
Sort ← ⊏⍏.

[1_2_5 1_2_3 1_2_4]
Sort
```

`rise` a l'air de faire ce que je veux, très bien.

Si j'ajoute au début de chaque main un nombre correspondant à sa catégorie, ça devrait résoudre le problème.

Pour catégoriser une main, je sens que `classify` va enfin devenir utile.

```
2_3_10_3_13
⊛.
```

Une fois que chaque carte est dotée d'un indice de groupe, je peux utiliser `group` qui va rassembler les cartes de même indice et appeler sur chaque groupe la fonction que je lui passe, en l'occurrence `length` puisque seule la longueur de chaque groupe m'intéresse.

```
2_3_10_3_13
⊛.
⊕⧻
```

Enfin, je veux avoir les tailles de groupes triées par ordre décroissant :

```
Sort ← ⊏⍏.

2_3_10_3_13
⊛.
⊕⧻
⇌Sort
```

Et pour que les choses soient bien ordonnables, je voudrais compléter cette liste de tailles de groupes par des `0` afin d'avoir toujours 5 tailles. Je fais ça avec `reshape` et j'appelle le tout `Groups` :

```
Sort ← ⊏⍏.

Groups = (
  ⊛.
  ⊕⧻
  ⇌Sort
  ⬚0↯ [5]
)

Groups 3_2_10_3_13
```

Finalement, au lieu de numéroter les catégories, je me dis que je peux aussi bien trier leur liste de groupes lexicographiquement, c'est-à-dire que `3_2_0_0_0` (un full) viendra naturellement après `3_1_1_0_0` (un brelan).

Et comme en cas de catégorie égale, il faut comparer les cartes, il devrait suffire de préfixer chaque main par sa liste de groupes.

```
Sort ← ⊏⍏.
Groups ← ⬚0↯ [5]  ⇌Sort  ⊕⧻  ⊛  .
AddGroups ← (
  .
  Groups
  ⊂
)
AddGroups 3_2_10_3_13
```

Pour trier une liste de mains, il suffit d'appliquer `AddGroups` à toutes puis `Sort` :

```
Sort ← ⊏⍏.
Groups ← ⬚0↯ [5]  ⇌Sort  ⊕⧻  ⊛  .
AddGroups ← ⊂ Groups .

[3_2_10_3_13 10_5_5_11_5 13_13_6_7_7]
≡AddGroups .
Sort
```

Mais attention, ce sont les mises que je veux trier par l'ordre des mains. Je ne vais donc pas trier celles-ci direcetement mais appliquer `rise` qui me donnera la liste des indices dans le bon ordre pour trier le tableau des mises, et j'appelle ça `SortByHands` :

```
Sort ← ⊏⍏.
Groups ← ⬚0↯ [5]  ⇌Sort  ⊕⧻  ⊛  .
AddGroups ← ⊂ Groups .
SortByHands ← (
  ≡AddGroups
  ⍏
  ⊏
)


765_684_28
[3_2_10_3_13 10_5_5_11_5 13_13_6_7_7]
SortByHands
```

Maintenant que les mises sont triées par ordre croissant des mains, je dois appliquer une multiplication par leur indice en commençant par 1, puis faire la somme, j'appelle ça `ScoreGame` :

```
ScoreGame ← (
  +1⇡⧻.
  ×
  /+
)

765_28_684
ScoreGame
```

Je me suis gardé le `parsing` pour la fin. Ça ne devrait pas être bien sorcier, grâce à `indexof` :

```
ParseHand ← ⊗:"0123456789TJQKA"
$ 32T3K
ParseHand
```

Enfin c'est un découpage classique par ligne et colonne. Noter que si la fonction passée à `partition` renvoie deux valeurs, on aura deux listes en sortie de `partition`. C'est exactement ce que je veux, ça tombe bien.

```
ParseHand ← ⊗:"0123456789TJQKA"
Parse ← ⊜(⊓ParseHand parse ⊃(↙5|↘6)) ≠@\n.

$ 32T3K 765
$ T55J5 684
$ KK677 28
$ KTJJT 220
$ QQQJA 483
Parse
```

Un apprentissage de ces derniers jours avec Uiua, c'est qu'il est généralement plus intéressant de séparer les données de différents types (ici, les mains et les mises) en différents tableaux, au lieu d'essayer de faire un unique tableau contenant des "structures" hétérogènes, ce qui impliquerait nécessairement des `box` à n'en plus finir.

Je combine tout ça et ça me fait `PartOne` :

```
Sort ← ⊏⍏.
Groups ← ⬚0↯ [5]  ⇌Sort  ⊕⧻  ⊛  .
AddGroups ← ⊂ Groups .
SortByHands ← ⊏ ⍏ ≡AddGroups
ScoreGame ← /+ × +1⇡⧻.
ParseHand ← ⊗:"0123456789TJQKA"
Parse ← ⊜(⊓ParseHand parse ⊃(↙5|↘6)) ≠@\n.
PartOne ← (
  Parse
  SortByHands
  ScoreGame
)

$ 32T3K 765
$ T55J5 684
$ KK677 28
$ KTJJT 220
$ QQQJA 483

⍤⊃⋅∘≍ 6440 PartOne
```

## Partie 2

Ah, `J` est maintenant un joker. C'est-à-dire qu'elle peut prendre la valeur de n'importe quelle autre carte quand il s'agit de déterminer la catégorie de la main.

En revanche, quand deux mains sont de la même catégorie et qu'elles doivent donc être comparées selon les hauteurs de cartes, `J` est la carte la plus faible, donc de valeur 1.

Je commence par modifier le _parser_ pour attribuer la valeur `1` à `J` :

```
ParseHandTwo ← ⊗:"0J23456789TQKA"

$ T55J5
ParseHandTwo
```

OK, maintenant pour déterminer le type d'une main je voudrais essayer toutes les hauteurs possibles pour `J` et retenir la meilleure catégorie. Je fais l'hypothèse que si on a plusieurs `J` en main, on a toujours intérêt à chosir la même valeur pour les deux.

Pour remplacer les occurrences de `1` par un autre nombre déjà, je peux utiliser `under``keep` :

```
1_5_5_1_5
=1.
⍜▽(≡(12;))
```

Ici on commence par trouver les positions des `1` dans la liste avec `=1.`, ce qui donne `1_0_0_1_0`.  Puis `under` commence par appliquer `keep` ce qui ramène la liste à `1_1`. On veut ensuite remplacer tous ces `1` par `12`, ce qu'on obtient avec la fonction constante `≡(12;)`.

La difficulté suivante c'est que je veux faire la même opération avec d'autres valeurs que `12`. Pour commencer il faut donc que j'arrive à sortir ce `12` de sa proximité avec `keep`, ce qui me demande quelques tâtonnements mais j'arrive à ça :

```
1_5_5_1_5
=1.
12
⍜(⊙▽∘)≡(⊓∘;)
```

Maintenant que la valeur de substitution est prise sur la pile, je peux parcourir une série de ces valeurs avec `rows`, en ayant pris soin de `fix`er les deux autres valeurs (`1_5_5_1_5` et le résultat de `=1.`) avec `both``fix`, puisqu'elles doivent être constantes pendant l'itération :

```
1_5_5_1_5
=1.
∩¤
11_12_13
≡(
  ⍜(⊙▽∘)≡(⊓∘;)
)
```

J'appelle ça `SubAllJokers` :

```
SubAllJokers ← (
  =1.
  ∩¤
  +2⇡12
  ≡(
    ⍜(⊙▽∘)≡(⊓∘;)
  )
)

1_5_5_1_5
SubAllJokers
```

Maintenant il faut que parmi ces mains accessibles par substitution de jokers, je trouve le meilleur type. Ça se fait bien en appliquant `Groups` à chaque main possible, puis je trie cette liste par ordre croissant et j'en prends le premier. J'appelle ça `BestGroups` :

```
Sort ← ⊏⍏.
Groups ← ⬚0↯ [5]  ⇌Sort  ⊕⧻  ⊛  .
SubAllJokers ← ≡(⍜(⊙▽∘)≡(⊓∘;)) +2⇡12 ∩¤ =1.
BestGroups ← (
  SubAllJokers
  ≡Groups
  .
  ⍖
  ⊢
  ⊡
)
1_5_5_1_5
BestGroups
```

La suite est identique à la première partie : je préfixe chaque main par sa catégorie donnée par `BestGroups`, et je n'ai plus qu'à calculer le score de la partie.

### Changement de règles ?

Au dernier moment, je suis pris d'un doute : quand deux mains sont du même type, est-ce que j'ai bien pensé à trier les cartes de chaque main par ordre décroissant avant de trier les mains ? Par exemple, est-ce que je vérifie bien que `1_2_3_4_6` est plus forte que `5_4_3_2_1` ?

Je regarde mon implémentation de `AddGroups` pour la partie 1 :

```no_run
AddGroups ← (
  Groups.
  ⊂
)
```

Non, la main est préfixée par les groupes représentant son type, mais à part ça elle reste dans l'ordre d'origine.

Je me dis que j'ai eu beaucoup de chance d'arriver à la bonne réponse pour la partie 1 malgré cet oubli, que je rectifie immédiatement. Quel n'est pas ma surprise de constater que le score calculé change !

Je retourne lire l'énoncé. Effectivement, il n'est dit nulle part que les cartes doivent être triées avant d'être comparées : une autre différence par rapport au poker !

Bref, j'ai bien eu de la chance : mon erreur dans la lecture de l'énoncé a été compensée par mon oubli dans l'implémentation…

### Tout est bien qui finit bien

Voici enfin `PartTwo`.

```
ParseHandTwo ← ⊗:"0J23456789TQKA"
ParseTwo ← ⊜(⊓ParseHandTwo parse ⊃(↙5|↘6)) ≠@\n.
Sort ← ⊏⍏.
Groups ← ⬚0↯ [5]  ⇌Sort  ⊕⧻  ⊛  .
SubAllJokers ← ≡(⍜(⊙▽∘)≡(⊓∘;)) +2⇡12 ∩¤ =1.
BestGroups ← ⊡ ⊢ ⍖ . ≡Groups SubAllJokers
AddBestGroups ← (
  ⊃(BestGroups|∘)
  ⊂
)
SortByHandsTwo ← (
  ≡AddBestGroups
  ⍏
  ⊏
)
ScoreGame ← /+ × +1⇡⧻.
PartTwo ← (
  ParseTwo
  SortByHandsTwo
  ScoreGame
)

$ 32T3K 765
$ T55J5 684
$ KK677 28
$ KTJJT 220
$ QQQJA 483
⍤⊃⋅∘≍ 5905 PartTwo
```
