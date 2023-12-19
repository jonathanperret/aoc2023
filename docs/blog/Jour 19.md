## Partie 1

Houla, il va y avoir du travail de _parsing_ aujourd'hui.

```no_run
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
```

Apparemment il s'agit d'un programme pour classer des pièces, qui sont données en bas.

Chaque pièce (il y en a `200` dans l'entrée) a quatre attributs, `x`, `m`, `a` et `s`. Chacune commence dans l'état `in`. Puis applique les différentes conditions pour se promener entre les états, jusqu'à arriver à `R` ou `A`. Ensuite il faut faire la somme des `x`, `m`, `a` et `s` pour toutes les pièces acceptées.

Attaquons donc l'analyse de ce texte. Je vais tout de suite numéroter les états. Enfin, après avoir lu toutes les règles quand même.

```
ParseRule ← ⍜°□(
  ⊜□ ¬∊:",{}".
  ⊃(
    ↘1
    ≡(
      °□
      ⊜□≠@:.
      >1⧻.
      (
        [0 ¯∞ ∞ ⊢]
        | °⊟
        ∩°□
        ⊃(
          ⊗:"xmas"⊢
            | =@>⊃(⊡1|⋕↘2)
          (¯∞|:∞)
        )
        {⊙⊙⊙∘}
      )
    )
  | ⊢
  )
)
NumberStates ← (
  ⊙¤
  ≡(
    ⊙¤
    ⍜°□ ≡(
      ⍜(⊢⇌)(□ -2⊗)
      ≡°□
    )
  )
)
SortStates ← ⍜:(
  ⍖=□"in".
  ,:
  ∩⊏
  ⊂ {"A" "R"}
)
ParsePart ← ⊜⋕ ∊:"0123456789". °□
Parse ← (
  ∩°□°⊟⊜(□⊜□≠@\n.)¬⌕"\n\n".
  :⊓(NumberStates SortStates ≡ParseRule|≡ParsePart)
)

$ px{a<2006:qkq,m>2090:A,rfg}
$ pv{a>1716:R,A}
$ lnx{m>1548:A,A}
$ rfg{s<537:gd,x>2440:R,A}
$ qs{s>3448:A,lnx}
$ qkq{x<1416:A,crn}
$ crn{x>2662:A,R}
$ in{s<1351:px,qqz}
$ qqz{s>2770:qs,m<1801:hdj,R}
$ gd{a>3333:R,R}
$ hdj{m>838:A,pv}
$
$ {x=787,m=2655,a=1222,s=2876}
$ {x=1679,m=44,a=2067,s=496}
$ {x=2036,m=264,a=79,s=2244}
$ {x=2461,m=1339,a=466,s=291}
$ {x=2127,m=1623,a=2188,s=1013}
Parse
```

Voilà, les noms d'états ont complètement disparu au profit d'indices (j'ai pris soin de faire en sorte que `in` ait l'indice `0`, et j'ai ajouté `A` et `R` en indices `-2` et `-1` respectivement). Et chaque règle est exprimée par un tableau de `4` éléments : attribut à tester, minimum, maximum, nouvel état. J'ai glissé des `∞` et des `-∞` aux bons endroits pour ne pas avoir à distinguer `<` de `>`. Et pour les cas inconditionnels, on testera simplement si l'attribut `0` (`x`) est entre `-∞` et `∞`.

Me voici armé pour l'exécution des règles.

En fait, je me retrouve plusieurs fois à retoucher l'analyseur d'entrée ci-dessus (le code ci-dessus est la dernière version) que je pensais être au point.

Mais une fois qu'il est vraiment au point, l'application des _workflows_ se fait sans difficulté particulière. Ma numérotation des états me permet de donner comme condition d'arrêt le fait d'atteindre un état négatif.

```
ParseRule ← ⍜°□(
  ⊜□ ¬∊:",{}".
  ⊃(
    ↘1
    ≡(
      °□
      ⊜□≠@:.
      >1⧻.
      (
        [0 ¯∞ ∞ ⊢]
        | °⊟
        ∩°□
        ⊃(
          ⊗:"xmas"⊢
            | =@>⊃(⊡1|⋕↘2)
          (¯∞|:∞)
        )
        {⊙⊙⊙∘}
      )
    )
  | ⊢
  )
)
NumberStates ← (
  ⊙¤
  ≡(
    ⊙¤
    ⍜°□ ≡(
      ⍜(⊢⇌)(□ -2⊗)
      ≡°□
    )
  )
)
SortStates ← ⍜:(
  ⍖=□"in".
  ,:
  ∩⊏
  ⊂ {"A" "R"}
)
ParsePart ← ⊜⋕ ∊:"0123456789". °□
Parse ← (
  ∩°□°⊟⊜(□⊜□≠@\n.)¬⌕"\n\n".
  :⊓(NumberStates SortStates ≡ParseRule|≡ParsePart)
)
ApplyWorkflow ← (
  ⊃(⊏ ⊢|°[⊙⊙∘] ↘1)⍉
  ↧⊓<>,:
  ⊢▽
)
Step ← (
  ⊃(
    ⊃(°□⊡⊙;|⋅∘)
    ApplyWorkflow
  | ⋅⊙∘
  )
)
ApplyWorkflows ← (
  0 # initial state (in)
  ⍢Step(≥0)
  ⊙⋅;
  =¯2
)
PartOne ← (
  Parse
  ⊃∘(
    ⊙¤
    ≡ApplyWorkflows
  )
  ▽:
  /+♭
)

$ px{a<2006:qkq,m>2090:A,rfg}
$ pv{a>1716:R,A}
$ lnx{m>1548:A,A}
$ rfg{s<537:gd,x>2440:R,A}
$ qs{s>3448:A,lnx}
$ qkq{x<1416:A,crn}
$ crn{x>2662:A,R}
$ in{s<1351:px,qqz}
$ qqz{s>2770:qs,m<1801:hdj,R}
$ gd{a>3333:R,R}
$ hdj{m>838:A,pv}
$
$ {x=787,m=2655,a=1222,s=2876}
$ {x=1679,m=44,a=2067,s=496}
$ {x=2036,m=264,a=79,s=2244}
$ {x=2461,m=1339,a=466,s=291}
$ {x=2127,m=1623,a=2188,s=1013}

⍤⊃⋅∘≍ 19114 PartOne
```
