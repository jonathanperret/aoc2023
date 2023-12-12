## Partie 1

Alors, on nous présente une liste de chaînes avec en face de chacune une liste d'entiers :

```no_run
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
```

Et il faut pour chacune de ces lignes énumérer le nombre de façons qu'il y a de remplacer ces `?` par soit `.` soit `#`, tout en satisfaisant la séquence d'entiers qui décrit la taille des différents groupes de `#`. C'est le principe de Picross, si vous connaissez.

Alors, clairement on peut traiter les lignes indépendamment.

Je jette un œil à mon fichier d'entrée. Je constate qu'il y a un maximum de 19 caractères `?` sur une ligne. Donc si je voulais énumérer tous les remplacements possibles des `?` par `#` ou `.`, ça ferait `2^19 = 524288` cas pour cette seule ligne. Et comme il y a `1000` lignes…

Une autre façon de voir le problème c'est de voir par exemple la séquence `5,7` comme une équation `x + 5 + y + 7 + z` où `x ≥ 0`, `y ≥ 1`, `z ≥ 0` et `x + 5 + y + 5 + z` est égal à la longueur de la chaîne cible.

Plutôt que d'énumérer les remplacements des `?`, je peux donc plutôt énumérer les décompositions d'un entier `n` (la longueur de la chaîne) en somme de `k` entiers. Pour éviter le cas particulier du premier et du dernier qui peuvent être égaux à `0`, je modifie la chaîne en ajoutant un `.` à droite comme à gauche, ce qui ne devrait pas changer le résultat mais me permet d'utiliser une décomposition en entiers supérieurs ou égaux à `1`.

J'écris une fonction — récursive ! C'est expérimental en Uiua… — qui énumère les façons de découper un entier `n` en une somme de `k` entiers supérieurs ou égaux à `1`.

```
# Experimental!
AllSplits ← (
  ↬(|2
    # entrée: n, k
    # out: liste de décompositions
    =1. # on arrête la récursion si k=1
    (
      ⊃(
        -1  # combien d'autres entiers
        -   # ce qui resterait à découper si les autres entiers valaient 1
        +1⇡ # tailles possibles du premier entier
        | ⊙∘
      )
      # on énumère les possibilités du premier entier
      ≡(|3
        ⊃(
          -1;
            | -⊙;
            | ∘
        )
        ↫ # récursion!
        # on ajoute ce premier entier à chaque sous-liste
        :
        ≡⊂
        □
      )
      °□/(⊂∩°□) # on rassemble toutes les sous-listes
    |           # cas d'un seul groupe
      ⍤⊃⋅∘≍1
      [[∘]]
    )
  )
)
⍤⊃⋅∘≍ [[4]] AllSplits 1 4
⍤⊃⋅∘≍ [1_3 2_2 3_1] AllSplits 2 4
⍤⊃⋅∘≍ [1_1_2 1_2_1 2_1_1] AllSplits 3 4
```

Et du coup la première partie :

```
# Experimental!
Lines ← ⊜□≠@\n.
Parse ← (
  Lines
  ≡(
    °□
    °⊟⊜(□)≠@\s.
    :
    □⊜⋕≠@,.°□
  )
)
AllSplits ← ↬(|2
  (
    °□/(⊂∩°□) ≡(|3 □ ≡⊂ : ↫ ⊃(-1;|-⊙;|∘)) ⊃(+1⇡ - -1|⊙∘)
  | [[∘]] ⍤⊃⋅∘≍1
  ) =1.
)
MakePattern ← (
  ⊙(⊂:0)
  ⍉⊟
  ≡(
    °⊟
    ⊓(▽:@.|▽:@#)
    ⊂
    □
  )
  /⊐⊂
)
MatchPattern ← (
  # en entrée: la chaîne à tester, la chaîne cible
  ⊃(
    =      # égalité directe
  | ⋅(=@?) # positions des `?`
  )
  ↥  # ça correspond là où c'est égal ou il y a un `?`
  /↧ # le résultat est le ET de toutes les positions
)
CountPossible ← (
  ⊙($"._."°□)     # on ajoute des `.` à droite et à gauche
  ⊃(+1⧻|-/+⊙⧻|⊙∘)

  AllSplits
  ⊙¤
  ≡MakePattern
  ⊙¤
  ≡MatchPattern
  /+
)
PartOne ← (
  Parse
  ≡(
    ∩°□
    CountPossible
  )
  /+
)

$ ???.### 1,1,3
$ .??..??...?##. 1,1,3
$ ?#?#?#?#?#?#?#? 1,3,1,6
$ ????.#...#... 4,1,1
$ ????.######..#####. 1,6,5
$ ?###???????? 3,2,1
⍤⊃⋅∘≍ 21 PartOne
```

## Partie 2

La longueur de chaque entrée se multiplie par 5.

Évidemment, ça ne vas pas passer avec ma technique d'énumération.

C'est un problème qui crie "progammation dynamique".

La programmation dynamique s'applique aux problèmes qui peuvent se décomposer en sous-problèmes et dont la solution d'un sous-problème est fonction des solutions de ses sous-sous-problème.

Ici, je pense qu'un sous-problème intéressant à considérer est "Dans les `n` premiers caractères de la chaîne cible (`..#???#..`), de combien de façons peut-on placer les `k` premiers groupes de `#` demandés, de sorte à utiliser toute la sous-chaîne (c'est-à-dire que la sous-chaîne se termine par le dernier `#` du dernier groupe) ?"

Quand il n'y a qu'un seul groupe (`k=1`) à considérer, la réponse est forcément `0` ou `1` : soit les `n` premiers caractères de la chaîne peuvent se terminer avec ce groupe, par exemple `..#??` pour `###`, soit ce n'est pas possible, soit parce que `n` est inférieur à la taille du groupe, soit parce que le préfixe de longueur `n` ne se termine pas par un motif compatible avec le groupe, par exemple `.##.?`, `.###.` (le groupe `###` pourrait apparaître dans cette dernière chaîne, mais pas en position finale), ou encore `.#.###` (le groupe `###` peut être placé en position finale mais il resterait un `#` isolé à sa gauche qui ne correspondrait à aucun groupe).

Dans `.??..??...?##.`, pour placer un groupe de longueur 1 soit `#`, les sous-chaînes compatibles sont `.?`, `..?`, `..??..?`, `.??..??`, `.??..??...?` et `.??..??...?#`.

Pour chacune de ces sous-chaînes, il reste la partie droite de la chaîne d'origine sur laquelle il reste à placer les groupes restants. C'est là qu'apparaît la notion de sous-problème : si je sais calculer le nombre de possibilités pour cette sous-liste de groupes sur cette sous-chaîne, je devrais m'en sortir.

Plus qu'à énumérer les positions du deuxième groupe, et pour chacune d'entre elles répéter avec le troisième, et ainsi de suite ? Pas si vite. Si je faisais ça naïvement, j'aurais beaucoup trop de cas à énumérer — on a jusqu'à 30 groupes dans cette partie, et des chaînes de plus de 100 caractères (donc beaucoup de positions potentielles pour un groupe). Dans le pire des cas je pourrais me retrouver à énumerer quasiment `100^30` cas.

C'est ici qu'intervient la programmation dynamique. Une fois que j'ai énuméré les positions de mes deux premiers groupes, j'ai une liste (ayant au maximum environ `100*100` éléments) de couples de positions possibles. Par exemple pour placer deux groupes de taille `1` dans `.??..??...?##`, je peux commencer par une de ces chaînes :
* `.#...#`, en laissant `?...?##` ;
* `..#..#`, en laissant `?...?##` ;
* `.#....#`, en laissant `...?##` ;
* `..#...#`, en laissant `...?##`.

Si ma liste de groupes est `1,1,3`, il me reste alors un groupe de taille `3` à placer. Si j'utilisais l'approche naïve, j'essaierais de le placer dans chacune des `4` chaînes restantes ci-dessus. Mais au lieu de ça, je peux plutôt observer qu'il n'y a que deux chaînes différentes à tester, correspondant aux deux longueurs possibles consommables avec les deux premiers groupes.

De plus, comme chacune de ces chaînes est nécessairement un suffixe de la chaîne de départ, le nombre de sous-chaînes à tester ne dépassera jamais la longueur de la chaîne de départ.

Dans le cas ci dessus, il me suffit de noter que le suffixe `?...?##` apparaît deux fois, donc si je résouds le problème de comptage avec les groupes restants sur ce suffixe, il faudra multiplier ce résultat par 2. De même pour `...?##`. Voilà comment un nombre de calculs exponentiel (multiplier par `100` à chaque étape) devient raisonnable (`100` chaînes à tester par étape).

Bon, ça fait quand même beaucoup de code à la fin.

```
Lines ← ⊜□≠@\n.
Parse ← (≡(□⊜⋕≠@,.°□ : °⊟⊜(□)≠@\s. °□) Lines)
MatchPattern ← (
  # en entrée: la chaîne à tester, la chaîne cible
  ⊃(
    =      # égalité directe
  | ⋅(=@?) # positions des `?`
  )
  ↥  # ça correspond là où c'est égal ou il y a un `?`
  /↧ # le résultat est le ET de toutes les positions
)
IsPrefixValidForGroup ← (
  # en entrée: longueur de préfixe, taille du groupe, chaîne cible
  ⊃(
    ⊃(-:|⋅∘)      # longueur des `.`, taille du groupe
    ⊂⊓(▽:@.|▽:@#) # générer une chaîne candidate `...##`
  | ↙ ⊙;          # extraction du préfixe
  )
  # la chaîne candidate, le préfixe
  MatchPattern
)
FindPrefixes ← (
  # en entrée: taille de groupe, chaîne cible
  # en sortie: les longueurs de préfixe valides
  ⊃(>⊙⧻|⊙∘) # la cible doit être plus longue que le groupe
  (
    [] # sinon, aucun préfixe ne marchera
  | ⊃(
      ∘
    | -⊙⧻ # longueur de chaîne moins taille du groupe
      +1⇡ # nombres possibles de `.` à ajouter à gauche
    | ⊙∘
    )
    + # on ajoute la longueur de groupe aux longueurs de `.`
    ⊃(
      ⊙⊙¤ # on fixe la chaîne cible
      # pour chaque longueur de préfixe on teste le groupe
      ≡IsPrefixValidForGroup
    | ∘
    )
    ▽ # ne garder que les longueurs de préfixe qui marchent
  )
)
NextGroupPrefixes ← (
  # en entrée: taille de groupe, table des chemins, chaîne cible
  # en sortie: la table mise à jour
  ⊃(⋅(⇡⧻)|⋅∘|∘) # on énumère les longueurs de préfixe
  ⊙⊙⊙¤          # on fixe la chaîne cible
  ⬚0≡(
    # pour chaque longueur de préfixe
    ±, # on teste si le nombre de chemins est 0
    (
      0 # on reste à 0 s'il y a 0 chemins
    | ⊃(⋅⋅∘|↘⊙⋅⋅∘|∘|⋅∘)
      FindPrefixes

      +  # on ajoute la longueur de préfixe
      °⊚ # on convertit la liste de longueurs en table binaire
      ×  # on multiplie par le nombre de chemins vers ce préfixe
    )
  )
  /+ # on additionne les lignes pour former la nouvelle table
)
DoGroups ← (
  # en entrée: liste des groupes, chaîne cible
  ⊙¤    # on fixe la chaîne cible
  ⊙⊙[1] # table initiale: un seul chemin qui consomme 0 caractères
  ∧(
    ⊙: # on permute pour satisfaire NextGroupPrefixes
    NextGroupPrefixes
  )
  # il reste la table qu'on a accumulée
)
ExpandTargets ← ≡⍜°□($"_?_?_?_?_" ....)
ExpandGroups ← ≡⍜°□(▽ 5)
MinPrefixLength ← -⊃(⊗ @# ⇌|⧻)
Solve ← (
  ≡(
    ∩°□
    ⊙$"._" # on ajoute un `.` à gauche pour éviter un cas spécial
    ⊃(⋅MinPrefixLength|DoGroups)
    ↘  # on enlève les préfixes qui laissent des `#`
    /+ # on fait la somme des valeurs de chaque préfixe
  )
  /+
)
PartOne ← Solve Parse
PartTwo ← Solve ⊓ExpandGroups ExpandTargets Parse

$ ???.### 1,1,3
$ .??..??...?##. 1,1,3
$ ?#?#?#?#?#?#?#? 1,3,1,6
$ ????.#...#... 4,1,1
$ ????.######..#####. 1,6,5
$ ?###???????? 3,2,1

⍤⊃⋅∘≍ 21 PartOne .
⍤⊃⋅∘≍ 525152 PartTwo
```
