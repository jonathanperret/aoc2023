# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

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
---
[787 2655 1222 2876]
[[3 ¯∞ 1351 1]
 [0 ¯∞ ∞ 8]]
ApplyWorkflow
Aeq 8

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
Parse.

°□⋅⊢
[[3 ¯∞ 1351 1]
 [0 ¯∞ ∞ 8]]
Aeq

⍤⊃⋅∘≍ 19114 PartOne

&p "Tests OK"
---
Aeq 421983 PartOne &fras "day19.txt"
# Aeq 0 PartTwo &fras "day19.txt"
