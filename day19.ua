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
MakeDot ← (
  °□⊢⊜□¬⌕"\n\n".
  /⊐⊂⊜(
    ⊗ @{.
    □$"_\n" ⊂⊃(
      $"\"_\" -> "↙
    | ↘¯1/⊐⊂⊜(□$"\"_\","⇌↙ ⊗ @:.)≠@,.⇌↘¯1↘+1
    )
  )≠@\n.
  $"digraph {rankdir=LR;ranksep=10;splines=false;\n_}\n"
)
# ( rule block instateblocks -- outblock instateblocks )
ApplyRuleToBlock ← (|3.2
  # -- rule block instateblocks
  °[⊙⊙⊙∘] # unpack rule
  # -- attrindex min max next block instateblocks
  ⊃(
    ⊙⋅⋅⋅∘ # -- attrindex block
  | ⋅⊙⊙∘
  )
  # -- attrindex block min max next inblockstates
  ⊃(
    ⊙∘  # keep attrindex and block
  | °□⊡ # pick attribute range
    # -- range min max
    # compare range
    ↧⊃(<|>⊙;|∘)
    # split range
    ∩□⊃▽(▽¬)
    # -- inrange outrange
  )
  # -- attrindex block inrange outrange next instateblocks
  ⊃(⊙⊙∘|⊙⊙⋅∘)
  # -- attrindex block inrange attrindex block outrange next instateblocks
  ∩(⍜⊡⋅∘)
  # -- inblock outblock next instateblocks
  ⊃(
    ⋅∘     # keep outblock
  |        # append to instateblocks
    {:⊙⋅∘} # couple outblock and nextstate
    ⊂¤
  )
  # -- outblock instateblocks'
)
# ( maximum -- block )
InitialBlock ← (
  +1⇡ # 1 to max
  ▽ 4 □
)
# ( stateblock workflows -- newstateblocks )
Expand ← (|2
  # -- stateblock workflows
  ∩°□°⊟
  # -- state block workflows
  ⊃(°□⊡⊙⋅∘|⋅∘) # get workflow from state
  # -- workflow block
  ⊙⊙(
    [] # newstateblocks
  )
  # -- workflow block newstateblocks
  ∧(|3.2
    ApplyRuleToBlock
  )
  # -- finalblock newstateblocks
  ⍤"final block should have empty range"≍□[]⊢
  # -- newstateblocks
)
# ( stateblocks -- accepted stateblocks' )
CountAndFilter ← (|1.2
  # -- newstateblocks
  ≡°□⊢⍉. # get states
  ⊃(
    =¯2
    ▽
    ;°⊟⍉
    ≡(
      °□
      ≡⧻
      /×
    )
    /+
  | ▽≥0
  ) # count accepted, remove rejected
  # -- newaccepted newstateblocks
)
Step ← (
  ⊃(
    ↘1 # remaining stateblocks
  | ⊢  # pop first stateblock
    # -- stateblock totalaccepted workflows
    ⊃(
      ⋅∘ # keep totalaccepted
    | ⊙; # drop totalaccepted
      Expand
      # -- newstateblocks
      CountAndFilter
      # -- newaccepted newstateblocks
    | ⋅⋅∘ # keep workflows
    )
    # -- totalaccepted newaccepted newstateblocks workflows
    :+
    # -- stateblocks accepted workflows
  )
  ⊂: # insert new stateblocks in stack
)
# ( maximum workflows -- totalaccepted )
Loop ← (
  # -- workflows
  [{0 InitialBlock ∘}] # init stack of stateblocks
  # -- stateblocks workflows
  ⊙0
  # -- stateblocks totalaccepted workflows
  ⍢(Step|±⧻) # until stateblocks empty
  ⋅⊙;        # keep only totalaccepted
  # -- totalaccepted
)
PartTwo ← (
  ;Parse
  Loop 4000
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

⍤⊃⋅∘≍ 19114 PartOne.
⍤⊃⋅∘≍ 167409079868000 PartTwo

$ in{s<3:A,bbb}
$ bbb{x>5:R,A}
$
$
;Parse
Loop 10
Aeq 6000

&p "Tests OK"
---
Aeq 421983 PartOne &fras "day19.txt"
# &fwa "day19.dot" MakeDot &fras "day19.txt"
Aeq 129249871135292 PartTwo &fras "day19.txt"
