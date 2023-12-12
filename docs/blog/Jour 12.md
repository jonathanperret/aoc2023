## Partie 1

### énoncé

### plan

traitement par ligne.

- brute force: max. 19 `?` => 524288 possibilités à tester
- max. 20 caractères au total

- séparer en n groupes : 5,7 -> x,5,y,7,z avec x+y+z=longueur totale

- automate fini?

- `1,…` = `# | .# | ..# | ...# | …`
puis `,1,…` avec le reste, etc.

### implémentation

Je finis par changer mon fusil d'épaule, parce que j'en ai marre.

J'écris une fonction — récursive ! — qui énumère les façons de découper un entier `n` en une somme de `k` entiers supérieurs à `1`.

```
# Experimental!
AllSplits ← (
  ↬(|2
    # in: count, length
    # out: list of splits
    =1. # test to end recursion: only one group to make?
    (
      ⊃(
        -1  # how many other groups
        -   # how much remaining for first group
        +1⇡ # possible sizes for first group
        | ⊙∘
      )
      # for each first group size
      ≡(|3
        # in: group size, count, length
        # out: list of splits
        ⊃(
          -1;     # one fewer group
            | -⊙; # remaining size
            | ∘   # keep first group size
        )
        # now on stack: remaining count, remaining length, first group size
        ↫
        # now on stack: splits, first group size
        # prepend first group size to each split
        :
        ≡⊂
        □
      )
      °□/(⊂∩°□) # join all split lists
    |           # only one group requested: just put it all in
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
AllSplits ← (
  ↬(|2
    # in: count, length
    # out: list of splits
    =1. # test to end recursion: only one group to make?
    (
      ⊃(
        -1  # how many other groups
        -   # how much remaining for first group
        +1⇡ # possible sizes for first group
        | ⊙∘
      )
      # for each first group size
      ≡(|3
        # in: group size, count, length
        # out: list of splits
        ⊃(
          -1;     # one fewer group
            | -⊙; # remaining size
            | ∘   # keep first group size
        )
        # now on stack: remaining count, remaining length, first group size
        ↫
        # now on stack: splits, first group size
        # prepend first group size to each split
        :
        ≡⊂
        □
      )
      °□/(⊂∩°□) # join all split lists
    |           # only one group requested: just put it all in
      ⍤⊃⋅∘≍1
      [[∘]]
    )
  )
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
  # in: candidate, target
  ⊃(
    =      # direct match
  | ⋅(=@?) # find ?s
  )
  ↥  # each matches if either direct or `?`
  /↧ # pattern matches if all chars match
)
CountPossible ← (
  ⊙($"._."°□)     # add holes left and right
  ⊃(+1⧻|-/+⊙⧻|⊙∘) # hole count, holes total

  AllSplits
  ⊙¤           # fix groups list
  ≡MakePattern # make all patterns
  ⊙¤           # fix target
  ≡MatchPattern
  /+ # count matching
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

Ici, je pense qu'un sous-problème intéressant à considérer est "dans les `n` premiers caractères de la chaîne cible (`..#???#..`), de combien de façons peut-on placer les `k` premiers groupes de `#` demandés ?"





#### fin
