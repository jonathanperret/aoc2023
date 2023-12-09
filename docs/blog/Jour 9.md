## Ce que j'ai retenu de l'épisode précédent

Noter en même temps que je réfléchis, ça prend un peu de temps mais ça peut quand même m'éviter de partir dans un mur.

Je suis quand même content de la façon dont j'ai pu gérer une structure de pile complexe à travers plusieurs fonctions. Je me demande s'il y a des pratiques Uiua qui permettraient d'améliorer encore cette gestion.

## Partie 1

Nous voilà dans une oasis. Et un delta-plane, mais il faut attendre que le vent se lève pour s'en servir.

En attendant, on fait des "observations écologiques".

Chacune de ces lignes contient l'historique d'une valeur :

```no_run
$ 0 3 6 9 12 15
$ 1 3 6 10 15 21
$ 10 13 16 21 30 45
```

Il faut réussir à prédire la prochaine valeur qui irait sur chaque ligne. Là comme ça, avant d'avoir lu la suite de l'énoncé, je dirais `18` pour la première ligne, mais ensuite… la deuxième me rappelle quelque chose ?

Le processus décrit dans l'énoncé pour obtenir les prochaines valeurs est le suivant : tout d'abord, construire des listes de différences entre les valeurs consécutives, plusieurs fois jusqu'à obtenir une ligne de `0` :

```no_run
1   3   6  10  15  21
  2   3   4   5   6
    1   1   1   1
      0   0   0
```

Puis on peut ajouter un `0` à la dernière ligne, et remonter logiquement :

```no_run
10  13  16  21  30  45  68
   3   3   5   9  15  23
     0   2   4   6   8
       2   2   2   2
         0   0   0
```

Ça a l'air jouable pour l'instant, on verra ce que demandera la deuxième partie. Probablement la même chose avec des nombres gigantesques et il faudra trouver une formule adéquate, mais pour le moment…

Lire l'entrée, c'est vraiment facile aujourd'hui :

```
Parse ← ⊜(⊜⋕ ≠@\s.)≠@\n.

$ 0 3 6 9 12 15
$ 1 3 6 10 15 21
$ 10 13 16 21 30 45

Parse
```

Je constate que je n'ai même pas besoin de boîtes, puisque toutes les (`200`) lignes ont le même nombre d'éléments (`20`). J'aperçois aussi des nombres conséquents comme `10231852` qui laissent présager une bonne prise de tête en partie 2.

Mais d'ici là, calculons des différences consécutives. C'est quelque chose que j'ai fait hier. J'avais utilisé `windows` mais j'essaie autre chose : décaler la liste puis la soustraire à elle-même :

```
Deltas ← -⊃(⍜⇌(↘1)|↘1)
[0 3 6 9 12 15]
Deltas
```

Ensuite, il faut répéter l'opération. Je réfléchis quelques instants à ce que je dois sauvegarder pour calculer le dernier élément à la fin : seul le dernier élément de chaque liste de différences me semble impliqué dans le calcul ?

En tout cas, c'est un travail pour `do`. On va appliquer `Deltas` jusqu'à ce que le `maximum` de la liste soit `0`… Oh. Il y a des nombres négatifs dans l'entrée. Je vais donc plutôt utiliser `deduplicate` et vérifier que le résultat est `[0]`.

Ça pourrait ressembler à ça :

```
Deltas ← -⊃(⍜⇌(↘1)|↘1)
RepeatedDeltas ← ⍢(Deltas) (¬≍[0]⊝)

[0 3 6 9 12 15]
RepeatedDeltas
```

Bien sûr, ce n'est pas suffisant, il faut retenir la séquence des nombres qui vont me permettre de faire le calcul final. Par exemple si j'arrive à :

```no_run
10  13  16  21  30  45  68
   3   3   5   9  15  23
     0   2   4   6   8
       2   2   2   2
         0   0   0
```

Le résultat (`68`) est donné par : `45 + 23`, ce `23` étant obtenu par `15 + 8` et ainsi de suite. Si je retenais uniquement le dernier élément de chaque liste pendant la "descente" j'obtiendrais :

```no_run
45
15
6
2
0
```

Le total recherché est bien `45 + 15 + 6 + 2 = 68`. Mais je n'ai même pas besoin de retenir la liste, je peux simplement additionner au fur et à mesure que je descends.

Mon accumulateur pour `do` sera donc une valeur qui commence à `0`. J'appelle la fonction résultante `FindNext` :

```
Deltas ← -⊃(⍜⇌(↘1)|↘1)
FindNext ← (
  0 # l'accumulateur
  ⍢(
    ⊙⊃(
      ⊢⇌     # on récupère le dernier élément
    | Deltas # puis on applique Deltas
    )
    +        # on ajoute à l'accumulateur le dernier élément
  )(¬≍[0]⋅⊝) # jusqu'à ce que la liste ne contienne que des `0`
  ⊙;         # pour finir on efface la liste de `0`
)

FindNext [10 13 16 21 30 45]
```

Voilà, plus qu'à appliquer ça sur chaque ligne et faire la somme :

```
Parse ← ⊜(⊜⋕ ≠@\s.)≠@\n.
Deltas ← -⊃(⍜⇌(↘1)|↘1)
FindNext ← ⊙; ⍢(+ ⊙⊃(⊢⇌|Deltas))(¬≍[0]⋅⊝) 0
PartOne ← (
  Parse
  ≡FindNext
  /+
)

$ 0 3 6 9 12 15
$ 1 3 6 10 15 21
$ 10 13 16 21 30 45
⍤⊃⋅∘≍ 114 PartOne
```

## Partie 2

Cette première partie était tranquille, que nous réserve la suite ?

Ah, il faut compléter les listes sur la gauche, maintenant.

```no_run
(5)  10  13  16  21  30  45
  (5)   3   3   5   9  15
   (-2)   0   2   4   6
      (2)   2   2   2
        (0)   0   0
```

Il doit y avoir un loup, parce que ça ne paraît pas si compliqué ? Il suffit de retourner la liste en entrée, non ?

J'essaie, ça marche sur l'exemple. Et sur l'entrée complète ! On est bien le 9 décembre ?

```
Parse ← ⊜(⊜⋕ ≠@\s.)≠@\n.
Deltas ← -⊃(⍜⇌(↘1)|↘1)
FindNext ← ⊙; ⍢(+ ⊙⊃(⊢⇌|Deltas))(¬≍[0]⋅⊝) 0
PartTwo ← (
  Parse
  ≡(FindNext⇌)
  /+
)

$ 0 3 6 9 12 15
$ 1 3 6 10 15 21
$ 10 13 16 21 30 45
⍤⊃⋅∘≍ 2 PartTwo
```
